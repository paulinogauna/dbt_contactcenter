

with source as (

    select * from {{ source('raw', 'dim_channel') }}

),

renamed as (

    select
        channel_id,
        channel_name,
        loaded_at

    from source

)

select * from renamed

