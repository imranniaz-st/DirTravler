#!/bin/bash

# Usage check
[[ ! $1 || ! $2 ]] && echo "Usage: $0 <area_id> <name>" && exit 1

area_id=$1
name=$2
dir="/data/web"

# Make sure the directory exists
if [[ ! -d "$dir" ]]; then
    echo "❌ Directory $dir does not exist."
    exit 1
fi

# Get current WAN IP
ip_wan=$(curl -s icanhazip.com)
echo "Detected WAN IP: $ip_wan"

# Go to target directory (not with sudo, use full sudo line when needed)
cd "$dir" || { echo "❌ Failed to cd to $dir"; exit 1; }

# Create p23.json
cat > p23.json <<EOF
{
    "area": {
        "$area_id": {
            "name": "$name",
            "svrlist": "http://$ip_wan:7000/server/list"
        }
    },
    "serverUrl": "http://$ip_wan:7000/server/list",
    "noticeUrl": "http://$ip_wan:7000/notice",
    "checkWhite": "http://$ip_wan:6008/api/check",
    "reportUrl": "http://$ip_wan:9000/api/",
    "resUrl": "http://aygexqcdn.tunyouhy.com/resUpdate",
    "whiteResUrl": "http://aygexqcdn.tunyouhy.com/resWhite"
}
EOF

# Change ownership
sudo chown game:game p23.json

# Output result
echo -e "\n✅ Generated p23.json:"
cat p23.json
