#!/usr/bin/env python3
import re
import sys
import time

if len(sys.argv) != 2:
    print("Usage: python3 filter_urls_live.py <file.txt>")
    sys.exit(1)

file_path = sys.argv[1]

# Extensions and folder patterns to skip
skip_patterns = re.compile(
    r'\.(?:jpg|jpeg|png|gif|webp|bmp|svg|css|woff2?|ttf|eot|mp3|mp4|webm|avi|mov|wav|m4a)$'
    r'|/(?:node_modules|\.git|\.github|vendor|\.idea|\.vscode|__MACOSX)(/|$)'
    r'|\.git(ignore|config|modules|keep)?$',
    re.IGNORECASE
)

def filter_and_dedupe(file_path):
    try:
        with open(file_path, 'r+', encoding='utf-8') as file:
            lines = file.readlines()

            seen = set()
            cleaned_lines = []
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                if skip_patterns.search(line):
                    continue
                if line not in seen:
                    seen.add(line)
                    cleaned_lines.append(line)

            file.seek(0)
            file.write('\n'.join(cleaned_lines) + '\n')
            file.truncate()

        print(f"[✔] Cleaned {file_path} | Total valid: {len(cleaned_lines)}")
    except Exception as e:
        print(f"[-] Error: {e}")

if __name__ == "__main__":
    print(f"🔁 Watching file: {file_path} — Running cleanup every 10s...")
    while True:
        filter_and_dedupe(file_path)
        time.sleep(20)
