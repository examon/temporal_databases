#!/bin/bash

echo Database testing
# psql args
POSTGRES_HOME="/usr/bin/psql"
server=localhost
database=testdb
database_hist=testdb_history
port=5432
username=testuser
PGPASSWORD=test
# prompt timeout
timeout=5
# dirs
home="$HOME/Documents/temporal_databases/testdb_tests"
inputdir="$home/testdb_test_queries"
outputdir="$home/testdb_test_results"

echo How many iterations? 
read itrs
output="$outputdir/test_results_$itrs.csv"

echo
read -t $timeout -r -n 1 -p "${1:-Clear '$output'?} [y/n]: " prompt
if [[ $prompt = "y" || $prompt = "Y" || $prompt = "" ]]; then 
> $output
echo $'\n'$output cleared
fi

# selects
echo
read -t $timeout -r -n 1 -p "${1:-Run selects?} [y/n]: " prompt
if [[ $prompt = "y" || $prompt = "Y" || $prompt = "" ]]; then
echo $'\n'selects on $database and $database_hist
for input in $inputdir/ts_* # regex
do
query=${input##*/}
query=${query%%.*}
sql="$(<"$input")"
sql=${sql//\'/\'\'}
for itr in $(seq $itrs)
do
"$POSTGRES_HOME" -h $server -U $username -d $database -p $port -c "COPY (select '$database' as database, 'select' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$sql')) TO STDOUT WITH CSV" >> $output
"$POSTGRES_HOME" -h $server -U $username -d $database_hist -p $port -c "COPY (select '$database_hist' as database, 'select history' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$sql')) TO STDOUT WITH CSV" >> $output
done
done
fi

echo
read -t $timeout -r -n 1 -p "${1:-Run selects with history?} [y/n]: " prompt
if [[ $prompt = "y" || $prompt = "Y" || $prompt = "" ]]; then
echo $'\n'selects on database_hist
for input in $inputdir/thsh_*
do
query=${input##*/}
query=${query%%.*}
sql="$(<"$input")"
sql=${sql//\'/\'\'}
for itr in $(seq $itrs)
do
"$POSTGRES_HOME" -h $server -U $username -d $database_hist -p $port -c "COPY (select '$database_hist' as database, 'select history' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$sql')) TO STDOUT WITH CSV" >> $output
done
done
fi

# inserts
echo
read -t $timeout -r -n 1 -p "${1:-Run inserts?} [y/n]: " prompt
if [[ $prompt = "y" || $prompt = "Y" || $prompt = "" ]]; then
echo $'\n'inserts on $database and $database_hist
insertin="$inputdir/ti_inserts.txt"
> $insertin
chmod a+w $insertin
"$POSTGRES_HOME" -h $server -U $username -d $database -p $port -c "COPY (select * from generate_inserts($itrs)) TO '$insertin' (format text)"

itr=1
sql="$(<"$insertin")"
sql=${sql//\'/\'\'}
IFS='\;'
for input in $sql
do
sqlexec="'$input;'"
query=`expr "$input" : '.*\(insert[ ]into[ ]*[a-zA-Z_]*\)'`

"$POSTGRES_HOME" -h $server -U $username -d $database -p $port -c "COPY (select '$database' as database, 'insert' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$input;')) TO STDOUT WITH CSV" >> $output
"$POSTGRES_HOME" -h $server -U $username -d $database_hist -p $port -c "COPY (select '$database_hist' as database, 'insert' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$input;')) TO STDOUT WITH CSV" >> $output

itr=$(($itr%$itrs +1))
done
fi

# updates
echo
read -t $timeout -r -n 1 -p "${1:-Run updates?} [y/n]: " prompt
if [[ $prompt = "y" || $prompt = "Y" || $prompt = "" ]]; then
echo $'\n'updates on $database and $database_hist
updatein="$inputdir/tu_updates.txt"
> $updatein
chmod a+w $updatein
"$POSTGRES_HOME" -h $server -U $username -d $database -p $port -c "COPY (select * from generate_updates($itrs)) TO '$updatein' (format text)"

itr=1
sql="$(<"$updatein")"
sql=${sql//\'/\'\'}
IFS='\;'
for input in $sql
do
sqlexec="'$input;'"
query=`expr "$input" : '.*\(update[ ]*[a-zA-Z_]*\)'`

"$POSTGRES_HOME" -h $server -U $username -d $database -p $port -c "COPY (select '$database' as database, 'update' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$input;')) TO STDOUT WITH CSV" >> $output
"$POSTGRES_HOME" -h $server -U $username -d $database_hist -p $port -c "COPY (select '$database_hist' as database, 'update' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$input;')) TO STDOUT WITH CSV" >> $output

itr=$(($itr%$itrs +1))
done
fi

# deletes

echo
read -t $timeout -r -n 1 -p "${1:-Run deletes?} [y/n]: " prompt
if [[ $prompt = "y" || $prompt = "Y" || $prompt = "" ]]; then
echo $'\n'deletes on $database and $database_hist
deletein="$inputdir/td_deletes.txt"
> $deletein
chmod a+w $deletein
"$POSTGRES_HOME" -h $server -U $username -d $database -p $port -c "COPY (select * from generate_deletes($itrs)) TO '$deletein' (format text)"



itr=1
sql="$(<"$deletein")"
sql=${sql//\'/\'\'}
IFS='\;'
for input in $sql
do
sqlexec="'$input;'"
query=`expr "$input" : '.*\(DELETE[ ]FROM[ ]*[a-zA-Z_]*\)'`

"$POSTGRES_HOME" -h $server -U $username -d $database -p $port -c "COPY (select '$database' as database, 'delete' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$input;')) TO STDOUT WITH CSV" >> $output
"$POSTGRES_HOME" -h $server -U $username -d $database_hist -p $port -c "COPY (select '$database_hist' as database, 'delete' as category, '$query' as query, $itr as iteration, * from measure_exec_time('$input;')) TO STDOUT WITH CSV" >> $output

itr=$(($itr%$itrs +1))
done
fi


echo
echo $'\n'results in $output
