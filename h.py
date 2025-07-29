import mysql.connector
from mysql.connector import Error
import datetime

# Your login credentials
user = " "
password = " -"

# Log file to track attempts
log_file = "host_scan_log.txt"

# Function to write to log file
def log(message):
    timestamp = datetime.datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    with open(log_file, "a") as f:
        f.write(f"{timestamp} {message}\n")

# Loop through 1 to 10000
for i in range(1, 10001):
    host = f"auth-db{i}.hstgr.io"
    log(f"🔍 Trying host: {host}")
    print(f"🔍 Trying host: {host}")
    
    try:
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            connection_timeout=3
        )
        if conn.is_connected():
            log(f"✅ SUCCESS: Connected to host {host}")
            print(f"✅ SUCCESS: Connected to host {host}")
            conn.close()
            break  # comment this if you want to try all 10,000
    except Error as e:
        log(f"❌ FAILED: {host} - {str(e).splitlines()[0]}")
        continue

print(f"📝 Scan complete. Check log: {log_file}")
