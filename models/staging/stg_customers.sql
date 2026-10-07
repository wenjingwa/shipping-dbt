with source as (
    select * from {{ source('olist', 'olist_customers_dataset') }}
),

final as (
    select
        customer_id,
        customer_unique_id, 
        customer_zip_code_prefix as customer_zip_code,
        customer_city,
        customer_state
    from source
    where customer_id is not null
)

select * from final