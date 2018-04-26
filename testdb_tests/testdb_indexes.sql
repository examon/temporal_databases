create index on category using gist(sys_period);
create index on category_history using gist(sys_period);

create index on category_product using gist(sys_period);
/*create index on category_product_history using gist(sys_period);*/

create index on customer using gist(sys_period);
create index on customer_history using gist(sys_period);

create index on product using gist(sys_period);
create index on product_history using gist(sys_period);

create index on purchase using gist(sys_period);
/*create index on purchase_history using gist(sys_period);*/