#!/bin/bash

# Define paths
CONTENT_DIR="/usr/share/nginx/html/content"

# Download a JSON file, replacing the existing one only if the response is valid JSON.
# (Prevents error pages, e.g. Cloudflare challenges, from overwriting good cached data.)
fetch_json() {
    url="$1"
    dest="$2"
    tmp="$dest.tmp"
    if curl -sSf "$url" -o "$tmp" && jq empty "$tmp" 2>/dev/null; then
        mv "$tmp" "$dest"
    else
        echo "Failed to fetch valid JSON from $url; keeping existing $dest" >&2
        rm -f "$tmp"
    fi
}

# Download the initial JSON files
fetch_json "https://legacy.wikirate.org/Answer/compact.json?limit=0&filter%5Bcompany_group%5D=~13479530&filter%5Bmetric_id%5D%5B%5D=6126450&filter%5Bmetric_id%5D%5B%5D=5780639&filter%5Bmetric_id%5D%5B%5D=5990097&filter%5Bmetric_id%5D%5B%5D=7624093&filter%5Bmetric_id%5D%5B%5D=7616258&filter%5Bmetric_id%5D%5B%5D=19884143&filter%5Byear%5D=latest" "$CONTENT_DIR/brand_answers.json"
fetch_json "https://legacy.wikirate.org/~13479530+Company.json?item=nucleus" "$CONTENT_DIR/brands.json"
fetch_json "https://legacy.wikirate.org/~5768810+Relationships.json?limit=999&filter%5Bcompany_group%5D=~13479530&filter%5Byear%5D=latest" "$CONTENT_DIR/sub_brands.json"
fetch_json "https://legacy.wikirate.org/~20354046.json" "$CONTENT_DIR/country_list.json"
fetch_json "https://legacy.wikirate.org/~5990097+Answers.json?limit=999&filter%5Bcompany_group%5D=~13479530&filter%5Byear%5D=latest" "$CONTENT_DIR/living_wage_scores.json"

# Extract country names from the content attribute of country_list.json
country_names=$(jq -r '.content[]' "$CONTENT_DIR/country_list.json")

# Loop through each country name to make additional requests
for country_name in $country_names; do
    # Convert country name to lowercase
    lower_country_name=$(echo "$country_name" | tr '[:upper:]' '[:lower:]')
    fetch_json "https://legacy.wikirate.org/~7347357+Answers.json?limit=999&filter%5Bcountry%5D%5B%5D=$country_name&filter%5Byear%5D=latest" "$CONTENT_DIR/$lower_country_name.json"
done