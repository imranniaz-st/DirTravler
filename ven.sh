#!/bin/bash

# Input domain list
DOMAIN_FILE="domain.txt"

# Output files
SUBS_FILE="subfinder_output.txt"
DNSX_FILE="dnsx_output.txt"
RESOLVED_IPS="resolved_ips.txt"
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
    echo "[*] Resolving with DNSx..."
    dnsx -l "$SUBS_FILE" -silent -a -resp-only -o "$RESOLVED_IPS"
else
    echo "[!] dnsx not found. Skipping..."
    touch "$RESOLVED_IPS"
fi

# Step 3: Port Scanning with Masscan
if command -v masscan >/dev/null 2>&1; then
    echo "[*] Running Masscan..."
    masscan -iL "$RESOLVED_IPS" -p21,22,80,443,8080,8443,3306 --rate=10000 -oL "$MASSCAN_OUT"
    
    grep "Host:" "$MASSCAN_OUT" | \
    sed -E 's/.*Host: ([0-9.]+).*Ports: ([0-9]+)\/.*/\1:\2/' > "$LIVE_IP_PORTS"
else
    echo "[!] masscan not found. Skipping..."
    touch "$LIVE_IP_PORTS"
fi

# Step 4: Update and run Nuclei with all templates
if command -v nuclei >/dev/null 2>&1; then
    echo "[*] Updating Nuclei templates..."
    nuclei -ut
    
    echo "[*] Running Nuclei on IP:Port..."
    nuclei -l "$LIVE_IP_PORTS" -t ~/nuclei-templates/ -o "$NUCLEI_OUT" -silent
else
    echo "[!] nuclei not found. Skipping..."
    touch "$NUCLEI_OUT"
fi

echo "[✔] Scan complete. Output saved:"
echo "    Subdomains:         $SUBS_FILE"
echo "    Resolved IPs:       $RESOLVED_IPS"
echo "    Port Scan (raw):    $MASSCAN_OUT"
echo "    IP:Port Live List:  $LIVE_IP_PORTS"
echo "    Vulnerabilities:    $NUCLEI_OUT"
