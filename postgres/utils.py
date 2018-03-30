#!/usr/bin/env python3

from pprint import pprint as pp

import random
import string
import datetime

import psycopg2

"""
Requirements:
- psycopg2

TODO:
- functions for selecting ranges?
    - select stuff from test_history where sys_perios is in range: tstzrange('0110-01-01', '0320-01-01', '[]')
    select * from test_history where tstzrange('0110-01-01', '0320-01-01', '[]') @> sys_period;
"""


ALPHABET = list(string.ascii_lowercase)

conn = None
cur = None


def init(dbname, user, password):
    global conn
    global cur
    global db_user
    conn = psycopg2.connect("dbname='{DBNAME}' user='{USER}' password='{PASSWORD}'".format(DBNAME=dbname, USER=user, PASSWORD=password))
    cur = conn.cursor()
    assert(conn != None and cur != None)

    try:
        # Try to create temporal_tables extension
        # You need user with superuser permissions
        q = cur.execute("""create extension temporal_tables;""")
    except psycopg2.ProgrammingError:
        print("temporal_tables extension already created")
    finally:
        # Need to commit transaction
        conn.commit()


def execute(sql):
    cur.execute(sql)
    conn.commit()


def execute_from_file(file_name):
    """ Executes sql code from given file.
    """
    f = open(file_name)
    sql_code = f.read()
    cur.execute(sql_code)
    conn.commit()


def create_table(name, *attributes, history=True):
    """ Usage:

    create_table("test", "name text", "age int")
    """
    attrs = ','.join(attributes)
    cur.execute("""create table {NAME} ({ATTRIBUTES});""".format(NAME=name, ATTRIBUTES=attrs))
    if history:
        cur.execute("""alter table {TABLE} add column sys_period tstzrange NOT NULL;""".format(TABLE=name))
    conn.commit()


def set_db_time(hour, day, month, year):
    cur.execute("""SELECT set_system_time('{YEAR}-{MONTH}-{DAY} {HOUR}:0');""".format(
        YEAR=year, MONTH=month, DAY=day, HOUR=hour))
    conn.commit()


def reset_db_time():
    cur.execute("""SELECT set_system_time(NULL);""")
    conn.commit()


def table_attach_history(name):
    cur.execute("""alter table {TABLE} add column sys_period tstzrange NOT NULL;""".format(TABLE=name))
    conn.commit()


def create_history_table(name):
    """ Creates history table for table @name
    """
    cur.execute("""create table {TABLE}_history (like {TABLE});""".format(TABLE=name))
    # this works only if the user has superuser permissions
    cur.execute("""create trigger versioning_trigger before insert or update or delete on {TABLE} for each row execute procedure versioning('sys_period', '{TABLE}_history', true);""".format(TABLE=name))
    conn.commit()


def select_all_from(table):
    cur.execute("""select * from {TABLE};""".format(TABLE=table))
    return cur.fetchall()


def count_rows(table):
    cur.execute("""select count(*) from {TABLE};""".format(TABLE=table))
    return cur.fetchall()[0][0]


def clear_table(table):
    cur.execute("""delete from {TABLE};""".format(TABLE=table))


def drop_table(table, cascade=False):
    c = "cascade" if cascade else ''
    cur.execute("""drop table {TABLE} {CASCADE};""".format(TABLE=table, CASCADE=c))
    conn.commit()


def get_all_user_tables(user):
    cur.execute("""select tablename from pg_catalog.pg_tables where tableowner like '{USER}';""".format(USER=user))
    return cur.fetchall()


def drop_all_user_tables(user):
    for table in get_all_user_tables(user):
        drop_table(table[0], cascade=True)


def get_random_string(min_length=5, max_length=15):
    final = ""
    for i in range(random.choice(range(min_length, max_length+1))):
        final += ALPHABET[random.choice(range(0, len(ALPHABET)))]
    return final


def get_random_number(min_value=0, max_value=100000):
    try:
        return random.choice(range(min_value, max_value+1))
    except:
        print(min_value, max_value)


def get_random_boolean():
    res = random.choice(range(2))
    if res == 0:
        return "false"
    else:
        return "true"


def get_random_tstzrange(min_start_year=100, max_end_year=2018, step=1):
    """ 'year-month-day'
    """
    s_year = get_random_number(min_start_year, max_end_year)
    e_year = get_random_number(s_year+step, max_end_year+step)
    s_month = get_random_number(1, 12)
    e_month = get_random_number(1, 12)
    # 28 so we do not get out of range
    s_day = get_random_number(1, 28)
    e_day = get_random_number(1, 28)
    start = datetime.datetime(s_year, s_month, s_day)
    end = datetime.datetime(e_year, e_month, e_day)
    start_str = '{:%Y-%m-%d}'.format(start)
    end_str = '{:%Y-%m-%d}'.format(end)
    return """tstzrange('{START}', '{END}')""".format(START=start_str, END=end_str)
    #return (start_str, end_str)
