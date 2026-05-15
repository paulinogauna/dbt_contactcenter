{{ get_latest_records(
    input_table=ref('stg_dim_customer'),
    partition_by=['customer_id'],
    select_columns=[
        'customer_id',
        'account_id',
        'customer_name',
        'customer_email',
        'customer_age',
        'customer_gender',
        'customer_tenure_months',
        'language',
        'preferred_contact_time',
        'operating_system',
        'browser',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }}
