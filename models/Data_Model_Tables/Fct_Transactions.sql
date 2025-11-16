-- Creating the fact table for the model
select 

t.id,
t.device_id,
t.product_sku,
t.product_name,
t.category_name,
t.amount,
t.status,
concat('**** **** **** ', right(t.card_number, 4)) as card_number, -- anonymize senstive data 
concat('** ',right(t.cvv, 1)) as cvv, -- anonymize senstive data 
t.created_at,
t.happened_at,
d.store_id
from
transactions t
join devices d on d.id = t.device_id

