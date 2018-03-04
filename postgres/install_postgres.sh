# install postgresql on the machine
sudo dnf -y install postgresql-server

# fill the data directory (AKA init-db)
# REMEMBER - here it is: /var/lib/pgsql/data/
sudo postgresql-setup initdb

# Enable postgresql to be started on bootup:
# (I hope it works...)
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl status postgresql
