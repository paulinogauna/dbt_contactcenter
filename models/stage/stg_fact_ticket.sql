

with source as (

    select * from {{ source('raw', 'fact_ticket') }}

),

renamed as (

    select
        ticket_id,
        customer_id,
        account_id,
        product_id,
        category_id,
        region_id,
        channel_id,
        priority_id,
        status_id,
        agent_id,
        issue_description,
        resolution_notes,
        first_response_time_hours,
        resolution_time_hours,
        ticket_created_date,
        ticket_resolved_date,
        escalated,
        sla_breached,
        issue_complexity_score,
        customer_satisfaction_score,
        previous_tickets,
        loaded_at

    from source

)

select * from renamed

