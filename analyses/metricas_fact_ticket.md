# Métricas propuestas para `fact_ticket`

## Objetivo
Este documento reúne propuestas de métricas analíticas que pueden construirse a partir de la tabla de hechos `fact_ticket` y de las dimensiones de la capa `int`, con foco en casos de uso reales de contact center, seguimiento operativo y análisis de desempeño.

No incluye SQL. El objetivo es dejar definidos los enunciados funcionales para una futura implementación analítica en dbt o en una capa de reporting.

---

## 1. Métricas operativas de volumen

### 1.1 Tickets totales por período
Cantidad total de tickets creados por día, semana o mes.

### 1.2 Tickets por canal
Cantidad de tickets distribuidos por canal de entrada, por ejemplo email, chat o teléfono.

### 1.3 Tickets por región
Cantidad de tickets generados por región de la cuenta.

### 1.4 Tickets por categoría y prioridad
Volumen de tickets segmentado por categoría funcional y nivel de prioridad.

### 1.5 Participación porcentual por canal
Porcentaje que representa cada canal sobre el total de tickets del período.

### 1.6 Mix de tickets por segmento de cuenta
Distribución de tickets según segmento comercial de la cuenta.

---

## 2. Métricas de tendencia y evolución

### 2.1 Crecimiento mensual de tickets
Variación absoluta y porcentual del volumen de tickets entre meses consecutivos.

### 2.2 Tendencia móvil de tickets
Promedio móvil de tickets en ventanas de 7, 30 o 90 días para suavizar variaciones puntuales.

### 2.3 Variación semana contra semana por región
Cambio en el volumen de tickets por región respecto de la semana anterior.

### 2.4 Detección de picos operativos
Identificación de períodos con volumen de tickets significativamente superior al comportamiento histórico.

### 2.5 Estacionalidad por día de semana
Análisis de concentración de tickets según día de la semana para detectar patrones operativos.

---

## 3. Métricas de backlog y resolución

### 3.1 Tickets abiertos al cierre
Cantidad de tickets que permanecen abiertos al cierre de cada día, semana o mes.

### 3.2 Tasa de resolución
Porcentaje de tickets resueltos sobre el total de tickets creados o gestionados en un período.

### 3.3 Tiempo promedio de resolución
Tiempo promedio transcurrido entre la creación y la resolución del ticket.

### 3.4 Mediana de tiempo de resolución
Valor central del tiempo de resolución para reducir el efecto de outliers.

### 3.5 Percentil 90 o 95 de resolución
Tiempo por debajo del cual se resuelve el 90% o 95% de los tickets.

### 3.6 Antigüedad del backlog
Tiempo promedio o máximo de permanencia de tickets aún abiertos.

### 3.7 Backlog crítico envejecido
Cantidad de tickets de alta prioridad abiertos por encima de un umbral de antigüedad definido por negocio.

---

## 4. Métricas de SLA y calidad de servicio

### 4.1 Cumplimiento de SLA
Porcentaje de tickets resueltos dentro del tiempo objetivo comprometido.

### 4.2 Incumplimiento de SLA por prioridad
Porcentaje de tickets fuera de SLA segmentado por prioridad.

### 4.3 Cumplimiento de SLA por canal
Comparación del nivel de cumplimiento entre canales de atención.

### 4.4 Brecha promedio contra SLA objetivo
Diferencia promedio entre el tiempo real de resolución y el tiempo objetivo de SLA.

### 4.5 Percentil 95 del tiempo de primera respuesta
Tiempo de primera respuesta en el extremo alto de la distribución para monitorear experiencia de atención.

---

## 5. Métricas de desempeño de agentes

### 5.1 Tickets resueltos por agente
Cantidad de tickets cerrados o resueltos por cada agente en un período.

### 5.2 Tiempo promedio de resolución por agente
Tiempo medio de resolución por agente para comparar productividad.

### 5.3 Cumplimiento de SLA por agente
Porcentaje de tickets del agente resueltos dentro de SLA.

### 5.4 Tasa de reapertura por agente
Porcentaje de tickets que vuelven a abrirse luego de haber sido resueltos por un agente.

### 5.5 Carga activa por agente
Cantidad de tickets abiertos asignados a cada agente en un momento determinado.

### 5.6 Productividad ponderada por complejidad
Indicador que ajusta el volumen resuelto por el peso relativo de prioridad, categoría o severidad.

---

## 6. Métricas de cliente y cuenta

### 6.1 Tickets por cuenta
Cantidad de tickets asociados a cada cuenta en un período.

