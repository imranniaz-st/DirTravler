#!/usr/bin/env bash

# Ensure Bash 4+
if [ -z "$BASH_VERSION" ] || [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    echo "❌ Bash 4 or higher is required."
    exit 1
fi

declare -A visited

normalize_url() {
    local url="$1"
    echo "$url" | awk -F'://' '{gsub(/\/+/, "/", $2); print $1 "://" $2}'
}

is_directory_listing() {
    local content="$1"
    echo "$content" | grep -qE "Index of|<title>Index|Parent Directory|<pre>"
}

extract_links() {
    echo "$1" | grep -oP '(?<=href=")[^"]+' | grep -vE '^(mailto:|javascript:|#)' | sort -u
}

crawl() {
    local url=$(normalize_url "$1")
    [[ ${visited["$url"]+_} ]] && return
    visited["$url"]=1

    echo "[*] Checking: $url"
    local content=$(curl -ks "$url")

    if is_directory_listing "$content"; then
        echo "[+] Directory listing found: $url"
        echo "$url" >> found.txt

        mapfile -t links < <(extract_links "$content")

        for link in "${links[@]}"; do
            [[ "$link" == "../" || "$link" == "/" ]] && continue

            if [[ "$link" =~ ^https?:// ]]; then
                next="$link"
            elif [[ "$link" =~ ^/ ]]; then
                proto=$(echo "$url" | grep -oE "^https?://")
                domain=$(echo "$url" | awk -F/ '{print $3}')
                next="$proto$domain$link"
            else
                next="${url%/}/$link"
            fi

            next=$(normalize_url "$next")

            if [[ "$next" =~ /$ ]]; then
                crawl "$next"
            else
                echo "[FILE] $next"
                echo "$next" >> found_files.txt
            fi
        done
    fi
}

# === Modified Section to read from txt file ===

if [[ -z "$1" || ! -f "$1" ]]; then
    echo "Usage: $0 <targets.txt>"
    exit 1
fi

rm -f found.txt found_files.txt

while IFS= read -r target; do
    target=$(echo "$target" | xargs)  # Trim spaces
    [[ -z "$target" ]] && continue

    # Add http:// if not present
    if [[ ! "$target" =~ ^https?:// ]]; then
        target="http://$target"
    fi

    crawl "$target"
done < "$1"
