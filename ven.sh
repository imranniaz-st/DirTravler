#!/bin/bash

# Input domain list
DOMAIN_FILE="domains.txt"

# Output files
SUBS_FILE="subfinder_output.txt"
DNSX_FILE="dnsx_output.txt"
MASSCAN_OUT="masscan_output.txt"
LIVE_IP_PORTS="live_ips_ports.txt"
HTTPX_OUT="httpx_output.txt"
NUCLEI_OUT="vuln_results.txt"

echo "[+] Starting Vulnerability Recon on $(wc -l < "$DOMAIN_FILE") domains..."

# Subfinder
if command -v subfinder >/dev/null 2>&1; then
    echo "[*] Running Subfinder..."
    subfinder -dL "$DOMAIN_FILE" -silent -all -o "$SUBS_FILE"
else
    echo "[!] subfinder not found. Skipping..."
    cp "$DOMAIN_FILE" "$SUBS_FILE"
fi

# DNS Resolution (with dnsx)
if command -v dnsx >/dev/null 2>&1; then
    echo "[*] Running DNSx..."
    dnsx -l "$SUBS_FILE" -silent -a -o "$DNSX_FILE"
else
    echo "[!] dnsx not found. Skipping..."
    cp "$SUBS_FILE" "$DNSX_FILE"
fi

# Masscan
if command -v masscan >/dev/null 2>&1; then
    echo "[*] Running Masscan..."
    masscan -iL "$DNSX_FILE" -p80,443,8080,8443,3000,8000,9000 --rate=10000 -oL "$MASSCAN_OUT"
    grep "Host:" "$MASSCAN_OUT" | sed -E 's/.*Host: ([0-9.]+).*Ports: ([0-9]+)\/.*/\1:\2/' > "$LIVE_IP_PORTS"
else
    echo "[!] masscan not found. Skipping..."
    touch "$LIVE_IP_PORTS"
fi

# HTTPX
if command -v httpx >/dev/null 2>&1; then
    echo "[*] Running HTTPX..."
    cat "$LIVE_IP_PORTS" | httpx -title -tech-detect -status-code -server -cdn -silent -o "$HTTPX_OUT"
else
    echo "[!] httpx not found. Skipping..."
    touch "$HTTPX_OUT"
fi

# Nuclei
if command -v nuclei >/dev/null 2>&1; then
    echo "[*] Running Nuclei..."
    cat "$HTTPX_OUT" | cut -d ' ' -f1 | nuclei -silent -o "$NUCLEI_OUT"
else
    echo "[!] nuclei not found. Skipping..."
    touch "$NUCLEI_OUT"
fi

echo "[✔] Scan complete. Output saved:"
echo "    Subdomains: $SUBS_FILE"
echo "    DNS resolved: $DNSX_FILE"
echo "    Masscan: $MASSCAN_OUT"
echo "    Live IPs/Ports: $LIVE_IP_PORTS"
echo "    HTTPX: $HTTPX_OUT"
echo "    Vulnerabilities: $NUCLEI_OUT"
