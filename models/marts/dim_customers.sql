with customers as (
    select * from {{ ref('stg_customers') }}
),

states as (
    select * from {{ ref('brazil_states') }}
)

select
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    s.state_name    as customer_state_name,
    s.region        as customer_region
from customers c
left join states s on c.customer_state = s.state_code