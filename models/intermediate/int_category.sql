{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='category_id',
    on_schema_change='sync_all_columns'
) }}

with category as ({{ get_latest_records(
    input_table=ref('stg_dim_category'),
    partition_by=['category_id'],
    select_columns=[
        'category_id',
        'category_name',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }})
select
    category_id,
    category_name,
    loaded_at as category_loaded_at
from category
{% if is_incremental() %}
where loaded_at >= (select dateadd(day, -1, max(category_loaded_at)) from {{ this }})
{% endif %}
