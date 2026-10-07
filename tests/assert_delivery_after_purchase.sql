-- Singular test: a delivered order cannot have been delivered before it was purchased.
-- dbt treats every returned row as a failure, so this must return zero rows.
-- Catches swapped timestamp columns or a bad cast upstream.

select
    order_id,
    purchased_at,
    delivered_at
from {{ ref('fct_shipments') }}
where delivered_at < purchased_at
