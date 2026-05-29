# Guía de estudio: modelos incrementales en dbt

## 1. Qué es un modelo incremental
Un modelo incremental en dbt construye una tabla y, en ejecuciones posteriores, procesa solo una parte de los datos en lugar de recalcular todo el dataset.

Idea base:
- primer run: crea o reconstruye la tabla completa
- runs siguientes: procesa solo filas o particiones nuevas/relevantes
- `is_incremental()` controla la lógica condicional para esos runs posteriores

## 2. Cuándo conviene usar incremental
Conviene cuando:
- el volumen es grande
- recalcular todo es costoso
- existe una columna confiable para filtrar cambios, como `loaded_at`, `updated_at` o una fecha de partición
- el modelo tiene una estrategia clara para inserts, updates o reemplazo de particiones

No conviene cuando:
- el modelo es pequeño
- no existe un watermark confiable
- la lógica incremental es más compleja o riesgosa que un `table`
- el modelo necesita simplicidad para depuración o certificación conceptual

## 3. Cómo piensa dbt un incremental
Para entender incremental, conviene separar 4 piezas:

1. **materialización**
   - `materialized='incremental'`
2. **estrategia incremental**
   - `append`
   - `merge`
   - `delete+insert`
   - `insert_overwrite`
   - depende del adapter
3. **watermark o filtro incremental**
   - la condición dentro de `is_incremental()`
4. **grano del modelo**
   - una fila por ticket
   - una fila por producto versión
   - una fila por ticket y fecha de carga

Si el grano no está claro, la estrategia incremental suele quedar mal definida.

## 4. Qué hace `is_incremental()`
`is_incremental()` no significa “estoy en prod”.

En la práctica, suele ser `true` cuando:
- el modelo es `incremental`
- la relación `{{ this }}` ya existe en el target actual
- no se está ejecutando con full refresh

Entonces:
- primer run en un schema nuevo: normalmente `false`
- segundo run en ese mismo schema: normalmente `true`

## 5. Precedencia de configuración
Orden práctico de precedencia para configs de modelos:

1. defaults de dbt
2. `dbt_project.yml`
3. properties YAML del modelo
4. `{{ config(...) }}` dentro del SQL

Regla corta:
- gana la configuración más específica

Ejemplo:
- `dbt_project.yml` dice `table`
- el modelo tiene `{{ config(materialized='incremental') }}`
- resultado final: `incremental`

## 6. Estrategias incrementales principales

### 6.1 `append`
Comportamiento:
- solo inserta filas nuevas
- no actualiza filas existentes
- no deduplica automáticamente

Úsalo cuando:
- quieres conservar histórico de cargas o eventos
- cada fila nueva debe preservarse
- no necesitas corregir filas ya cargadas

Riesgo principal:
- si reprocesas una ventana hacia atrás, puedes duplicar datos

Ejemplo de riesgo:
```sql
where loaded_at >= (
    select dateadd(day, -1, max(product_loaded_at))
    from {{ this }}
)
```
Con `append`, ese lookback de 1 día vuelve a traer filas ya insertadas. Si no hay deduplicación explícita, se duplican.

Patrón más seguro para `append`:
```sql
where loaded_at > (
    select max(product_loaded_at)
    from {{ this }}
)
```

Si necesitas lookback con `append`, agrega una deduplicación explícita alineada al grano.

### 6.2 `merge`
Comportamiento:
- inserta filas nuevas
- actualiza filas existentes
- requiere una `unique_key` correcta

Úsalo cuando:
- quieres mantener estado actual
- necesitas upsert
- el grano es estable y la clave identifica una fila única

Ejemplo típico:
- una fila por `priority_id`
- `unique_key='priority_id'`

Ventaja:
- una ventana de 1 día hacia atrás suele ser razonable
- no duplica si la `unique_key` está bien definida

Riesgo principal:
- si quieres histórico y usas `unique_key` solo por id de negocio, `merge` sobrescribe historia en vez de preservarla

