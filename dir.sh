#!/bin/bash

# Output directory
mkdir -p reports

# Loop through each domain in domain.txt
while read -r domain; do
    if [[ -z "$domain" ]]; then
        continue
    fi

    echo "🔍 Scanning: $domain"
    
    # Clean filename
    safe_name=$(echo "$domain" | sed 's|https\?://||g' | tr '/:' '_')

    # Run dirsearch
    dirsearch -u "$domain" -e txt,py,html,json -o "reports/${safe_name}.txt"

    echo "✅ Finished: $domain → reports/${safe_name}.txt"
    echo "-----------------------------------------------"

done < domain.txt
