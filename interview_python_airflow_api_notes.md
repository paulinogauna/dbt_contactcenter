# Guía rápida para entrevista: Python, APIs SQL, paginación y Airflow

## 1. Qué deberías saber

### Python básico
- funciones
- listas y diccionarios
- loops
- manejo de errores
- imports comunes como `requests` y `datetime`

#### Ejemplo
```python
import requests
from datetime import datetime

def obtener_datos(fecha):
    return f"Procesando {fecha}"

rows = [{"id": 1}, {"id": 2}]
for row in rows:
    print(row["id"])
```

---

## 2. Llamadas a API para ejecutar SQL

Patrón típico:
- endpoint HTTP
- headers con autenticación
- body JSON con SQL
- parámetros
- parseo de respuesta
- manejo de errores

#### Ejemplo básico
```python
import requests

API_URL = "https://api.ejemplo.com/query"
TOKEN = "mi_token"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

payload = {
    "sql": """
        SELECT id, updated_at
        FROM tickets
        WHERE updated_at >= :since
        ORDER BY updated_at
        LIMIT :limit
    """,
    "params": {
        "since": "2026-05-20 00:00:00",
        "limit": 1000
    }
}

response = requests.post(API_URL, json=payload, headers=headers, timeout=60)
response.raise_for_status()

data = response.json()
rows = data.get("rows", [])
print(rows)
```

### Qué deberías poder explicar
- `requests.post(...)`
- `json=payload`
- `headers`
- `timeout`
- `raise_for_status()`
- `response.json()`

---

## 3. Filtrar datos nuevos o actualizados

### SQL típico
```sql
SELECT id, created_at, updated_at
FROM tickets
WHERE updated_at >= :desde
  AND updated_at < :hasta
ORDER BY updated_at, id
```

### Nuevos o actualizados
```sql
SELECT id, created_at, updated_at
FROM tickets
WHERE (created_at >= :desde AND created_at < :hasta)
   OR (updated_at >= :desde AND updated_at < :hasta)
ORDER BY updated_at, id
```

### Idea clave
No pedir todo. Pedir una ventana incremental:
- `desde`
- `hasta`

---

## 4. Paginación

### Por qué existe
Porque una API suele tener:
- límite de filas
- límite de tamaño de respuesta
- timeout
- restricciones para no devolver millones de registros

### Paginación con `limit` y `offset`
```python
import requests

def fetch_all():
    all_rows = []
    limit = 1000
    offset = 0

    while True:
        payload = {
            "sql": """
                SELECT id, updated_at
                FROM tickets
                ORDER BY updated_at, id
                LIMIT :limit OFFSET :offset
            """,
            "params": {
                "limit": limit,
                "offset": offset
            }
        }

        response = requests.post(API_URL, json=payload, headers=headers, timeout=60)
        response.raise_for_status()

        rows = response.json().get("rows", [])
        if not rows:
            break

        all_rows.extend(rows)
        offset += limit

    return all_rows
```

### Qué decir
Funciona, pero con mucho volumen puede ser ineficiente.

### Paginación mejor: keyset o cursor
```python
import requests

def fetch_incremental(desde):
    all_rows = []
    page_size = 1000
    last_updated_at = desde
    last_id = 0

    while True:
        payload = {
            "sql": """
                SELECT id, updated_at
                FROM tickets
                WHERE updated_at >= :desde
                  AND (
                        updated_at > :last_updated_at
                        OR (updated_at = :last_updated_at AND id > :last_id)
                  )
                ORDER BY updated_at, id
                LIMIT :page_size
            """,
            "params": {
                "desde": desde,
                "last_updated_at": last_updated_at,
                "last_id": last_id,
                "page_size": page_size
            }
        }

        response = requests.post(API_URL, json=payload, headers=headers, timeout=60)
        response.raise_for_status()

        rows = response.json().get("rows", [])
        if not rows:
            break

        all_rows.extend(rows)

        last_row = rows[-1]
        last_updated_at = last_row["updated_at"]
        last_id = last_row["id"]

    return all_rows
```

