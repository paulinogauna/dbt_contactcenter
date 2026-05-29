{% macro get_latest_records(input_table, partition_by, select_columns, order_by_column) %}
    with actual_records as (

        select
            {{ select_columns | join(',\n            ') }},
            row_number() over (
                partition by {{ partition_by | join(', ') }}
                order by {{ order_by_column }} desc
            ) as rn
        from {{ input_table }}

    )

    select
        {{ select_columns | join(',\n        ') }}
    from actual_records
    where rn = 1
{% endmacro %}
