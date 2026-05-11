

with source as (

    select * from {{ source('raw', 'dim_status') }}

),

renamed as (

    select
        status_id,
        status_name,
        is_terminal,
        loaded_at

    from source

)

select * from renamed

