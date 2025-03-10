#!/bin/bash

# Define paths
CONTENT_DIR="/usr/share/nginx/html/content"

# Download the initial JSON files
curl "https://wikirate.org/Answer/compact.json?limit=0&filter%5Bcompany_group%5D=~13479530&filter%5Bmetric_id%5D%5B%5D=6126450&filter%5Bmetric_id%5D%5B%5D=5780639&filter%5Bmetric_id%5D%5B%5D=5990097&filter%5Bmetric_id%5D%5B%5D=7624093&filter%5Bmetric_id%5D%5B%5D=7616258&filter%5Bmetric_id%5D%5B%5D=19884143&filter%5Byear%5D=latest" -o "$CONTENT_DIR/brand_answers.json"
curl "https://wikirate.org/~13479530+Company.json?item=nucleus" -o "$CONTENT_DIR/brands.json"
curl "https://wikirate.org/~5768810+Relationships.json?limit=999&filter%5Bcompany_group%5D=~13479530&filter%5Byear%5D=latest" -o "$CONTENT_DIR/sub_brands.json"
curl "https://wikirate.org/~20354046.json" -o "$CONTENT_DIR/country_list.json"
curl "https://wikirate.org/~5990097+Answers.json?limit=999&filter%5Bcompany_group%5D=~13479530&filter%5Byear%5D=latest" -o "$CONTENT_DIR/living_wage_scores.json"

# Extract country names from the content attribute of country_list.json
country_names=$(grep '"content":' "$CONTENT_DIR/country_list.json" | sed -E 's/.*"content":\[(.*)\].*/\1/' | tr -d '[]" ' | tr ',' '\n')

# Loop through each country name to make additional requests
for country_name in $country_names; do
    curl "https://wikirate.org/~7347357+Answers.json?limit=999&filter%5Bcountry%5D%5B%5D=$country_name&filter%5Byear%5D=latest" -o "$CONTENT_DIR/$country_name.json"
done