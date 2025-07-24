mkdir -p reports

while read -r url; do
    domain_name=$(echo "$url" | sed 's|https\?://||' | tr '/:' '_')
    python3 dirsearch.py -u "$url" -e php,html,js,txt -x 403,404,500 -t 50 --simple-report "reports/${domain_name}.txt"
done < domain.txt
