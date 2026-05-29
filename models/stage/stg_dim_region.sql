

with source as (

    select * from {{ source('raw', 'dim_region') }}

),

renamed as (

    select
        region_id,
        region_name,
        loaded_at

    from source

)

select * from renamed

