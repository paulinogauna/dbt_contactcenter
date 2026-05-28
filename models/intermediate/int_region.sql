{{config(materialized='incremental',
    unique_key='region_id',
    incremental_strategy='delete+insert',
    on_schema_change='sync_all_columns')}}

with region as (
{{ get_latest_records(
    input_table=ref('stg_dim_region'),
    partition_by=['region_id'],
    select_columns=[
        'region_id',
        'region_name',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }})
select
    region_id,
    region_name,
    loaded_at as region_loaded_at
from region
{% if is_incremental() %}
    where loaded_at >= (select 
    dateadd(day, -1, max(region_loaded_at)) from {{ this }})
{% endif %}