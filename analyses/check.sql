select count(*), min(review_score), max(review_score), count(distinct order_id)
from {{ ref('stg_order_reviews') }}