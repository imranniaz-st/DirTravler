#!/usr/bin/env bash

# Ensure tools exist
for cmd in nmap curl whatweb jq; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Required tool '$cmd' is missing!"
        exit 1
    fi
done

if [[ -z "$1" || ! -f "$1" ]]; then
    echo "Usage: $0 targets.txt"
    exit 1
fi

echo "🔍 Starting scan on targets from $1..."
rm -f results.json

while IFS= read -r target; do
    target=$(echo "$target" | xargs)
    [[ -z "$target" ]] && continue

    echo "--------------------------------------"
    echo "🔎 Scanning: $target"

    # Normalize URL
    url="http://$target"
    if curl -s --head "$url" | grep -q "^Location: https"; then
        url="https://$target"
    fi

    # Port Scan (Top 20)
    ports=$(nmap -Pn --top-ports 20 "$target" | grep "^PORT" -A 20 | grep -E "tcp" | awk '{print $1 " " $2}' | xargs)

    # HTTP Headers
    headers=$(curl -s -D - -o /dev/null "$url" | grep -v "^<" | grep -v "^$")
    status=$(echo "$headers" | grep -i "HTTP/" | tail -n1 | awk '{print $2}')
    server=$(echo "$headers" | grep -i "Server:" | awk -F ': ' '{print $2}' | xargs)

    # SSL Info if HTTPS
    ssl_issuer=""
    ssl_expiry=""
    if [[ "$url" == https* ]]; then
        ssl_info=$(echo | openssl s_client -connect "$target:443" 2>/dev/null | openssl x509 -noout -issuer -enddate)
        ssl_issuer=$(echo "$ssl_info" | grep "issuer=" | sed 's/issuer=//')
        ssl_expiry=$(echo "$ssl_info" | grep "notAfter=" | sed 's/notAfter=//')
    fi

    # WhatWeb Technology Fingerprinting
    tech=$(whatweb --no-errors --log-verbose=- "$url" | head -n1 | sed "s/^$target//" | xargs)

    # Directory guessing (lightweight)
    declare -a dirs=("admin" "login" "dashboard" "config" "backup" "phpinfo.php" "server-status" ".git/config")
    found_dirs=()
    for dir in "${dirs[@]}"; do
        full="$url/$dir"
        code=$(curl -o /dev/null -s -w "%{http_code}" "$full")
        if [[ "$code" =~ ^(200|301|302)$ ]]; then
            found_dirs+=("$dir ($code)")
        fi
    done

    # Save JSON output
    jq -n \
        --arg ip "$target" \
        --arg status "$status" \
        --arg ports "$ports" \
        --arg server "$server" \
        --arg tech "$tech" \
        --arg ssl_issuer "$ssl_issuer" \
        --arg ssl_expiry "$ssl_expiry" \
        --argjson directories "$(printf '%s\n' "${found_dirs[@]}" | jq -R . | jq -s .)" \
        '{
            ip: $ip,
            http_status: $status,
            open_ports: $ports,
            server_header: $server,
            ssl_issuer: $ssl_issuer,
            ssl_expiry: $ssl_expiry,
            technologies: $tech,
            interesting_directories: $directories
        }' >> results.json

    echo "✅ $target scanned and saved."

done < "$1"

echo "📄 All results saved in results.json"
