with product as ({{ get_latest_records(
    input_table=ref('stg_dim_product'),
    partition_by=['product_id'],
    select_columns=[
        'product_id',
        'product_name',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }})
select
    product_id,
    product_name,
    loaded_at as product_loaded_at
from product
