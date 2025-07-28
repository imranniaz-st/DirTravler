import re

file_path = 'nmap_targets.txt'

# Read the current lines
with open(file_path, 'r') as f:
    lines = f.readlines()

# Clean lines: remove everything from first slash onwards
cleaned = []
for line in lines:
    line = line.strip()
    # Remove from first '/' to end
    line = re.split(r'/', line)[0]
    # Keep only if it is alphabet-only
    if line.isalpha():
        cleaned.append(line)

# Overwrite the same file with cleaned content
with open(file_path, 'w') as f:
    for line in cleaned:
        f.write(line + '\n')

print(f"[+] Cleaned and updated '{file_path}' in-place.")
