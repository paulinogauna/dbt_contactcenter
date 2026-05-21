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