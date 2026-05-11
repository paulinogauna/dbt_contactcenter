

with source as (

    select * from {{ source('raw', 'dim_customer') }}

),

renamed as (

    select
        customer_id,
        account_id,
        customer_name,
        customer_email,
        customer_age,
        customer_gender,
        customer_tenure_months,
        language,
        preferred_contact_time,
        operating_system,
        browser,
        loaded_at

    from source

)

select * from renamed

