#!/usr/bin/env bash
echo "* * * * *     /dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/conf > /dev/pts/1" >> /etc/crontabs/root
crond -c /etc/crontabs -f &
nginx -c /etc/nginx/nginx_dehydrated.conf -g 'daemon off;'
