with date as (
    select explode(sequence(date '2016-09-01', date '2018-12-31', interval 1 day)) as date
)

select
    date,
    year(date)                      as year,
    quarter(date)                   as quarter,
    month(date)                     as month,
    date_format(date, 'MMMM')       as month_name,
    trunc(date, 'MM')               as month_start,
    weekofyear(date)                as week_of_year,
    (dayofweek(date) + 5 ) % 7 + 1  as day_of_week,      -- get Monday = 1
    date_format(date, 'EEEE')       as day_name,
    dayofweek(date) in (1, 7)       as is_weekend
from date