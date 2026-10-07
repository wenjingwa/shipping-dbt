-- Singular test: guardrail on the headline metric.
-- In the Olist data roughly 7% of delivered orders arrive after the promised date.
-- If the share jumps above 30%, something upstream broke (date parsing, timezone,
-- a changed definition of is_late), not the business. Fail the build rather than
-- publish a wrong number to Power BI.

with stats as (
    select
        avg(case when is_late then 1 else 0 end) as late_share,
        count(*)                                 as delivered_orders
    from {{ ref('fct_shipments') }}
    where is_delivered
)

select *
from stats
where late_share > 0.30
   or delivered_orders < 50000   -- also fail if most of the data has gone missing
