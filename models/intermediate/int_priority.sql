{{ config(
    materialized='incremental',
    unique_key='priority_id',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
) }}

with priority as ({{ get_latest_records(
    input_table=ref('stg_dim_priority'),
    partition_by=['priority_id'],
    select_columns=[
        'priority_id',
        'priority_name',
        'priority_level',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }})
select
    priority_id,
    priority_name,
    priority_level,
    loaded_at as priority_loaded_at
from priority
{% if is_incremental() %}
where loaded_at >= (select dateadd(day, -1, max(priority_loaded_at)) from {{ this }})
{% endif %}
