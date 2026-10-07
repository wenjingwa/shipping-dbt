with source as (
    select * from {{ source('olist', 'olist_order_reviews_dataset') }}
),

cleaned as (
    select
        review_id,
        order_id,
        cast(review_score as integer) as review_score,
        review_comment_title, 
        review_comment_message,
        try_cast(review_creation_date as date) as review_created_at,
        try_cast(review_answer_timestamp as timestamp) as review_answered_at
    from source
    where review_id is not null
),

-- some orders have more than one review; keep the latest so the join to orders stays 1:1
ranked as (
    select 
        *,
        row_number() over (partition by order_id order by review_created_at desc) as review_rank
    from cleaned
)

-- leave out the review_rank column from the output
select * except (review_rank) from ranked where review_rank = 1


-- this CSV was split on every line break, including the ones inside review comments.
-- so this query has been run in my Databricks warehouse
-- create or replace table raw.olist_shipping.olist_order_reviews_dataset as
-- select *
-- from read_files(
--   '/Volumes/raw/olist_shipping/landing/olist_order_reviews_dataset.csv',
--   format => 'csv',
--   header => true,
--   multiLine => true,
--   escape => '"',
--   schemaEvolutionMode => 'none',
--   inferSchema => false
-- );
