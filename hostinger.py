import mysql.connector
from mysql.connector import Error

host = "auth-db1420.hstgr.io"
user = " "
password = ""

for i in range(1, 10001):
    db_name = f"db{i}"
    try:
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=db_name,
            connection_timeout=3
        )
        if conn.is_connected():
            print(f"✅ SUCCESS: Connected to database '{db_name}'")
            conn.close()
            break
    except Error as e:
        # Uncomment below if you want to debug every failed attempt
        # print(f"Failed on {db_name}: {e}")
        continue
