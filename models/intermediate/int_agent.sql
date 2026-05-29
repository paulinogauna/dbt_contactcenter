{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='agent_id',
    on_schema_change='sync_all_columns'
) }}

with agent as ({{ get_latest_records(
    input_table=ref('stg_dim_agent'),
    partition_by=['agent_id'],
    select_columns=[
        'agent_id',
        'agent_name',
        'agent_email',
        'region_id',
        'hire_date',
        'is_active',
        'loaded_at'
    ],
    order_by_column='loaded_at'
) }})
select
    agent_id,
    agent_name,
    agent_email,
    region_id as agent_region_id,
    hire_date as agent_hire_date,
    is_active as agent_is_active,
    loaded_at as agent_loaded_at
from agent
{% if is_incremental() %}
where loaded_at >= (select dateadd(day, -1, max(agent_loaded_at)) from {{ this }})
{% endif %}
