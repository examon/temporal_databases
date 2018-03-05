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
- functions for creating versioned tables
- functions to drop table
- functions for selecting ranges?
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


def create_table(name, *attributes, history=True):
    """ Usage: create_table("test", "name text", "age int")

    history: True = creates history table and enables versioning
    """
    attrs = ','.join(attributes)
    cur.execute("""create table {NAME} ({ATTRIBUTES});""".format(NAME=name, ATTRIBUTES=attrs))

    if history:
        cur.execute("""alter table {TABLE} add column sys_period tstzrange NOT NULL;""".format(TABLE=name))
        cur.execute("""create table {TABLE}_history (like {TABLE});""".format(TABLE=name))
        #cur.execute("""create trigger versioning_trigger before insert or update or delete on {TABLE} for each row execute procedure versioning('sys_period', '{TABLE}_history', true);""".format(TABLE=name))
    conn.commit()


def select_all_from(table):
    cur.execute("""select * from {TABLE};""".format(TABLE=table))
    return cur.fetchall()


def insert_history(table, name, department, salary, time_start, time_end):
    insert = """insert into {TABLE} values('{NAME}', '{DEPARTMENT}', {SALARY}, tstzrange('{START}', '{END}'));""".format(
        TABLE=table, NAME=name, DEPARTMENT=department, SALARY=salary, START=time_start, END=time_end)
    cur.execute(insert)
    conn.commit()


def count_rows(table):
    cur.execute("""select count(*) from {TABLE};""".format(TABLE=table))
    return cur.fetchall()[0][0]


def clear_table(table):
    cur.execute("""delete from {TABLE};""".format(TABLE=table))


def drop_table(table):
    cur.execute("""drop table {TABLE};""".format(TABLE=table))
    conn.commit()


def get_all_user_tables(user):
    cur.execute("""select tablename from pg_catalog.pg_tables where tableowner like '{USER}';""".format(USER=user))
    return cur.fetchall()


def drop_all_user_tables(user):
    for table in get_all_user_tables(user):
        drop_table(table[0])


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
    return (start_str, end_str)