### 6.2 Frecuencia de contacto por cuenta
Número promedio de tickets por cuenta activa en una ventana temporal.

### 6.3 Recurrencia de incidentes
Cantidad de tickets repetidos o similares para una misma cuenta o cliente dentro de un período.

### 6.4 Tiempo entre tickets consecutivos
Tiempo transcurrido entre un ticket y el siguiente para una misma cuenta.

### 6.5 Cuentas con mayor volumen de tickets críticos
Identificación de cuentas con mayor concentración de tickets de alta prioridad.

### 6.6 Riesgo operativo por cuenta
Indicador compuesto basado en volumen, recurrencia, prioridad e incumplimiento de SLA.

---

## 7. Métricas avanzadas que pueden requerir funciones de ventana

Estas métricas son especialmente útiles para una capa analítica más madura y suelen requerir funciones como `rank`, `dense_rank`, `row_number`, acumulados o percentiles.

### 7.1 Ranking de agentes por tickets resueltos
Ordenar agentes según cantidad de tickets resueltos en un período.

### 7.2 Top 3 agentes por región
Obtener los tres agentes con mejor desempeño dentro de cada región.

### 7.3 Ranking de cuentas por recurrencia
Ordenar cuentas según cantidad de tickets generados o reincidencias en una ventana temporal.

### 7.4 Ranking de categorías con peor tiempo de resolución
Clasificar categorías según su tiempo promedio o mediano de resolución.

### 7.5 Top productos con más tickets críticos
Identificar los productos con mayor volumen de incidencias de alta prioridad.

### 7.6 Canal dominante por región o por mes
Determinar qué canal concentra más tickets dentro de cada región o período.

### 7.7 Último estado conocido por ticket
Seleccionar el estado más reciente de cada ticket cuando exista historial o múltiples eventos.

### 7.8 Última asignación de agente por ticket
Identificar el agente más reciente asociado a cada ticket.

### 7.9 Primer ticket de cada cuenta
Detectar el primer ticket registrado para cada cuenta para análisis de onboarding o inicio de fricción.

### 7.10 Percentil de desempeño de agentes
Ubicar a cada agente dentro de la distribución de desempeño de su región o del total.

---

## 8. Métricas ejecutivas y compuestas

### 8.1 Índice de criticidad operativa
Score compuesto que combine volumen de tickets, prioridad, backlog envejecido e incumplimiento de SLA.

### 8.2 Índice de presión operativa por agente
Métrica que combine tickets abiertos, tickets críticos y antigüedad del backlog asignado.

### 8.3 Índice de fricción del cliente
Indicador basado en recurrencia, reaperturas, demoras y severidad de incidencias.

### 8.4 Concentración del backlog
Porcentaje del backlog total explicado por el top de cuentas, regiones o categorías.

### 8.5 Pareto de causas o categorías
Análisis acumulado para identificar qué categorías explican la mayor parte del volumen o del incumplimiento.

---

## 9. Enunciados funcionales recomendados para priorizar

Si se quiere avanzar con una primera capa de métricas de negocio sobre `fact_ticket`, estas son buenas candidatas iniciales:

1. Ranking mensual de agentes por tickets resueltos.
2. Top 3 agentes por región según cumplimiento de SLA.
3. Cuentas con mayor recurrencia de tickets críticos en los últimos 90 días.
4. Categorías con peor mediana de tiempo de resolución por mes.
5. Backlog abierto y backlog crítico envejecido por región.
6. Cumplimiento de SLA por prioridad, canal y región.
7. Top productos con mayor volumen de incidencias críticas.
8. Participación acumulada de categorías en el total de tickets para análisis Pareto.
9. Percentil de desempeño de cada agente respecto de su región.
10. Índice de riesgo operativo por cuenta.

---

## 10. Posible agrupación para reporting

Estas métricas pueden organizarse en tableros o capas semánticas como:

- **Operación diaria**: volumen, backlog, resolución.
- **Calidad de servicio**: SLA, tiempos, reaperturas.
- **Desempeño de agentes**: productividad, ranking, carga.
- **Cliente y cuenta**: recurrencia, criticidad, riesgo.
- **Vista ejecutiva**: tendencias, concentración, indicadores compuestos.

---

## Nota final
Estas métricas asumen que `fact_ticket` contiene o puede derivar atributos temporales, estado, agente, prioridad, categoría, canal, cuenta, producto y fechas relevantes del ciclo de vida del ticket. Si algunos de estos campos aún no están presentes, los enunciados siguen siendo válidos como backlog funcional para futuras extensiones del modelo.
