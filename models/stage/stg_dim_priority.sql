

with source as (

    select * from {{ source('raw', 'dim_priority') }}

),

renamed as (

    select
        priority_id,
        priority_name,
        priority_level,
        loaded_at

    from source

)

select * from renamed

