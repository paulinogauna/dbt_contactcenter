with status as ({{ get_latest_records(
    input_table=ref('stg_dim_status'),
    partition_by=['status_id'],
    select_columns=[
        'status_id',
        'status_name',
        'is_terminal',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }})
select
    status_id,
    status_name,
    is_terminal,
    loaded_at as status_loaded_at
from status
