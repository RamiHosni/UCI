--Top 10 products sold

select top 10 product_sku, count(product_sku) sold_products
from
{{ ref('Fct_Transactions') }} 
where status = 'accepted' and product_sku is not null--assuming it is sold if payment status is accepted 
group by product_sku
order by sold_products desc
