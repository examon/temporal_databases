#!/usr/bin/env python3

"""
Tomas Meszaros

TODO:
- add delete to each function
"""

import utils
import random
import sys

TIME = {"hour": 12, "minute": 0, "day": 1, "month": 1, "year": 1990}

def advance_time(by_hour=1):
    TIME["hour"] += 1
    if TIME["hour"] > 24:
        TIME["hour"] = 1
        TIME["day"] += 1
        if TIME["day"] > 28:
            TIME["day"] = 1
            TIME["month"] += 1
            if TIME["month"] > 12:
                TIME["month"] = 1
                TIME["year"] += 1
    utils.set_db_time(hour=TIME["hour"], day=TIME["day"], month=TIME["month"], year=TIME["year"])


################################################################################
## category                                                                   ##
################################################################################

def insert_category():
    category_name = utils.get_random_string()
    utils.execute("""INSERT INTO category (name) VALUES ('{CATEGORY_NAME}');""".format(
        CATEGORY_NAME=category_name))
    advance_time()

def update_category():
    rand_id = utils.get_random_number(1, utils.count_rows("category"))
    rand_name = utils.get_random_string()
    utils.execute("""update category set name = '{RAND_NAME}' where id = {RAND_ID};""".format(
        RAND_NAME=rand_name, RAND_ID=rand_id))
    advance_time()

################################################################################
## product                                                                    ##
################################################################################

def insert_product():
    product_name = utils.get_random_string()
    product_cost = utils.get_random_number(0, 1000)
    product_amount = utils.get_random_number(0, 10000)
    utils.execute("""INSERT INTO product (name, cost, amount) VALUES ('{PRODUCT_NAME}', {PRODUCT_COST}, {PRODUCT_AMOUNT});""".format(
        PRODUCT_NAME=product_name, PRODUCT_COST=product_cost, PRODUCT_AMOUNT=product_amount))
    advance_time()

def update_product():
    rand_id = utils.get_random_number(1, utils.count_rows("product"))
    product_cost = utils.get_random_number(0, 1000)
    product_amount = utils.get_random_number(0, 10000)
    utils.execute("""update product set cost = {PRODUCT_COST} where id = {RAND_ID};""".format(
        PRODUCT_COST=product_cost, RAND_ID=rand_id))
    advance_time()

################################################################################
## customer                                                                   ##
################################################################################

def insert_customer():
    customr_name = utils.get_random_string()
    customer_email = utils.get_random_string()
    customer_password = utils.get_random_string()
    customer_active = utils.get_random_boolean()
    utils.execute("""INSERT INTO customer (name, email, password, active) VALUES ('{CUSTOMER_NAME}', '{CUSTOMER_EMAIL}', '{CUSTOMER_PASSWORD}', '{CUSTOMER_ACTIVE}');""".format(
        CUSTOMER_NAME=customr_name, CUSTOMER_EMAIL=customer_email, CUSTOMER_PASSWORD=customer_password, CUSTOMER_ACTIVE=customer_active))
    advance_time()

def update_customer():
    rand_id = utils.get_random_number(1, utils.count_rows("customer"))
    customer_active = utils.get_random_boolean()
    utils.execute("""update customer set active = '{CUSTOMER_ACTIVE}' where id = {RAND_ID};""".format(
        CUSTOMER_ACTIVE=customer_active, RAND_ID=rand_id))
    advance_time()

################################################################################
## category_product                                                           ##
################################################################################

_category_product_pairs = []
def _get_pair_category_product():
    category_num_ids = utils.count_rows("category")
    product_num_ids = utils.count_rows("product")
    category_product_category_id = utils.get_random_number(1, category_num_ids)
    category_product_product_id = utils.get_random_number(1, product_num_ids)
    return (category_product_category_id, category_product_product_id)

def insert_category_product():
    found_good_pair = False
    while not found_good_pair:
        pair = _get_pair_category_product()
        if pair not in _category_product_pairs:
            _category_product_pairs.append(pair)
            found_good_pair = True
            break
    if not found_good_pair:
        return
    category_product_category_id = pair[0]
    category_product_product_id = pair[1]

    utils.execute("""INSERT INTO category_product (category_id, product_id) VALUES ({CATEGORY_PRODUCT_CATEGORY_ID}, {CATEGORY_PRODUCT_PRODUCT_ID});""".format(
        CATEGORY_PRODUCT_CATEGORY_ID=category_product_category_id, CATEGORY_PRODUCT_PRODUCT_ID=category_product_product_id))
    advance_time()

