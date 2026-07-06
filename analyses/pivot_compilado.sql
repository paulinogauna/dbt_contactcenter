with account_totals as (
    select
        account_payment_method,
        count(*) as total_accounts
    from int_account
    group by account_payment_method
)

select
    sum(
        case
            when account_payment_method = 'credit_card' then total_accounts
            else 0
        end
    ) as credit_card_total,
    sum(
        case
            when account_payment_method = 'bank_transfer' then total_accounts
            else 0
        end
    ) as bank_transfer_total,
    sum(
        case
            when account_payment_method = 'paypal' then total_accounts
            else 0
        end
    ) as paypal_total
from account_totals;
