#!/bin/bash

# Usage: ./dir_traveler.sh https://example.com/

crawl() {
    local url="$1"
    echo "Checking: $url"

    # Fetch the page content
    page=$(curl -s "$url")

    # Check if directory listing exists (look for "Index of" or a <pre> tag as common indicators)
    if [[ "$page" =~ "Index of" || "$page" =~ "<pre>" ]]; then
        # Extract links (files and directories)
        links=$(echo "$page" | grep -oP '(?<=href=")[^"]+' | grep -v '^/?$' | grep -v '^\?' | grep -v '^#')
        for link in $links; do
            # Ignore parent directory links
            if [[ "$link" == "../" ]]; then
                continue
            fi
            # If it's a directory (ends with /), recurse into it
            if [[ "$link" == */ ]]; then
                crawl "${url}${link}"
            else
                echo "File: ${url}${link}"
            fi
        done
    else
        echo "No directory listing at $url"
    fi
}

if [ -z "$1" ]; then
    echo "Usage: $0 <base_url>"
    exit 1
fi

base_url="$1"
[[ "${base_url}" != */ ]] && base_url="${base_url}/"

crawl "$base_url"