### Qué decir
Esto escala mejor que `offset`.

---

## 5. Buenas prácticas en APIs SQL
- usar parámetros en vez de concatenar strings
- manejar errores HTTP
- usar timeout
- paginar
- no cargar millones de filas en memoria si no hace falta
- guardar progreso incremental

### Mal ejemplo
```python
sql = f"SELECT * FROM tickets WHERE id = {user_input}"
```

### Mejor
```python
payload = {
    "sql": "SELECT * FROM tickets WHERE id = :id",
    "params": {"id": user_input}
}
```

---

## 6. Manejo de errores básico
```python
import requests

try:
    response = requests.post(API_URL, json=payload, headers=headers, timeout=60)
    response.raise_for_status()
    data = response.json()
except requests.exceptions.Timeout:
    print("Timeout en la API")
except requests.exceptions.HTTPError as e:
    print(f"HTTP error: {e}")
except Exception as e:
    print(f"Error general: {e}")
```

---

## 7. Airflow: qué debes saber

### Conceptos clave
- DAG
- task
- operator
- schedule
- dependencies
- retries
- catchup
- logical date
- `data_interval_start`
- `data_interval_end`

### Ejemplo básico
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

def tarea_simple():
    print("Hola Airflow")

with DAG(
    dag_id="dag_basico",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    t1 = PythonOperator(
        task_id="saludo",
        python_callable=tarea_simple,
    )
```

---

## 8. Pasar parámetros al Python en Airflow
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

def ejecutar_query(fecha_proceso, **context):
    print(f"Fecha de proceso: {fecha_proceso}")

with DAG(
    dag_id="dag_con_parametros",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    t1 = PythonOperator(
        task_id="query",
        python_callable=ejecutar_query,
        op_kwargs={
            "fecha_proceso": "{{ ds }}"
        },
    )
```

### Qué explicar
- `python_callable` apunta a la función
- `op_kwargs` pasa argumentos
- `{{ ds }}` es la fecha lógica del run

---

## 9. Airflow con ventana incremental
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

def consultar_incremental(desde, hasta, **context):
    print(f"Consultando desde {desde} hasta {hasta}")

with DAG(
    dag_id="dag_incremental",
    start_date=datetime(2026, 5, 1),
    schedule="@hourly",
    catchup=False,
) as dag:

    t1 = PythonOperator(
        task_id="consulta_incremental",
        python_callable=consultar_incremental,
        op_kwargs={
            "desde": "{{ data_interval_start }}",
            "hasta": "{{ data_interval_end }}"
        },
    )
```

### Qué decir
Para procesos incrementales es mejor usar `data_interval_start` y `data_interval_end`.

---

## 10. Airflow con llamada a API SQL
```python
import requests
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

API_URL = "https://api.ejemplo.com/query"
TOKEN = "mi_token"

def ejecutar_api_sql(desde, hasta, **context):
    headers = {
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json"
    }

    payload = {
        "sql": """
            SELECT id, updated_at
            FROM tickets
            WHERE updated_at >= :desde
              AND updated_at < :hasta
            ORDER BY updated_at, id
            LIMIT :limit
        """,
        "params": {
            "desde": desde,
            "hasta": hasta,
            "limit": 1000
        }
    }

    response = requests.post(API_URL, json=payload, headers=headers, timeout=60)
    response.raise_for_status()

    rows = response.json().get("rows", [])
    print(f"Filas obtenidas: {len(rows)}")

with DAG(
    dag_id="dag_api_sql",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    t1 = PythonOperator(
        task_id="consultar_api",
        python_callable=ejecutar_api_sql,
        op_kwargs={
            "desde": "{{ data_interval_start }}",
            "hasta": "{{ data_interval_end }}"
        },
    )
```

---

## 11. Dependencias entre tareas

### Secuencial
```python
t1 >> t2 >> t3
```

### Paralelo
```python
t1 >> [t2, t3]
```

### Join
```python
[t2, t3] >> t4
```

### Ejemplo
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

def extraer():
    print("Extraer")

def transformar_clientes():
    print("Transformar clientes")

def transformar_tickets():
    print("Transformar tickets")

def cargar():
    print("Cargar")

with DAG(
    dag_id="dag_paralelo",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    t1 = PythonOperator(task_id="extraer", python_callable=extraer)
    t2 = PythonOperator(task_id="transformar_clientes", python_callable=transformar_clientes)
    t3 = PythonOperator(task_id="transformar_tickets", python_callable=transformar_tickets)
    t4 = PythonOperator(task_id="cargar", python_callable=cargar)

    t1 >> [t2, t3]
    [t2, t3] >> t4
```

---

## 12. Preguntas típicas de entrevista

### ¿Cómo traerías solo datos nuevos?
- usando `updated_at` o `created_at`
- con ventana `desde/hasta`
- evitando full refresh
- paginando resultados

### ¿Qué pasa si la API devuelve demasiados registros?
- usar paginación
- `limit/offset` o cursor
- procesar por lotes
- no guardar todo en memoria

### ¿Cómo pasarías una fecha desde Airflow?
- con `op_kwargs`
- usando `{{ ds }}` o `{{ data_interval_start }}` / `{{ data_interval_end }}`

### ¿Cómo haces que una tarea espere a otra?
```python
t1 >> t2
```

### ¿Cómo ejecutas tareas en paralelo?
```python
t1 >> [t2, t3]
```

---

## 13. Respuestas cortas para memorizar

### Sobre paginación
No pediría millones de filas en una sola llamada. Usaría paginación con `limit/offset` o preferiblemente cursor/keyset si hay mucho volumen.

### Sobre incremental
Filtraría por `updated_at` entre una ventana `desde` y `hasta`, idealmente pasada por Airflow con `data_interval_start` y `data_interval_end`.

### Sobre Airflow
En Airflow usaría un `PythonOperator` o TaskFlow, pasando parámetros con `op_kwargs`, y definiría dependencias con `>>`.

### Sobre robustez
Agregaría `timeout`, manejo de errores, retries y logs.

---

## 14. Mini ejemplo integral
```python
import requests
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

API_URL = "https://api.ejemplo.com/query"
TOKEN = "mi_token"

def extraer_tickets(desde, hasta, **context):
    headers = {
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json"
    }

    limit = 1000
    offset = 0
    total = 0

    while True:
        payload = {
            "sql": """
                SELECT id, updated_at, status
                FROM tickets
                WHERE updated_at >= :desde
                  AND updated_at < :hasta
                ORDER BY updated_at, id
                LIMIT :limit OFFSET :offset
            """,
            "params": {
                "desde": desde,
                "hasta": hasta,
                "limit": limit,
                "offset": offset
            }
        }

        response = requests.post(API_URL, json=payload, headers=headers, timeout=60)
        response.raise_for_status()

        rows = response.json().get("rows", [])
        if not rows:
            break

        total += len(rows)
        offset += limit

    print(f"Total extraído: {total}")

with DAG(
    dag_id="entrevista_ejemplo",
    start_date=datetime(2026, 5, 1),
    schedule="@hourly",
    catchup=False,
) as dag:

    t1 = PythonOperator(
        task_id="extraer_tickets",
        python_callable=extraer_tickets,
        op_kwargs={
            "desde": "{{ data_interval_start }}",
            "hasta": "{{ data_interval_end }}"
        },
    )
```

---

# Dependencia entre DAGs en Airflow

Sí. Un DAG puede depender de otro DAG o esperar a que termine con cierto estado.

## Formas comunes
1. esperar una tarea de otro DAG
2. disparar otro DAG
3. esperar a que el otro DAG complete
4. depender del estado `success`, `failed`, etc.

---

## 1. Esperar otro DAG con `ExternalTaskSensor`
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor

def proceso_final():
    print("El DAG anterior terminó correctamente")

with DAG(
    dag_id="dag_dependiente",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    esperar_otro_dag = ExternalTaskSensor(
        task_id="esperar_dag_origen",
        external_dag_id="dag_origen",
        external_task_id=None,
        allowed_states=["success"],
        failed_states=["failed", "skipped"],
        mode="poke",
        timeout=3600,
    )

    ejecutar = PythonOperator(
        task_id="continuar_proceso",
        python_callable=proceso_final,
    )

    esperar_otro_dag >> ejecutar
```

### Qué significa
- espera al DAG `dag_origen`
- solo sigue si está en `success`
- si el otro queda en `failed` o `skipped`, falla

---

## 2. Esperar una tarea específica de otro DAG
```python
esperar_tarea = ExternalTaskSensor(
    task_id="esperar_task_especifica",
    external_dag_id="dag_origen",
    external_task_id="cargar_datos",
    allowed_states=["success"],
    failed_states=["failed"],
    mode="poke",
    timeout=3600,
)
```

---

## 3. Disparar otro DAG con `TriggerDagRunOperator`
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

with DAG(
    dag_id="dag_lanzador",
    start_date=datetime(2026, 5, 1),
    schedule=None,
    catchup=False,
) as dag:

    lanzar = TriggerDagRunOperator(
        task_id="lanzar_otro_dag",
        trigger_dag_id="dag_destino",
        conf={"fecha": "2026-05-20"},
    )
```

---

## 4. Disparar y esperar al otro DAG
```python
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

lanzar_y_esperar = TriggerDagRunOperator(
    task_id="lanzar_y_esperar",
    trigger_dag_id="dag_destino",
    conf={"fecha": "2026-05-20"},
    wait_for_completion=True,
    poke_interval=30,
    allowed_states=["success"],
    failed_states=["failed"],
)
```

---

## 5. ¿Puede depender del status?
Sí. Puede depender de estados como:
- `success`
- `failed`
- `skipped`

Ejemplo:
```python
allowed_states=["success"]
failed_states=["failed", "skipped"]
```

---

## 6. Caso típico de negocio
- DAG A extrae datos y carga staging
- DAG B espera a que DAG A termine bien
- luego DAG B transforma o publica

Eso se modela con `ExternalTaskSensor`.

---

## 7. Consideración importante
La dependencia entre DAGs normalmente se evalúa para la misma logical date.

Ejemplo:
- `dag_a` corre para `2026-05-20`
- `dag_b` espera el run de `dag_a` también para `2026-05-20`

Si los schedules no están alineados, hay que ajustar la lógica.

---

## 8. Ejemplo simple DAG A y DAG B

### DAG A
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

def cargar():
    print("Carga completada")

with DAG(
    dag_id="dag_a",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    t1 = PythonOperator(
        task_id="cargar_datos",
        python_callable=cargar,
    )
```

### DAG B
```python
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor

def transformar():
    print("Transformación iniciada")

with DAG(
    dag_id="dag_b",
    start_date=datetime(2026, 5, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    wait_a = ExternalTaskSensor(
        task_id="wait_dag_a",
        external_dag_id="dag_a",
        external_task_id="cargar_datos",
        allowed_states=["success"],
        failed_states=["failed"],
        timeout=3600,
        mode="poke",
    )

    t2 = PythonOperator(
        task_id="transformar",
        python_callable=transformar,
    )

    wait_a >> t2
```

---

## 9. Respuesta corta para entrevista
Sí, en Airflow un DAG puede esperar a otro usando `ExternalTaskSensor`, o puede disparar otro DAG con `TriggerDagRunOperator`. También puede depender del estado del otro DAG o de una task específica, por ejemplo continuar solo si terminó en `success`.

---

## 10. Diferencia rápida
- `ExternalTaskSensor`: espera otro DAG o task
- `TriggerDagRunOperator`: lanza otro DAG
- `TriggerDagRunOperator(wait_for_completion=True)`: lo lanza y espera resultado
