create or replace rule ignore_insert_violation as on insert to category 
where exists (select 1 from category where id = new.id) do instead nothing;

create or replace rule ignore_insert_violation as on insert to category_product 
where not exists (select 1 from category_product cp join category c on new.category_id = c.id join product p on new.product_id = p.id) 
or exists (select 1 from category_product where product_id = new.product_id and category_id = new.category_id) do instead nothing;
create or replace rule ignore_update_violation as on update to category_product 
where not exists (select 1 from category_product cp join category c on new.category_id = c.id join product p on new.product_id = p.id) 
or exists (select 1 from category_product where product_id = new.product_id and category_id = new.category_id) do instead nothing;

create or replace rule ignore_insert_violation as on insert to customer 
where exists (select 1 from customer where id = new.id) do instead nothing;

create or replace rule ignore_insert_violation as on insert to product 
where exists (select 1 from product where id = new.id) do instead nothing;

create or replace rule ignore_insert_violation as on insert to purchase 
where not exists (select 1 from purchase pu join customer c on new.customer_id = c.id join product p on new.product_id = p.id) 
or exists (select 1 from purchase where id = new.id) do instead nothing;
create or replace rule ignore_update_violation as on update to purchase 
where not exists (select 1 from purchase pu join customer c on new.customer_id = c.id join product p on new.product_id = p.id) 
or exists (select 1 from purchase where id = new.id) do instead nothing;
