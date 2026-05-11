

with source as (

    select * from {{ source('raw', 'dim_agent') }}

),

renamed as (

    select
        agent_id,
        agent_name,
        agent_email,
        region_id,
        hire_date,
        is_active,
        loaded_at

    from source

)

select * from renamed

