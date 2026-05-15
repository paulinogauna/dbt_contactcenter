{{ get_latest_records(
    input_table=ref('stg_dim_account'),
    partition_by=['account_id'],
    select_columns=[
        'account_id',
        'account_name',
        'account_segment',
        'subscription_type',
        'payment_method',
        'region_id',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }}