### 6.3 `delete+insert`
Comportamiento:
- elimina filas existentes que coinciden con la clave
- luego inserta las nuevas

Úsalo cuando:
- el adapter no soporta `merge` como necesitas
- quieres comportamiento tipo upsert sin merge nativo

Requiere:
- `unique_key` correcta
- entender el costo de borrar e insertar

### 6.4 `insert_overwrite`
Comportamiento:
- reemplaza particiones completas
- la unidad operativa principal es la partición, no la fila individual

Úsalo cuando:
- la tabla está particionada
- quieres reprocesar días o períodos completos
- el modelo es histórico o voluminoso y la partición es natural

Ejemplo razonable:
- particionar por `ticket_loaded_date`
- reprocesar el último día

Config conceptual:
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={
        'field': 'ticket_loaded_date',
        'data_type': 'date'
    }
) }}
```

Riesgo principal:
- particionar por `timestamp` completo suele ser mala idea
- la partición debe ser estable y útil, normalmente `date`

## 7. Rol de `unique_key`
`unique_key` define cómo identificar una fila existente para estrategias tipo upsert.

### Importa especialmente en:
- `merge`
- `delete+insert`

### En `append`
- normalmente no cumple un rol operativo real
- no evita duplicados por sí sola

### En `insert_overwrite`
- suele ser secundaria o irrelevante según adapter
- lo importante es la partición a reemplazar

Regla práctica:
- si usas `append`, no asumas que `unique_key` deduplica
- si usas `merge`, la `unique_key` debe representar el grano real

## 8. Grano: la decisión más importante
Antes de elegir estrategia, define el grano.

Ejemplos:
- una fila por ticket
- una fila por ticket y fecha de carga
- una fila por producto versión
- una fila por customer actual

Preguntas clave:
- ¿quiero estado actual o histórico?
- ¿puede haber varias filas por el mismo id de negocio?
- ¿la clave natural es solo el id o id + timestamp/version?

### Estado actual
Suele combinar bien con:
- `merge`
- `unique_key` por id de negocio

### Histórico
Suele combinar mejor con:
- `append` si cada evento/carga debe preservarse
- `insert_overwrite` si el histórico se maneja por particiones
- snapshots si quieres SCD gestionado por dbt

## 9. Lookback windows: cuándo sirven y cuándo dañan
Un lookback window es reprocesar una ventana reciente, por ejemplo 1 día hacia atrás.

Ejemplo:
```sql
where cast(loaded_at as date) >= (
    select dateadd(day, -1, max(ticket_loaded_date))
    from {{ this }}
)
```

### Sirve cuando:
- hay llegadas tardías
- quieres corregir datos recientes
- usas `merge` o `insert_overwrite`

### Puede dañar cuando:
- usas `append`
- no tienes deduplicación explícita

Regla práctica:
- `append` + lookback = riesgo de duplicados
- `merge` + lookback = razonable si la clave está bien
- `insert_overwrite` + lookback = razonable si reescribes particiones

## 10. Particiones: buenas y malas decisiones
Para `insert_overwrite`, la partición es central.

### Buena práctica
Particionar por una columna derivada y estable, por ejemplo:
```sql
cast(ticket_loaded_at as date) as ticket_loaded_date
```
Y luego:
```sql
partition_by={
    'field': 'ticket_loaded_date',
    'data_type': 'date'
}
```

### Mala práctica común
Particionar por `timestamp` completo:
- demasiada granularidad
- poca eficiencia
- reescritura poco útil

## 11. Alias y filtros incrementales
Error común: usar en `{{ this }}` un nombre de columna que no existe en la tabla final.

Ejemplo:
- en el `select` final renombras `loaded_at as customer_loaded_at`
- luego consultas `max(loaded_at)` desde `{{ this }}`

Eso falla conceptualmente porque `{{ this }}` tiene `customer_loaded_at`, no `loaded_at`.

Regla:
- en el lado fuente usa el nombre fuente disponible en el CTE actual
- en `{{ this }}` usa el nombre final materializado en la tabla

## 12. Patrones recomendados por objetivo

### A. Quiero estado actual de una dimensión
Ejemplo: prioridad actual, customer actual

Suele convenir:
- `table` si el volumen es manejable
- o `incremental` con `merge` si el volumen lo justifica
- `unique_key` por id de negocio

### B. Quiero histórico de cambios o cargas
Ejemplo: producto histórico, ticket histórico

Suele convenir:
- `append` si cada nueva fila debe preservarse y no reprocesas hacia atrás sin deduplicar
- `insert_overwrite` si trabajas por particiones diarias
- snapshot si quieres SCD tipo 2 administrado por dbt

### C. Quiero latest record por entidad
Si usas una macro tipo `get_latest_records(...)`, muchas veces el modelo representa estado actual, no histórico.

Entonces revisa si realmente necesitas incremental.
A veces `table` es más claro que `append`.

## 13. Incremental vs snapshot
No son lo mismo.

### Incremental
- optimiza procesamiento
- tú defines la lógica de cambio
- sirve para facts y dimensiones según diseño

### Snapshot
- pensado para capturar cambios históricos en registros
- útil para SCD tipo 2
- dbt administra vigencias y cambios según estrategia del snapshot

Regla práctica:
- si tu necesidad principal es performance, piensa en incremental
- si tu necesidad principal es historia de atributos, piensa también en snapshot

## 14. Materializaciones relacionadas

### `view`
- simple
- siempre recalcula
- útil para modelos livianos

### `table`
- persiste resultado completo
- simple de razonar
- útil cuando incremental no aporta suficiente valor

### `incremental`
- persiste y actualiza parcialmente
- requiere más diseño

### `ephemeral`
- no crea objeto físico
- se incrusta como CTE en modelos dependientes
- no está relacionado funcionalmente con incremental; solo es otra materialización posible

## 15. Checklist mental para examen o certificación
Antes de aprobar una estrategia incremental, pregúntate:

1. ¿Cuál es el grano exacto del modelo?
2. ¿Quiero estado actual o histórico?
3. ¿Existe una columna confiable para watermark?
4. ¿Necesito inserts solamente, upserts o reemplazo de particiones?
5. ¿La `unique_key` representa el grano real?
6. ¿El lookback window puede duplicar datos?
7. ¿La partición está definida a una granularidad útil?
8. ¿`{{ this }}` usa nombres de columnas finales correctos?
9. ¿Incremental realmente simplifica o complica el modelo?
10. ¿Un `table` o un `snapshot` sería más correcto?

## 16. Errores frecuentes que debes detectar rápido
- usar `append` con lookback y asumir que no duplica
- definir `unique_key` y creer que siempre deduplica
- usar `merge` para un modelo histórico con clave demasiado simple
- particionar por `timestamp` en vez de `date`
- usar en `{{ this }}` columnas con nombre distinto al materializado final
- elegir incremental sin tener watermark confiable
- usar incremental cuando `table` sería más claro
- confundir `is_incremental()` con “estar en prod”

## 17. Resumen ultra corto
- `append`: inserta; no deduplica
- `merge`: upsert; depende de `unique_key`
- `delete+insert`: reemplaza por clave
- `insert_overwrite`: reemplaza particiones
- `is_incremental()`: depende de existencia de `{{ this }}` en el target actual
- `unique_key`: importa sobre todo en estrategias tipo upsert
- histórico y estado actual no se modelan igual
- el grano manda la estrategia

## 18. Frases útiles para recordar
- “La estrategia incremental debe seguir el grano del modelo.”
- “`append` preserva filas; no corrige filas.”
- “`merge` corrige estado actual; no preserva historia por sí solo.”
- “`insert_overwrite` piensa en particiones, no en filas.”
- “`is_incremental()` depende del target actual, no de prod.”
- “Si el lookback reprocesa datos, necesito merge, overwrite o deduplicación.”
