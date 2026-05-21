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
