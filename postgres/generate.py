#!/usr/bin/env python3

import utils

DBNAME = "testdb"
USER = "testuser"
PASSWORD = "test"

utils.init(DBNAME, USER, PASSWORD)


utils.drop_all_user_tables(USER)
utils.create_table("test", "name text")
utils.create_history_table("test")
utils.execute_from_file("model.sql")

print(utils.get_all_user_tables(USER))



"""
NUM_ROWS = 10000
TABLE = "test_history"
for i in range(NUM_ROWS):
    name = utils.get_random_string()
    time_start, time_end = utils.get_random_tstzrange()
    utils.insert_history(TABLE, name, time_start, time_end)
print(utils.count_rows("test_history"))
"""
