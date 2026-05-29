{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='sync_all_columns'
) }}

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
from stg_dim_customer
{% if is_incremental() %}
where loaded_at >= (select dateadd(day, -1, max(customer_loaded_at)) from {{ this }})
and concat(cast(customer_id as string), '|', cast(loaded_at as string)) 
    not in (select concat(cast(customer_id as string), '|', cast(customer_loaded_at as string)) from {{ this }})
{% endif %}


