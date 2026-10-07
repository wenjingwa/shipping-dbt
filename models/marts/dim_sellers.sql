with sellers as (
    select * from {{ ref('stg_sellers') }}
),

states as (
    select * from {{ ref('brazil_states') }}
)

select
    se.seller_id,
    se.seller_city,
    se.seller_state,
    s.state_name    as seller_state_name,
    s.region        as seller_region
from sellers se
left join states s on se.seller_state = s.state_code