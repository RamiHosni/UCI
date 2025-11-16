--Average time for a store to perform its first 5 transactions
with ranked as (
    select
        ft.store_id,
        ft.happened_at,
        row_number() over(partition by ft.store_id order by to_timestamp(ft.happened_at)) AS row_no --chaging to date to arrange ascending 
    from {{ ref('Fct_Transactions') }}  ft
   
),

first_five as (
    select
        store_id,
        min(case when row_no = 1 then happened_at end) as first_date, -- capture no 1 in ranked 
        max(case when row_no = 5 then happened_at end) as fifth_date --captre no 5 in ranked 
    from ranked
    where row_no <= 5
    group by store_id
    having count(*) = 5
)
select
    round(avg(timestampdiff('day', first_date, fifth_date)), 2) AS avg_days --dates difference in days (rounding 2 decimals)
from first_five