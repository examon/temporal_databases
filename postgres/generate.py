#!/usr/bin/env python3

import utils

DBNAME = "testdb"
USER = "testuser"
PASSWORD = "test"

utils.init(DBNAME, USER, PASSWORD)


## Create model and history tables
utils.drop_all_user_tables(USER)
utils.execute_from_file("model.sql")
tables = utils.get_all_user_tables(USER)
for t in tables:
    table = t[0]
    utils.table_attach_history(table)
    utils.create_history_table(table)
print(utils.get_all_user_tables(USER))


## Populate tables
"""
INSERT INTO category (name) VALUES ('test');
INSERT INTO product (name, cost, amount) VALUES ('penezenka', 1,20);
INSERT INTO category_product (category_id, product_id) VALUES (1,1);
INSERT INTO customer (name, email, password, active) VALUES ('Jan Hrozný', 'jan.hrozny@email.cz', 'heslo_jan_2', true);
INSERT INTO purchase (date_time, customer_id, product_id) VALUES (NOW(), 1 ,1 );
"""

## category
print("generating: category")
CATEGORY_ROWS = 1000
for i in range(CATEGORY_ROWS):
    # TODO: sys_period
    category_name = utils.get_random_string()
    utils.execute("""INSERT INTO category (name) VALUES ('{CATEGORY_NAME}');""".format(CATEGORY_NAME=category_name))
# TODO: history

## product
print("generating: product")
PRODUCT_ROWS = 1000
for i in range(PRODUCT_ROWS):
    # TODO: sys_period
    product_name = utils.get_random_string()
    product_cost = utils.get_random_number(0, 1000)
    product_amount = utils.get_random_number(0, 10000)
    utils.execute("""INSERT INTO product (name, cost, amount) VALUES ('{PRODUCT_NAME}', {PRODUCT_COST}, {PRODUCT_AMOUNT});""".format(
        PRODUCT_NAME=product_name, PRODUCT_COST=product_cost, PRODUCT_AMOUNT=product_amount))
# TODO: history

## customer
print("generating: customer")
CUSTOMER_ROWS = 1000
for i in range(CUSTOMER_ROWS):
    # TODO: sys_period
    customr_name = utils.get_random_string()
    customer_email = utils.get_random_string()
    customer_password = utils.get_random_string()
    customer_active = utils.get_random_boolean()
    utils.execute("""INSERT INTO customer (name, email, password, active) VALUES ('{CUSTOMER_NAME}', '{CUSTOMER_EMAIL}', '{CUSTOMER_PASSWORD}', '{CUSTOMER_ACTIVE}');""".format(
        CUSTOMER_NAME=customr_name, CUSTOMER_EMAIL=customer_email, CUSTOMER_PASSWORD=customer_password, CUSTOMER_ACTIVE=customer_active))
# TODO: history

## category_product
print("generating: category_product")
CATEGORY_PRODUCT_ROWS = 1000
for i in range(CATEGORY_PRODUCT_ROWS):
    # TODO: sys_period
    category_product_customer_id = 1 # TODO: some customer id
    category_product_product_id = 1 # TODO: some product id
    utils.execute("""INSERT INTO purchase (date_time, customer_id, product_id) VALUES (NOW(), {CATEGORY_PRODUCT_CUSTOMER_ID}, {CATEGORY_PRODUCT_PRODUCT_ID});""".format(
        CATEGORY_PRODUCT_CUSTOMER_ID=category_product_customer_id, CATEGORY_PRODUCT_PRODUCT_ID=category_product_product_id))
# TODO: history

## purchase
print("generating: purchase")
PURCHASE_ROWS = 1000
for i in range(PURCHASE_ROWS):
    # TODO: sys_period
    purchase_customer_id = 1 # TODO: some customer id
    purchase_product_id = 1 # TODO: some product id
    utils.execute("""INSERT INTO purchase (date_time, customer_id, product_id) VALUES (NOW(), {PURCHASE_CUSTOMER_ID}, {PURCHASE_PRODUCT_ID});""".format(
        PURCHASE_CUSTOMER_ID=purchase_customer_id, PURCHASE_PRODUCT_ID=purchase_product_id))
# TODO: history






"""
NUM_ROWS = 10000
TABLE = "test_history"
for i in range(NUM_ROWS):
    name = utils.get_random_string()
    time_start, time_end = utils.get_random_tstzrange()
    utils.insert_history(TABLE, name, time_start, time_end)
print(utils.count_rows("test_history"))
"""
