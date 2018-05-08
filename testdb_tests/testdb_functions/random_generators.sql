-- random generators

create or replace function generate_value(my_table text, my_column text) returns text as $$
declare
my_type text;
begin
select  /*case 
when data_type='character varying' 
then 'varchar('||character_maximum_length||')'
when data_type='numeric' then 'numeric('||numeric_precision||','||numeric_scale||')'
else*/ data_type
--end
from information_schema.columns
where table_schema='public' and table_name=my_table and column_name=my_column and is_updatable='YES' into my_type;

if (my_type like 'character varying') then return (select array_to_string(array(select chr((ascii('a')+round(random()*25))::integer) from generate_series(1,ceil(random()*20)::int)), ''));
elsif (my_type = 'integer') then return round(random()*1000)::integer;
elsif my_type = 'timestamp without time zone' then return current_timestamp::timestamp - random() * (current_timestamp - '1990-01-01 01:01:01'::timestamp);
elsif my_type = 'boolean' then return random() > 0.5;
else raise notice 'not supported';
end if;

end
$$ language plpgsql;

-- updates
create or replace function generate_updates(my_table text, my_column text, size int, my_ids integer[]) returns text as $$
declare
sql text;
var text;
ids text;
id integer;
idtxt text;

begin

if my_ids is null 
then my_ids:= array(select round(random()*1000)::integer from generate_series(1,size));
end if;
ids:=array_to_string(my_ids, ',');
size:=array_length(my_ids,1);
idtxt:='id';
sql:='';

foreach id in array my_ids
loop
if my_table = 'category_product'
then idtxt:='category_id = '||id||' and product_id';
end if;

var:=generate_value(my_table, my_column);
sql:=sql||'update '||my_table||' set '||my_column||' = '''||var||''' where '||idtxt||' = '||id||';';

--'from generate_series(1,'||size||') as generator) '||
end loop; 

return sql;

end
$$ language plpgsql;

create or replace function generate_updates(my_table text, size int) returns text as $$
declare
sql text;
columns text[];

begin
with sub as (select column_name
from information_schema.columns
where table_schema='public' and table_name=my_table and column_name not like 'id' and column_name not like 'sys_period' and table_name not like '%history' and is_updatable='YES'
)
select array_agg(column_name::text) from sub into columns;

return generate_updates(my_table, columns[ceil(random()*array_length(columns,1))], size, null);

end
$$ language plpgsql;

create or replace function generate_updates(size int) returns text as $$
declare
tables text[];
my_table text;
sql text;

begin
with sub as (select table_name
from information_schema.columns
where table_schema='public' and table_name not like '%history' and is_updatable='YES' 
group by table_name
)
select array_agg(table_name::text) from sub into tables;

sql:='';
foreach my_table in array tables -- return table?
loop
sql:=sql||generate_updates(my_table, size);
end loop;
return sql;

end
$$ language plpgsql;

-- inserts
create or replace function generate_inserts(my_table text, size int) returns text as $$
declare
sql text;
columns text[];

begin
with sub as (select column_name
from information_schema.columns
where table_name=my_table and column_name not like 'id' and column_name not like 'sys_period' and table_schema='public' and table_name not like '%history' and is_updatable='YES' 
)
select array_agg(column_name::text) from sub into columns;

sql:='';
for i in 1..size
loop
sql:=sql||'insert into '||my_table||' ('||array_to_string(columns, ',')||') values ('||array_to_string((select array(select ''''||generate_value(my_table, unnest(columns))||'''')),',')||');';

end loop;
return sql;

end
$$ language plpgsql;


create or replace function generate_inserts(size int) returns text as $$
declare
tables text[];
my_table text;
sql text;

begin
with sub as (select table_name
from information_schema.columns
where table_schema='public' and table_name not like '%history' and is_updatable='YES' 
group by table_name
)
select array_agg(table_name::text) from sub into tables;

sql:='';
foreach my_table in array tables
loop
sql:=sql||generate_inserts(my_table, size);
end loop;
return sql;

end
$$ language plpgsql;

-- deletes
create or replace function generate_deletes(my_table text, size int) returns text as $$
declare
sql text;
my_ids integer[];
id integer;

begin
my_ids:= array(select round(random()*1000)::integer from generate_series(1,size));

sql:='';
foreach id in array my_ids
loop
sql:=sql||'DELETE FROM '||my_table|| ' WHERE id = ' || id || ';';

end loop;
return sql;

end
$$ language plpgsql;

create or replace function generate_deletes(size int) returns text as $$
declare
tables text[] := ARRAY['purchase'];
my_table text;
sql text;

begin


sql:='';
foreach my_table in array tables
loop
sql:=sql||generate_deletes(my_table, size);
end loop;
return sql;

end
$$ language plpgsql;
