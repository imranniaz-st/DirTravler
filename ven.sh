#!/bin/bash

# Input domain list
DOMAIN_FILE="domain.txt"

# Output files
SUBS_FILE="subfinder_output.txt"
DNSX_FILE="dnsx_output.txt"
MASSCAN_OUT="masscan_output.txt"
LIVE_IP_PORTS="live_ips_ports.txt"
NUCLEI_OUT="vuln_results.txt"

echo "[+] Starting Vulnerability Recon on $(wc -l < "$DOMAIN_FILE") domains..."

# Step 1: Subdomain Enumeration
if command -v subfinder >/dev/null 2>&1; then
    echo "[*] Running Subfinder..."
    subfinder -dL "$DOMAIN_FILE" -silent -all -o "$SUBS_FILE"
else
    echo "[!] subfinder not found. Skipping..."
    cp "$DOMAIN_FILE" "$SUBS_FILE"
fi

# Step 2: DNS Resolution
if command -v dnsx >/dev/null 2>&1; then
    echo "[*] Running DNSx..."
    dnsx -l "$SUBS_FILE" -silent -a -o "$DNSX_FILE"
else
    echo "[!] dnsx not found. Skipping..."
    cp "$SUBS_FILE" "$DNSX_FILE"
fi

# Step 3: Port Scanning with Masscan
if command -v masscan >/dev/null 2>&1; then
    echo "[*] Running Masscan..."
    masscan -iL "$DNSX_FILE" -p80,443,8080,8443,3000,8000,9000,22,21,3306 --rate=10000 -oL "$MASSCAN_OUT"
    grep "Host:" "$MASSCAN_OUT" | sed -E 's/.*Host: ([0-9.]+).*Ports: ([0-9]+)\/.*/\1:\2/' > "$LIVE_IP_PORTS"
else
    echo "[!] masscan not found. Skipping..."
    touch "$LIVE_IP_PORTS"
fi

# Step 4: Run Nuclei on IPs/Ports
if command -v nuclei >/dev/null 2>&1; then
    echo "[*] Running Nuclei on IP:Port..."
    cut -d ':' -f1 "$LIVE_IP_PORTS" | sort -u | nuclei -silent -o "$NUCLEI_OUT"
else
    echo "[!] nuclei not found. Skipping..."
    touch "$NUCLEI_OUT"
fi

echo "[✔] Scan complete. Output saved:"
echo "    Subdomains:         $SUBS_FILE"
echo "    Resolved IPs:       $DNSX_FILE"
echo "    Port Scan (raw):    $MASSCAN_OUT"
echo "    IP:Port Live List:  $LIVE_IP_PORTS"
echo "    Vulnerabilities:    $NUCLEI_OUT"
