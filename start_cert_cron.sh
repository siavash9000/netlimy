#!/usr/bin/env bash
nginx -c /etc/nginx/nginx_dehydrated.conf -g 'daemon off;' &
/dehydrated/dehydrated --register --accept-terms --config /etc/dehydrated/config/conf
/dehydrated/dehydrated --cron --accept-terms --config /etc/dehydrated/config/conf