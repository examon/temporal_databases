@echo off
REM Copyright (c) 2012-2015, EnterpriseDB Corporation.  All rights reserved

REM PostgreSQL server psql runner script for Windows

SET server=localhost
SET database=testdb_history
SET port=5432
SET username=testuser
SET PGPASSWORD=test

for /f "delims=" %%a in ('chcp ^|find /c "932"') do @ SET CLIENTENCODING_JP=%%a
if "%CLIENTENCODING_JP%"=="1" SET PGCLIENTENCODING=SJIS
if "%CLIENTENCODING_JP%"=="1" SET /P PGCLIENTENCODING="Client Encoding [%PGCLIENTENCODING%]: "


REM Run psql, -W force authentication, -c command, -f file
setlocal EnableDelayedExpansion

SET "home=."

SET /p "itrs=How many iterations? "
set "output=%home%\testdb_test_results\test_results_%itrs%.csv"
break > !output!

for %%f in (%home%\testdb_test_queries\*) do (
set query=%%~nxf
set "input=%%f"
rem set /p query=<!input!

set "sql="
for /f "tokens=1 delims=" %%x in (!input!) do (
set "sql=!sql! %%x"
)
set "sql=!sql:'=''!"

for /l %%i in (1,1,%itrs%) do (
rem net stop postgresql-x64-9.4 & net start postgresql-x64-9.4
rem "%POSTGRES_HOME%\bin\psql.exe" -h %server% -U %username% -d %database% -p %port% -c "deallocate all"
rem "%POSTGRES_HOME%\bin\psql.exe" -h %server% -U %username% -d %database% -p %port% -c "discard all"
"%POSTGRES_HOME%\bin\psql.exe" -h %server% -U %username% -d %database% -p %port% -c "COPY (select '!query!' as query, %%i as iteration, * from measure_exec_time('!sql!')) TO STDOUT WITH CSV " >> !output!
)
)

pause

