# Login
sudo -s
# password for root...

# switch to postgres
su - postgres

createdb testdb
psql -s testdb

create user testuser password 'test';
grant all privileges on database testdb to testuser;


# get out of root and login
psql -d testdb -U testuser
