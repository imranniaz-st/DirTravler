#!/bin/bash

# === CONFIG ===
DOMAIN_FILE="domain.txt"
SUBS_FILE="subdomains.txt"
RESOLVED_FILE="resolved.txt"
MASSCAN_OUT="masscan_output.txt"
LIVE_IP_PORTS="live_ips_ports.txt"
HTTPX_OUT="httpx_results.txt"
NUCLEI_OUT="vuln_results.txt"

# === COLORS ===
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[*] Starting Automated Recon...${NC}"

# === STEP 1: INSTALL REQUIRED TOOLS ===
echo -e "${GREEN}[+] Checking/installing required tools...${NC}"
TOOLS=(subfinder dnsx masscan httpx nuclei)
for tool in "${TOOLS[@]}"; do
  if ! command -v $tool &>/dev/null; then
    echo "[!] $tool not found. Installing..."
    go install -v github.com/projectdiscovery/$tool/cmd/$tool@latest
  fi
done

# === STEP 2: Subdomain Enumeration ===
echo -e "${GREEN}[+] Running subfinder...${NC}"
subfinder -dL "$DOMAIN_FILE" -silent -all -o "$SUBS_FILE"

# === STEP 3: DNS Resolution ===
echo -e "${GREEN}[+] Resolving subdomains...${NC}"
dnsx -l "$SUBS_FILE" -silent -a -o "$RESOLVED_FILE"

# === STEP 4: Masscan Port Scan ===
echo -e "${GREEN}[+] Running masscan...${NC}"
masscan -iL "$RESOLVED_FILE" -p80,443,8080,8443,3000,8000,9000 --rate=10000 -oL "$MASSCAN_OUT"

# === STEP 5: Extract IP:PORT from masscan ===
echo -e "${GREEN}[+] Extracting live IPs and ports...${NC}"
grep "Host:" "$MASSCAN_OUT" | sed -E 's/.*Host: ([0-9.]+).*Ports: ([0-9]+)\/.*/\1:\2/' > "$LIVE_IP_PORTS"

# === STEP 6: Run HTTPX ===
echo -e "${GREEN}[+] Running httpx...${NC}"
cat "$LIVE_IP_PORTS" | httpx -title -tech-detect -status-code -server -cdn -silent -o "$HTTPX_OUT"

# === STEP 7: Run nuclei for vulnerability detection ===
echo -e "${GREEN}[+] Running nuclei on live targets...${NC}"
cat "$HTTPX_OUT" | cut -d' ' -f1 | nuclei -severity low,medium,high,critical -silent -o "$NUCLEI_OUT"

# === DONE ===
echo -e "${GREEN}[✓] Scan completed. Output saved to:${NC}"
echo -e "  → Subdomains:      $SUBS_FILE"
echo -e "  → Resolved:        $RESOLVED_FILE"
echo -e "  → Masscan:         $MASSCAN_OUT"
echo -e "  → Live IPs/Ports:  $LIVE_IP_PORTS"
echo -e "  → Httpx:           $HTTPX_OUT"
echo -e "  → Vulnerabilities: $NUCLEI_OUT"
