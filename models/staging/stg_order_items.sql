with source as (
    select * from {{ source('olist', 'olist_order_items_dataset') }}
),

final as (
    select
        order_id,
        order_item_id, 
        product_id,
        seller_id,
        try_cast(shipping_limit_date as timestamp) as shipping_limit_at,
        cast(price as decimal(10,2)) as item_price,
        cast(freight_value as decimal(10,2)) as freight_value
    from source
    where order_id is not null
)

select * from final