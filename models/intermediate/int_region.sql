

with region as (

    select * from {{ ref('stg_dim_region') }}

)
select group_region as (

    select region_id,
        region_name,
        row_number() over (partition by region_id order by loaded_at desc) as rn
        from region)

select get_latest_records('group_region', ['region_id'], ['region_id', 'region_name'], 'loaded_at')
 
           

