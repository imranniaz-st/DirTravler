import re

input_file = 'nmap_targets.txt'
output_file = 'alpha_only_targets.txt'

# Regex to match lines with only alphabets (a-z, A-Z)
alpha_pattern = re.compile(r'^[a-zA-Z]+$')

cleaned_lines = []

with open(input_file, 'r') as f:
    for line in f:
        stripped = line.strip()
        if alpha_pattern.fullmatch(stripped):
            cleaned_lines.append(stripped)

with open(output_file, 'w') as f:
    for line in cleaned_lines:
        f.write(line + '\n')

print(f"[+] Saved {len(cleaned_lines)} clean alphabet-only lines to '{output_file}'")
