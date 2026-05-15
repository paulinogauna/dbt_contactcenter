{{ get_latest_records(
    input_table=ref('stg_dim_channel'),
    partition_by=['channel_id'],
    select_columns=[
        'channel_id',
        'channel_name',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }}
