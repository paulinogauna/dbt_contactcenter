with customer as ({{ get_latest_records(
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
) }})
select
    customer_id,
    account_id as customer_account_id,
    customer_name,
    customer_email,
    customer_age,
    customer_gender,
    customer_tenure_months,
    language as customer_language,
    preferred_contact_time as customer_preferred_contact_time,  
    operating_system as customer_operating_system,
    browser as customer_browser,    
    loaded_at as customer_loaded_at
from customer


