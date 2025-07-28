import re

input_file = 'nmap_targets.txt'

with open(input_file, 'r+') as f:
    lines = f.readlines()
    f.seek(0)
    for line in lines:
        # Remove lines containing "/open/tcp//ms-wbt-server//"
        if not re.search(r'/open/tcp//ms-wbt-server//', line):
            f.write(line)
    f.truncate()