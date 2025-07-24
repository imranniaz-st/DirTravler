#!/bin/bash

# Input file
input="domain.txt"

# Output directory
mkdir -p subdomains

# Loop over each domain
while IFS= read -r domain || [ -n "$domain" ]; do
    # Strip protocol (http/https) and trailing slashes if any
    clean_domain=$(echo "$domain" | sed -E 's@https?://@@; s@/$@@')

    echo "[*] Finding subdomains for: $clean_domain"

    # Save to file
    subfinder -d "$clean_domain" -silent -all -o "subdomains/$clean_domain.txt"

    echo "[✔] Output saved: subdomains/$clean_domain.txt"
done < "$input"

echo -e "\n[✓] All subdomains collected!"
