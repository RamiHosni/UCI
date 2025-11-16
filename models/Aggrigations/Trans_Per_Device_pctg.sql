-- Percentage of transactions per device type
select
    d.type as Device_type,
    count(t.id) AS Number_Of_Transactions,
    Round (100 * Number_Of_Transactions / sum(Number_Of_Transactions) over (), 2)  AS Percentage -- using over to sum all rows 
from {{ ref('Dim_Devices') }} d
left join {{ ref('Fct_Transactions') }} t ON d.id = t.device_id
group by d.type
order by Number_Of_Transactions DESC