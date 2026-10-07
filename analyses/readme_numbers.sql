-- Queries behind the README findings. Preview each block in dbt Studio.

-- 1. Headline late share and medians
select
    count(*)                                                as delivered_orders,
    round(avg(case when is_late then 1 else 0 end), 3)      as late_share,
    percentile(lt_total_delivery, 0.5)                      as median_total_days,
    percentile(lt_seller_handling, 0.5)                     as median_seller_days,
    percentile(lt_carrier_transit, 0.5)                     as median_carrier_days,
    percentile(lt_estimated_delivery, 0.5)                  as median_promised_days,
    round(avg(case when seller_count = 1 then 1 else 0 end), 3) as single_seller_share
from {{ ref('fct_shipments') }}
where is_delivered;

-- 2. Late share by month (best and worst month)
select
    trunc(purchase_date, 'MM')                              as month,
    count(*)                                                as orders,
    round(avg(case when is_late then 1 else 0 end), 3)      as late_share
from {{ ref('fct_shipments') }}
where is_delivered
group by 1
order by 1;

-- 3. Worst routes with at least 100 orders
select
    seller_state,
    customer_state,
    count(*)                                                as orders,
    round(avg(case when is_late then 1 else 0 end), 3)      as late_share,
    percentile(lt_total_delivery, 0.5)                      as median_days
from {{ ref('fct_shipments') }}
where is_delivered
group by 1, 2
having count(*) >= 100
order by late_share desc
limit 10;

-- 4. Same state vs cross state
select
    is_same_state,
    count(*)                                                as orders,
    round(avg(case when is_late then 1 else 0 end), 3)      as late_share,
    percentile(lt_total_delivery, 0.5)                      as median_days
from {{ ref('fct_shipments') }}
where is_delivered
group by 1;

-- 5. Review score, late vs on time
select
    is_late,
    count(*)                                                as orders,
    round(avg(review_score), 2)                             as avg_review,
    round(avg(case when review_score = 1 then 1 else 0 end), 3) as one_star_share
from {{ ref('fct_shipments') }}
where is_delivered and review_score is not null
group by 1;
