with int_ticket as (
<<<<<<< HEAD
select * from {{ ref('Mart_fact_ticket') }} ),
=======
select * from {{ ref('mart_fact_ticket') }} ),
>>>>>>> e6b46c2c4a04cefa6a7ed7fc14d14101b205c008

test as (
select count(*) as count_ticket ,
         year(ticket_created_date) as year_ticket,
         ticket_channel_name  
from int_ticket
where ticket_status_id = 4
group by year(ticket_created_date), ticket_channel_name)

select row_number() over (partition by ticket_channel_name order by count_ticket desc) as rn,
    count_ticket,
    year_ticket,
    ticket_channel_name
 from test
 qualify rn = 1