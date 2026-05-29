
with source as (

    select * from {{ source('raw', 'dim_account') }}

),

renamed as (

    select
        account_id,
        account_name,
        account_segment,
        subscription_type,
        payment_method,
        region_id,
        loaded_at

    from source

)

select * from renamed


