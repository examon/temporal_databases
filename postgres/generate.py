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


conn = psycopg2.connect("dbname='testdb' user='testuser' password='test'")
print(conn)
cur = conn.cursor()

def select_all_from(table):
    cur.execute("""select * from {TABLE};""".format(TABLE=table))
    rows = cur.fetchall()
    return rows

def insert_history(table, name, department, salary, time_start, time_end):
    insert = """insert into {TABLE} values('{NAME}', '{DEPARTMENT}', {SALARY}, tstzrange('{START}', '{END}'));""".format(
        TABLE=table, NAME=name, DEPARTMENT=department, SALARY=salary, START=time_start, END=time_end)
    #print(insert)
    cur.execute(insert)
    conn.commit()

def count_rows(table):
    cur.execute("""select count(*) from {TABLE};""".format(TABLE=table))
    return cur.fetchall()[0][0]

def clear_table(table):
    cur.execute("""delete from {TABLE};""".format(TABLE=table))

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


NUM_ROWS = 10000
TABLE = "employees_history"
for i in range(NUM_ROWS):
    name = get_random_string()
    department = get_random_string()
    salary = get_random_number()
    time_start, time_end = get_random_tstzrange()
    insert_history(TABLE, name, department, salary, time_start, time_end)

print(count_rows("employees_history"))

