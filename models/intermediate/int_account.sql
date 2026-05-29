{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='account_id',
    on_schema_change='sync_all_columns'
) }}

with account as (
    {{ get_latest_records(
    input_table=ref('stg_dim_account'),
    partition_by=['account_id'],
    select_columns=[
        'account_id',
        'account_name',
        'account_segment',
        'subscription_type',
        'payment_method',
        'region_id' , 
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }}
)
select
    account_id,
    account_name,
    account_segment,
    subscription_type as account_subscription_type,
    payment_method as account_payment_method,
    region_id as account_region_id,
    loaded_at as account_loaded_at
from account
{% if is_incremental() %}
where loaded_at >= (select dateadd(day, -1, max(account_loaded_at)) from {{ this }})
{% endif %}