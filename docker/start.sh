#!/bin/sh

# Start nginx in the background
nginx -g "daemon off;" &

# Start supercronic to run cron jobs
/usr/local/bin/supercronic /fashionchecker/cronfile