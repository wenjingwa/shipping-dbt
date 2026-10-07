with source as (
    select * from {{ source('olist', 'olist_sellers_dataset') }}
),

final as (
    select
        seller_id,
        seller_zip_code_prefix as seller_zip_code,
        seller_city,
        seller_state
    from source
    where seller_id is not null
)

select * from final