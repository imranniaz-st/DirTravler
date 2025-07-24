#!/bin/bash

# File paths
DOMAIN_FILE="domains.txt"
SUBS_FILE="subdomains.txt"
RESOLVED_FILE="resolved.txt"
MASSCAN_OUT="masscan_output.txt"
LIVE_IP_PORTS="live_ips_ports.txt"
HTTPX_OUT="httpx_results.txt"
NUCLEI_OUT="vuln_results.txt"

# Subdomain Enumeration
subfinder -dL "$DOMAIN_FILE" -silent -all -o "$SUBS_FILE"

# DNS Resolution
dnsx -l "$SUBS_FILE" -silent -a -o "$RESOLVED_FILE"

# Masscan
masscan -iL "$RESOLVED_FILE" -p80,443,8080,8443,3000,8000,9000 --rate=10000 -oL "$MASSCAN_OUT"

# Extract IP:Port
grep "Host:" "$MASSCAN_OUT" | sed -E 's/.*Host: ([0-9.]+).*Ports: ([0-9]+)\/.*/\1:\2/' > "$LIVE_IP_PORTS"

# Run HTTPX
cat "$LIVE_IP_PORTS" | httpx -title -tech-detect -status-code -server -cdn -silent -o "$HTTPX_OUT"

# Run Nuclei
cat "$HTTPX_OUT" | cut -d' ' -f1 | nuclei -severity low,medium,high,critical -silent -o "$NUCLEI_OUT"
