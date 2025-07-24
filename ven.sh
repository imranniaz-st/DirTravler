#!/bin/bash

DOMAIN_FILE="domain.txt"
RESOLVED_IPS="resolved_ips.txt"
NMAP_OUT="nmap_results.pxt"
NUCLEI_OUT="nuclei_results.pxt"
NUCLEI_TEMPLATE_DIR="$HOME/nuclei-templates"

echo "[+] Starting full scan on domains in $DOMAIN_FILE..."

# Step 1: Resolve IPs with dnsx
echo "[*] Resolving IPs using dnsx..."
dnsx -l "$DOMAIN_FILE" -a -resp-only -silent -o "$RESOLVED_IPS"

# Step 2: Run aggressive Nmap on each IP
echo "[*] Running aggressive Nmap scan..."
> "$NMAP_OUT"  # Empty the file
while read -r ip; do
    echo "[*] Scanning $ip with Nmap..."
    nmap -A -T4 "$ip" >> "$NMAP_OUT"
    echo -e "\n-----------------------------\n" >> "$NMAP_OUT"
done < "$RESOLVED_IPS"

# Step 3: Update nuclei templates if not found
if [ ! -d "$NUCLEI_TEMPLATE_DIR" ]; then
    echo "[*] Downloading Nuclei templates..."
    git clone https://github.com/projectdiscovery/nuclei-templates.git "$NUCLEI_TEMPLATE_DIR"
else
    echo "[*] Updating Nuclei templates..."
    nuclei -update-templates
fi

# Step 4: Run nuclei scan on all domains
echo "[*] Running Nuclei scan on domains..."
nuclei -l "$DOMAIN_FILE" -t "$NUCLEI_TEMPLATE_DIR" -o "$NUCLEI_OUT" -silent

# Final summary
echo "[✔] Scan Complete:"
echo "    Nmap Results:   $NMAP_OUT"
echo "    Nuclei Results: $NUCLEI_OUT"
