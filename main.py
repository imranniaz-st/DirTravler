import re
import sys

if len(sys.argv) != 2:
    print("Usage: python remove_image_urls.py <file.txt>")
    sys.exit(1)

file_path = sys.argv[1]

# Regex to match image URLs or paths
img_regex = re.compile(
    r'(https?:\/\/\S+\.(?:jpg|jpeg|png|gif|webp|bmp|svg|css|woff|woff2|ttf|eot|mp3|mp4|webm|avi|mov|wav|m4a)'
    r'|\b\S+\.(?:jpg|jpeg|png|gif|webp|bmp|svg|css|woff|woff2|ttf|eot|mp3|mp4|webm|avi|mov|wav|m4a))',
    re.IGNORECASE
)

try:
    with open(file_path, 'r+', encoding='utf-8') as file:
        content = file.read()
        cleaned = img_regex.sub('', content)
        file.seek(0)
        file.write(cleaned)
        file.truncate()
    print(f"[+] Removed image URLs from: {file_path}")
except Exception as e:
    print(f"[-] Error: {e}")

# Remove empty lines
try:
    with open(file_path, 'r+', encoding='utf-8') as file:
        content = file.read()
        cleaned = re.sub(r'^\s*$', '', content, flags=re.MULTILINE)
        file.seek(0)
        file.write(cleaned)
        file.truncate()
    print(f"[+] Removed empty lines from: {file_path}")
except Exception as e:
    print(f"[-] Error while removing empty lines: {e}")
