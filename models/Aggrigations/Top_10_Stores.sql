select top 10 s.id, s.name, sum(t.amount) as profit
from {{ ref('Dim_Stores') }} s
left join {{ ref('Fct_Transactions') }} t on  s.id = t.store_id 
where status = 'accepted'
group by s.id, s.name
order by profit desc