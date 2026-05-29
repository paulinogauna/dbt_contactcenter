

with source as (

    select * from {{ source('raw', 'dim_category') }}

),

renamed as (

    select
        category_id,
        category_name,
        loaded_at

    from source

)

select * from renamed

