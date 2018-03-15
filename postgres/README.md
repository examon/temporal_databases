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
