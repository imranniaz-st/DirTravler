#!/bin/bash

# Input file
DOMAIN_FILE="domain.txt"

# Output files
SUBS_FILE="subfinder_output.txt"
RESOLVED_IPS="resolved_ips.txt"
MASSCAN_OUT="masscan_output.txt"
LIVE_IP_PORTS="live_ips_ports.txt"
NUCLEI_OUT="vuln_results.txt"

echo "[+] Starting Vulnerability Recon..."

# Step 1: Subdomain enumeration
if command -v subfinder >/dev/null 2>&1; then
    echo "[*] Running Subfinder..."
    subfinder -dL "$DOMAIN_FILE" -silent -all -o "$SUBS_FILE"
else
    echo "[!] subfinder not found, copying domains directly..."
    cp "$DOMAIN_FILE" "$SUBS_FILE"
fi

# Step 2: DNS resolution
if command -v dnsx >/dev/null 2>&1; then
    echo "[*] Resolving with DNSx..."
    dnsx -l "$SUBS_FILE" -a -resp-only -silent -o "$RESOLVED_IPS"
else
    echo "[!] dnsx not found. Creating empty IP list."
    touch "$RESOLVED_IPS"
fi

# Step 3: Port scanning
if command -v masscan >/dev/null 2>&1; then
    echo "[*] Running Masscan..."
    masscan -iL "$RESOLVED_IPS" -p21,22,80,443,8080,8443,3306 --rate=10000 -oL "$MASSCAN_OUT" || touch "$MASSCAN_OUT"
    grep "Host:" "$MASSCAN_OUT" | sed -E 's/.*Host: ([0-9.]+).*Ports: ([0-9]+)\/.*/\1:\2/' > "$LIVE_IP_PORTS"
else
    echo "[!] masscan not found. Creating empty ports list."
    touch "$LIVE_IP_PORTS"
fi

# Step 4: Install Nuclei templates and scan
if command -v nuclei >/dev/null 2>&1; then
    echo "[*] Updating Nuclei templates..."
    nuclei -update-templates

    TEMPLATE_DIR="$HOME/nuclei-templates"
    if [ ! -d "$TEMPLATE_DIR" ]; then
        echo "[!] Template directory not found. Cloning manually..."
        git clone https://github.com/projectdiscovery/nuclei-templates.git "$TEMPLATE_DIR"
    fi

    echo "[*] Running Nuclei with all templates..."
    nuclei -l "$LIVE_IP_PORTS" -t "$TEMPLATE_DIR" -o "$NUCLEI_OUT" -silent || touch "$NUCLEI_OUT"
else
    echo "[!] nuclei not found. Creating empty vulnerabilities file."
    touch "$NUCLEI_OUT"
fi

echo "[✔] Scan complete. Output saved:"
echo "    Subdomains:         $SUBS_FILE"
echo "    Resolved IPs:       $RESOLVED_IPS"
echo "    Port Scan (raw):    $MASSCAN_OUT"
echo "    IP:Port Live List:  $LIVE_IP_PORTS"
echo "    Vulnerabilities:    $NUCLEI_OUT"
