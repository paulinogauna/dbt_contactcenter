with int_ticket as (
    select * from {{ ref('int_fact_ticket') }}
),
int_customer as (
    select * from {{ ref('int_customer') }}
),
int_account as (
    select * from {{ ref('int_account') }}
),
int_product as (
    select * from {{ ref('int_product') }}
),
int_category as (
    select * from {{ ref('int_category') }}
),
int_region as (
    select * from {{ ref('int_region') }}
),
int_channel as (
    select * from {{ ref('int_channel') }}
),
int_priority as (
    select * from {{ ref('int_priority') }}
),
int_status as (
    select * from {{ ref('int_status') }}
),
int_agent as (
    select * from {{ ref('int_agent') }}
)

select
    ticket_id,
    ticket_customer_id,
    int_customer.customer_name as ticket_customer_name,
    int_customer.customer_email as ticket_customer_email,
    ticket_account_id,
    int_account.account_name as ticket_account_name,
    int_account.account_segment as ticket_account_segment,
    int_account.account_subscription_type as ticket_account_subscription_type,
    ticket_product_id,
    int_product.product_name as ticket_product_name,
    ticket_category_id,
    int_category.category_name as ticket_category_name,
    ticket_region_id,
    int_region.region_name as ticket_region_name,
    ticket_channel_id,
    int_channel.channel_name as ticket_channel_name,
    ticket_priority_id,
    int_priority.priority_name as ticket_priority_name,
    int_priority.priority_level as ticket_priority_level,
    ticket_status_id,
    int_status.status_name as ticket_status_name,
    int_status.is_terminal as ticket_status_is_terminal,
    ticket_agent_id,
    int_agent.agent_name as ticket_agent_name,
    ticket_issue_description,
    ticket_resolution_notes,
    ticket_first_response_time_hours,
    ticket_first_response_time_minutes,
    ticket_first_response_time_seconds,
    ticket_resolution_time_hours,
    ticket_resolution_time_minutes,
    ticket_resolution_time_seconds,
    cast(ticket_created_date as timestamp) as ticket_created_date,
    cast(ticket_resolved_date as timestamp) as ticket_resolved_date,
    ticket_escalated,
    ticket_sla_breached,
    ticket_issue_complexity_score,
    ticket_customer_satisfaction_score,
    ticket_previous_tickets,
    ticket_loaded_at
from int_ticket
left join int_customer on int_ticket.ticket_customer_id = int_customer.customer_id
left join int_account on int_ticket.ticket_account_id = int_account.account_id
left join int_product on int_ticket.ticket_product_id = int_product.product_id
left join int_category on int_ticket.ticket_category_id = int_category.category_id
left join int_region on int_ticket.ticket_region_id = int_region.region_id
left join int_channel on int_ticket.ticket_channel_id = int_channel.channel_id
left join int_priority on int_ticket.ticket_priority_id = int_priority.priority_id
left join int_status on int_ticket.ticket_status_id = int_status.status_id
left join int_agent on int_ticket.ticket_agent_id = int_agent.agent_id
