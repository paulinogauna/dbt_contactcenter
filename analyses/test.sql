with int_ticket as (
select * from {{ ref('Mart_fact_ticket') }} )
select sum(ticket_id) as sum_ticket , year(ticket_created_date) as year_ticket, ticket_channel_name  
from int_ticket
where ticket_status_id = 4
group by year(ticket_created_date), ticket_channel_name