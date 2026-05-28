{{config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={
        'field': 'product_loaded_date',
        'data_type': 'date'
    },
    on_schema_change='sync_all_columns'
)}}

select
    product_id,
    product_name,
    loaded_at as product_loaded_at,
    cast(loaded_at as date) as product_loaded_date
from {{ref('stg_dim_product')}}
{% if is_incremental() %}
where loaded_at >= (select 
    dateadd(day, -1, max(product_loaded_date)) from {{ this }})
{% endif %}
