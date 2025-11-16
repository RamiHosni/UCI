select s.country, s.typology, round(avg(ft.amount),2) as amount 

from

{{ ref('Dim_Stores') }} s 
left join {{ ref('Fct_Transactions') }}  ft 
on s.id = ft.store_id

where ft.status = 'accepted'

group by s.country, s.typology 
order by amount desc