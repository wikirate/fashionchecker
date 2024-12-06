#!/bin/sh

# Start nginx in the background
nginx -g "daemon off;" &

# Run the script immediately for the first time
/fashionchecker/script/update_cached_data.sh

# Start supercronic to run cron jobs (updating cached data every 10 mins)
/usr/local/bin/supercronic /fashionchecker/cronfile