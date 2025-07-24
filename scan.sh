#!/bin/bash

domain=$1

if [ -z "$domain" ]; then
    echo "Usage: ./full_advanced_domain_scan.sh domain.com"
    exit 1
fi

echo "[+] Subdomain Enumeration on: $domain"
subfinder -d "$domain" -all -silent -o all_subdomains.txt

echo "[+] Extracting all IP addresses from all subdomains..."
dnsx -l all_subdomains.txt -silent -a -resp-only | tee ips_all.txt

echo "[+] Checking which subdomains are live..."
cat all_subdomains.txt | httpx -silent -status-code -ip -title -tech-detect -o live_subdomains.txt

echo "[+] Extracting IP addresses of LIVE subdomains..."
cat live_subdomains.txt | grep -oP '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u > ips_live.txt

echo "[+] Running Naabu port scan on ALL IPs..."
cat ips_all.txt | naabu -silent -top-ports 1000 -o ports.txt

echo "[+] Summary of Results:"
echo " - All Subdomains (Active/Inactive): all_subdomains.txt"
echo " - All IPs (Active/Inactive): ips_all.txt"
echo " - Live Subdomains: live_subdomains.txt"
echo " - Live IPs: ips_live.txt"
echo " - Open Ports (All IPs): ports.txt"

echo "[✓] Done"

