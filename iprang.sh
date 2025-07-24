#!/bin/bash

# ---------------------------------------
# DirTravler - IP Range Scanner Script
# Author: Imran Niaz
# Description: Resolve IPs of domains, get ranges, and masscan them
# ---------------------------------------

DOMAINS_FILE="bugbo.txt"
IPS_FILE="resolved_ips.txt"
RANGES_FILE="ip_ranges.txt"
MASSSCAN_OUTPUT="masscan_result.txt"

mkdir -p output
> "$IPS_FILE"
> "$RANGES_FILE"
> "$MASSSCAN_OUTPUT"

echo "[*] Resolving IPs from $DOMAINS_FILE..."
while read -r domain; do
    # Remove schema if present
    clean_domain=$(echo "$domain" | sed -E 's~https?://~~' | cut -d/ -f1)
    
    if [[ -n "$clean_domain" ]]; then
        ip=$(dig +short "$clean_domain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
        if [[ -n "$ip" ]]; then
            echo "$clean_domain => $ip"
            echo "$ip" >> "$IPS_FILE"

            # Get CIDR block using whois (Org IP range)
            range=$(whois "$ip" | grep -E 'CIDR:|NetRange:' | head -n1 | awk -F: '{print $2}' | xargs)
            if [[ -n "$range" ]]; then
                echo "$range" >> "$RANGES_FILE"
            fi
        fi
    fi
done < "$DOMAINS_FILE"

echo "[*] Unique IP Ranges collected:"
sort -u "$RANGES_FILE" > output/ip_ranges_final.txt
cat output/ip_ranges_final.txt

echo "[*] Running Masscan on IP Ranges..."
while read -r cidr; do
    if [[ "$cidr" == *"-"* ]]; then
        # Convert NetRange to CIDRs if needed
        iprange2cidr "$cidr" >> output/ip_cidrs.txt
    else
        echo "$cidr" >> output/ip_cidrs.txt
    fi
done < output/ip_ranges_final.txt

sort -u output/ip_cidrs.txt -o output/ip_cidrs.txt

while read -r cidr; do
    echo "[*] Scanning: $cidr"
    sudo masscan "$cidr" -p1-65535 --rate=1000 >> "$MASSSCAN_OUTPUT"
done < output/ip_cidrs.txt

echo "[✔] Scan complete. Results saved to: $MASSSCAN_OUTPUT"
