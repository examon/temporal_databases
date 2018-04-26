create or replace function measure_exec_time(sql_txt varchar(2000), out "elapsed_time [ms]" real) as $$ 
declare
t0 timestamptz;
t1 timestamptz;

begin
CHECKPOINT; --DBCC DROPCLEANBUFFERS; DBCC FREEPROCCACHE; v sql 2016
t0 := clock_timestamp();
execute sql_txt;-- queries
t1 := clock_timestamp();
"elapsed_time [ms]" := 1000*(extract(epoch from t1)-extract(epoch from t0));
end;

$$ language plpgsql;