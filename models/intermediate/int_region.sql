with region as (
    select * from {{ ref('stg_dim_region') }}),
region_actual as (
{{ get_latest_records('region', ['region_id'], ['region_id', 'region_name'], 'loaded_at') }}
)
select * from region_actual