def delete_category_product():
    ## Delete some pair
    found_good_pair = False
    while not found_good_pair:
        category_num_ids = utils.count_rows("category")
        _category_id = utils.get_random_number(1, category_num_ids)
        product_num_ids = utils.count_rows("product")
        _product_id = utils.get_random_number(1, product_num_ids)
        pair = (_category_id, _product_id)
        if pair in _category_product_pairs:
            #_category_product_pairs.remove(pair)
            found_good_pair = True
            break
    if not found_good_pair:
        return
    category_product_category_id = pair[0]
    category_product_product_id = pair[1]
    _category_product_pairs.remove(pair)
    #utils.execute("""update category_product set category_id = {CATEGORY_PRODUCT_CATEGORY_ID} where product_id = {CATEGORY_PRODUCT_PRODUCT_ID};""".format(
    #    CATEGORY_PRODUCT_CATEGORY_ID=category_product_category_id, CATEGORY_PRODUCT_PRODUCT_ID=category_product_product_id))
    utils.execute("""delete from category_product where category_id = {CATEGORY_PRODUCT_CATEGORY_ID} and product_id = {CATEGORY_PRODUCT_PRODUCT_ID};""".format(
        CATEGORY_PRODUCT_CATEGORY_ID=category_product_category_id, CATEGORY_PRODUCT_PRODUCT_ID=category_product_product_id))

    ## Insert modification of the deleted key
    found_new_pair = False
    while not found_new_pair:
        product_num_ids = utils.count_rows("product")
        _product_id = utils.get_random_number(1, product_num_ids)
        new_pair = (category_product_category_id, _product_id)
        if new_pair not in _category_product_pairs:
            #_category_product_pairs.remove(pair)
            found_new_pair = True
            break
    if not found_new_pair:
        return

    new_category_product_product_id = new_pair[1]
    _category_product_pairs.append(new_pair)

    utils.execute("""INSERT INTO category_product (category_id, product_id) VALUES ({CATEGORY_PRODUCT_CATEGORY_ID}, {CATEGORY_PRODUCT_PRODUCT_ID});""".format(
        CATEGORY_PRODUCT_CATEGORY_ID=category_product_category_id, CATEGORY_PRODUCT_PRODUCT_ID=new_category_product_product_id))

    advance_time()


################################################################################
## purchase                                                                   ##
################################################################################

_customer_product_pairs = []
def _get_pair_customer_product():
    customer_num_ids = utils.count_rows("customer")
    product_num_ids = utils.count_rows("product")
    purchase_customer_id = utils.get_random_number(1, customer_num_ids)
    purchase_product_id = utils.get_random_number(1, product_num_ids)
    return (purchase_customer_id, purchase_product_id)

def insert_purchase():
    def get_db_time():
        return """%d-%d-%d %d:%d""" % (TIME["year"], TIME["month"], TIME["day"], TIME["hour"], TIME["minute"])

    found_good_pair = False
    while not found_good_pair:
        pair = _get_pair_customer_product()
        if pair not in _customer_product_pairs:
            _customer_product_pairs.append(pair)
            found_good_pair = True
            break
    if not found_good_pair:
        return
    purchase_customer_id = pair[0]
    purchase_product_id = pair[1]

    utils.execute("""INSERT INTO purchase (date_time, customer_id, product_id) VALUES ('{DB_TIME}', {PURCHASE_CUSTOMER_ID}, {PURCHASE_PRODUCT_ID});""".format(
        DB_TIME=get_db_time(), PURCHASE_CUSTOMER_ID=purchase_customer_id, PURCHASE_PRODUCT_ID=purchase_product_id))
    advance_time()

def update_purchase():
    customer_num_ids = utils.count_rows("customer")
    product_num_ids = utils.count_rows("product")
    purchase_customer_id = utils.get_random_number(1, customer_num_ids)
    purchase_product_id = utils.get_random_number(1, product_num_ids)
    utils.execute("""update purchase set customer_id = {PURCHASE_CUSTOMER_ID} where product_id = {PURCHASE_PRODUCT_ID};""".format(
        PURCHASE_CUSTOMER_ID=purchase_customer_id, PURCHASE_PRODUCT_ID=purchase_product_id))
    advance_time()


################################################################################
## GENERATION                                                                 ##
################################################################################

def create_testdb_history():
    print(sys.argv)
    IS_HISTORY = False
    if len(sys.argv) == 2 and sys.argv[1] == "history":
        IS_HISTORY = True

    if IS_HISTORY:
        DBNAME = "testdb_history"
    else:
        DBNAME = "testdb"

    USER = "testuser"
    PASSWORD = "test"
    utils.init(DBNAME, USER, PASSWORD)

    TIME = {"hour": 12, "minute": 0, "day": 1, "month": 1, "year": 1990}
    utils.set_db_time(hour=TIME["hour"], day=TIME["day"], month=TIME["month"], year=TIME["year"])

    DB_CHANGES = 10000

    ## Create model and history tables
    utils.drop_all_user_tables(USER)
    utils.execute_from_file("model.sql")
    tables = utils.get_all_user_tables(USER)
    for t in tables:
        table = t[0]
        if IS_HISTORY:
            utils.table_attach_history(table)
            utils.create_history_table(table)

    ## list of database modification functions
    functions = [insert_category, update_category,
                 insert_product, update_product,
                 insert_customer, update_customer,
                 insert_category_product,
                 insert_purchase]
    functions_history = []
    if IS_HISTORY:
        functions_history.append(update_purchase)
        functions_history.append(delete_category_product)

    ## initial inserts
    def _init():
        insert_category()
        insert_product()
        insert_customer()
        insert_category_product()
        insert_purchase()
    for _ in range(20):
        _init()

    ## db life simulation
    for i in range(DB_CHANGES):
        fcn = functions[utils.get_random_number(0, len(functions)-1)]
        print(fcn.__name__)
        fcn()
        if IS_HISTORY:
            if utils.get_random_number(1, 10) == 1:
                fcn_history = functions_history[utils.get_random_number(0, len(functions_history)-1)]
                print(fcn_history.__name__)
                fcn_history()


create_testdb_history()
