#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p reports

# Read each domain line-by-line
while read -r url; do
    if [[ -z "$url" ]]; then
        continue
    fi

    echo "======================================================"
    echo "[*] Starting scan for $url"
    
    # Clean domain name for filename
    domain_name=$(echo "$url" | sed 's|https\?://||' | tr '/:' '_')

    # Run dirsearch and wait for it to finish before the next
    python3 /usr/lib/python3/dist-packages/dirsearch/dirsearch.py -u "$url" -e php,html,js,txt -x 403,404,500 -t 50 > "reports/${domain_name}.txt"

    echo "[✔] Completed scan for $url → reports/${domain_name}.txt"
    echo "======================================================"
done < domain.txt
