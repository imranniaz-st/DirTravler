#!/bin/bash

# Usage: ./check_git_wayback_batch.sh domains.txt

INPUT_FILE="$1"
WAYBACK_TMP="wayback_git_urls.txt"
OUTPUT_DIR="found-git-dumps"

if [ ! -f "$INPUT_FILE" ]; then
  echo "[-] File $INPUT_FILE not found."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
> "$WAYBACK_TMP"

echo "[*] Starting .git exposure scan using waybackurls..."

while read DOMAIN; do
  DOMAIN=$(echo "$DOMAIN" | tr -d '\r')  # Clean CRLF if needed
  echo "[*] Scanning: $DOMAIN"
  
  echo "$DOMAIN" | waybackurls | grep "/.git" | sort -u >> "$WAYBACK_TMP"
done < "$INPUT_FILE"

echo "[*] Testing URLs for live .git endpoints..."
cat "$WAYBACK_TMP" | sort -u | while read URL; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

  if [[ "$STATUS" == "200" ]]; then
    echo "[+] LIVE: $URL"

    # Check if it's a full repo dir
    if [[ "$URL" =~ \.git\/HEAD$ ]]; then
      BASE_URL=$(echo "$URL" | sed 's/\.git\/HEAD$/.git\//')
      DOMAIN_NAME=$(echo "$BASE_URL" | sed 's|https\?://||g' | tr '/' '_')
      DEST_DIR="$OUTPUT_DIR/$DOMAIN_NAME"

      echo "    -> Dumping Git repo from $BASE_URL to $DEST_DIR"
      mkdir -p "$DEST_DIR"
      ./gitdumper.sh --all "$BASE_URL" "$DEST_DIR"
    fi
  fi
done

echo "[*] Done."
