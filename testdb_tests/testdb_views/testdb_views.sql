create or replace view categories_with_history as 
select * from category
union all
select * from category_history;

/*create or replace view categories_products_with_history as 
select * from category_product
union all
select * from category_product_history;*/

create or replace view customers_with_history as 
select * from customer
union all
select * from customer_history;

create or replace view products_with_history as 
select * from product
union all
select * from product_history;

/*create or replace view purchases_with_history as 
select * from purchase
union all
select * from purchase_history;*/