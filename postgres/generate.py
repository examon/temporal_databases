#!/usr/bin/env python3

import utils

DBNAME = "testdb"
USER = "testuser"
PASSWORD = "test"

utils.init(DBNAME, USER, PASSWORD)

"""
NUM_ROWS = 10000
TABLE = "employees_history"
for i in range(NUM_ROWS):
    name = get_random_string()
    department = get_random_string()
    salary = get_random_number()
    time_start, time_end = get_random_tstzrange()
    insert_history(TABLE, name, department, salary, time_start, time_end)
print(count_rows("employees_history"))
"""

utils.drop_all_user_tables(USER)
utils.create_table("test", "name text", "age int")
print(utils.get_all_user_tables(USER))
