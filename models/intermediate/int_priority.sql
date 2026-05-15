{{ get_latest_records(
    input_table=ref('stg_dim_priority'),
    partition_by=['priority_id'],
    select_columns=[
        'priority_id',
        'priority_name',
        'priority_level',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }}
