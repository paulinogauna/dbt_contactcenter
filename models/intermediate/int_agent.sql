{{ get_latest_records(
    input_table=ref('stg_dim_agent'),
    partition_by=['agent_id'],
    select_columns=[
        'agent_id',
        'agent_name',
        'agent_email',
        'region_id',
        'hire_date',
        'is_active',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }}
