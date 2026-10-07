-- One row per order with the full shipping timeline and derived lead times.
-- Grain is order, not item: 97% of orders have one seller, so we collapse items
-- and keep seller_count so the simplification is visible.

with orders as (
    select * from {{ ref('stg_orders') }}
),

-- to get one row per order_id with item information
items as (
    select
        order_id,
        count(*)                    as item_count,
        count(distinct seller_id)   as seller_count,
        min(seller_id)              as seller_id,
        sum(item_price)             as goods_value,
        sum(freight_value)          as freight_value,
        min(shipping_limit_at)      as shipping_limit_at    -- get the earliest ddl any seller had
    from {{ ref('stg_order_items') }}
    group by order_id
),

-- customer dimension
customers as (
    select * from {{ ref('stg_customers') }}
),

-- seller dimension
sellers as (
    select * from {{ ref('stg_sellers') }}
),

-- already transformed to one row per order in staging
reviews as (
    select order_id, review_score from {{ ref('stg_order_reviews') }}
),

joined as (
    select
        o.order_id,
        o.customer_id,
        i.seller_id,
        o.order_status,

        -- to get the timeline
        o.purchased_at,                                -- customer placed the order
        o.approved_at,                                 -- order approved
        o.shipped_at,                                  -- seller handed the package to the carrier
        o.delivered_at,                                -- customer received it
        o.estimated_delivery_date,                     -- estimate delivery date to the customer
        i.shipping_limit_at,                           -- ddl the seller had the ship by
        to_date(o.purchased_at)                                             as purchase_date,

        -- calculate lead time in days
        datediff(o.approved_at, o.purchased_at)                             as lt_approval,
        datediff(o.shipped_at, o.approved_at)                               as lt_seller_handling,
        datediff(o.delivered_at, o.shipped_at)                              as lt_carrier_transit,
        datediff(o.delivered_at, o.purchased_at)                            as lt_total_delivery,
        datediff(o.estimated_delivery_date, o.purchased_at)                 as lt_estimated_delivery,

        -- check if delivered
        o.delivered_at is not null                                          as is_delivered,

        -- check if delivered orders are late. late = delivered date after estimated date
        o.delivered_at is not null
            and to_date(o.delivered_at) > o.estimated_delivery_date         as is_late,
        
        -- calculate earlier or late delivery and how many days. null = not delivered
        case when o.delivered_at is not null
             then datediff(to_date(o.delivered_at), o.estimated_delivery_date) end as days_vs_estimate,
        
        -- check if seller missed the ddl
        o.shipped_at > i.shipping_limit_at                                  as seller_missed_ddl,

        -- check states
        c.customer_state,
        s.seller_state,
        c.customer_state = s.seller_state                                   as is_same_state,

        -- order economics
        i.item_count,
        i.seller_count,
        i.goods_value,
        i.freight_value,
        -- calculate freight as a share of goods value: shipping costs on top of the product price
        case when i.goods_value > 0 then i.freight_value / i.goods_value end as freight_ratio,

        r.review_score

    from orders o
    inner join items     i on o.order_id = i.order_id
    left  join customers c on o.customer_id = c.customer_id
    left  join sellers   s on i.seller_id = s.seller_id
    left  join reviews   r on o.order_id = r.order_id
)

select * from joined