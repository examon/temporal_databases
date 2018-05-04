/* selects products with data related to purchase times */
select pu.id as purchase_id, pu.date_time as purchase_date_time, pu.customer_id, pu.sys_period as purchase_sys_period,
pr.id as product_id, pr.name as product_name, pr.cost, pr.amount, pr.sys_period as product_sys_period
from purchase pu, 
LATERAL(
select * 
from products prh
) pr
order by pu.id;
