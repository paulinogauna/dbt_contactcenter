

with source as (

    select * from {{ source('raw', 'dim_product') }}

),

renamed as (

    select
        product_id,
        product_name,
        loaded_at

    from source

)

select * from renamed

