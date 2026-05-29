{{ config(
    severity='warn'
)}}

with closed_tickets as (
    select distinct ticket_id
    from {{ ref('mart_fact_ticket') }} 
    where ticket_status_id in (4, 5)
    ),
open_tickets as (
    select ticket_id
    from {{ ref('mart_fact_ticket') }}
    where ticket_status_id = 1
),
closed_tickets_without_open_status as (
    select cl.ticket_id
    from closed_tickets cl
    left join open_tickets op on op.ticket_id = cl.ticket_id
    where op.ticket_id is null
)
select * from closed_tickets_without_open_status