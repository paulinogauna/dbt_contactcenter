{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={
        'field': 'ticket_created_date',
        'data_type': 'date'
    },
    on_schema_change='sync_all_columns'
) }}

with stg_ticket as (
    select * from {{ ref('stg_fact_ticket') }}
)

select
    ticket_id,
    customer_id as ticket_customer_id,
    account_id as ticket_account_id,
    product_id as ticket_product_id,
    category_id as ticket_category_id,
    region_id as ticket_region_id,
    channel_id as ticket_channel_id,
    priority_id as ticket_priority_id,
    status_id as ticket_status_id,
    agent_id as ticket_agent_id,
    issue_description as ticket_issue_description,
    resolution_notes as ticket_resolution_notes,
    first_response_time_hours as ticket_first_response_time_hours,
    first_response_time_hours * 60 as ticket_first_response_time_minutes,
    first_response_time_hours * 3600 as ticket_first_response_time_seconds,
    resolution_time_hours as ticket_resolution_time_hours,
    resolution_time_hours * 60 as ticket_resolution_time_minutes,
    resolution_time_hours * 3600 as ticket_resolution_time_seconds,
    ticket_created_date as ticket_created_date,
    ticket_resolved_date as ticket_resolved_date,
    escalated as ticket_escalated,
    sla_breached as ticket_sla_breached,
    issue_complexity_score as ticket_issue_complexity_score,
    customer_satisfaction_score as ticket_customer_satisfaction_score,
    previous_tickets as ticket_previous_tickets,
    loaded_at as ticket_loaded_at,
    cast(loaded_at as date) as ticket_loaded_date
from stg_ticket
{% if is_incremental() %}
where cast(loaded_at as date)  >= (select dateadd(day, -1, max(ticket_loaded_date)) from {{ this }})
{% endif %}
