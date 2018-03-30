# Create db, user and grant admin/superuser access
``` bash
sudo -s
su - postgres
createdb testdb
psql -s testdb
```

# In psql shell
``` sql
create user testuser password 'test';
grant all privileges on database testdb to testuser;
alter user testuser with superuser;
```

# Get out of root and login as a testuser
``` bash
psql -d testdb -U testuser
```

# Dump and Restore DB

https://www.postgresql.org/docs/9.1/static/backup-dump.html

To dump:

``` bash
pg_dump -U testuser testdb > testdb.dump
```

type password `test`.

Before restoring database from `testdb.dump`, create new database `new_testdb`:

``` bash
sudo -s
su - postgres
createdb new_testdb
```

Get out of the root shell.

psql -U testuser new_testdb < testdb.dump
