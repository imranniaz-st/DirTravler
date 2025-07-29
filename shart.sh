#!/bin/bash

# Usage: ./full_info_harvester.sh domains.txt

INPUT_FILE="$1"
WAYBACK_TMP="wayback_urls_all.txt"
LIVE_DIR="found_live_urls"
GIT_DUMP_DIR="found-git-dumps"
LOG_FILE="info_harvest.log"

if [ ! -f "$INPUT_FILE" ]; then
  echo "[-] File $INPUT_FILE not found."
  exit 1
fi

mkdir -p "$LIVE_DIR" "$GIT_DUMP_DIR"
> "$WAYBACK_TMP"
> "$LOG_FILE"

echo "[*] Harvesting waybackurls from input domains..."
while read DOMAIN; do
  DOMAIN=$(echo "$DOMAIN" | tr -d '\r')  # Clean CRLF
  echo "[*] Scanning: $DOMAIN"
  echo "$DOMAIN" | waybackurls >> "$WAYBACK_TMP"
done < "$INPUT_FILE"

echo "[*] Filtering useful/sensitive paths..."
cat "$WAYBACK_TMP" | grep -Ei "\.git|\.env|\.sql|\.zip|\.tar|\.gz|\.bak|\.old|\.inc|\.config|\.xml|\.log|\.json|\.php~" | sort -u > urls_to_test.txt

echo "[*] Testing URLs for live status..."
while read URL; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  if [[ "$STATUS" == "200" ]]; then
    echo "[+] LIVE: $URL" | tee -a "$LOG_FILE"
    echo "$URL" >> "$LIVE_DIR/live_urls.txt"

    # Handle Git dumps
    if [[ "$URL" =~ \.git/HEAD$ ]]; then
      BASE_URL=$(echo "$URL" | sed 's/\.git\/HEAD$/.git\//')
      FOLDER_NAME=$(echo "$BASE_URL" | sed 's|https\?://||g' | tr '/' '_')
      DEST_DIR="$GIT_DUMP_DIR/$FOLDER_NAME"
      echo "    -> Dumping Git repo: $BASE_URL" | tee -a "$LOG_FILE"
      mkdir -p "$DEST_DIR"
      ./gitdumper.sh --all "$BASE_URL" "$DEST_DIR"
    fi

    # Check for keys/tokens in file response
    RESPONSE=$(curl -s "$URL")
    if echo "$RESPONSE" | grep -Eiq "api[_-]?key|secret|token|password|authorization"; then
      echo "    [!] Possible credential leakage found at $URL" | tee -a "$LOG_FILE"
    fi

  fi
done < urls_to_test.txt

echo "[*] Done. Results saved to $LOG_FILE and $LIVE_DIR/"
