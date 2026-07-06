{% set payment_methods_query %}
    select distinct account_payment_method
    from {{ ref('int_account') }}
    where account_payment_method is not null
{% endset %}

{% set payment_methods_result = run_query(payment_methods_query) %}
{% set payment_methods = [] %}

{% if execute and payment_methods_result is not none %}
    {% set payment_methods = payment_methods_result.columns[0].values() %}
{% endif %}

with account_totals as (
    select
        account_payment_method,
        count(*) as total_accounts
    from {{ ref('int_account') }}
    group by account_payment_method
)

select
    {% for payment_method in payment_methods %}
    sum(
        case
            when account_payment_method = '{{ payment_method }}' then total_accounts
            else 0
        end
    ) as {{ payment_method | lower | replace(' ', '_') | replace('-', '_') }}_total{% if not loop.last %},{% endif %}
    {% endfor %}
from account_totals