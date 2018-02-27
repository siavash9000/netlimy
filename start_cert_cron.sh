#!/usr/bin/env bash
nginx -c /etc/nginx/nginx_dehydrated.conf -g 'daemon off;' &
/dehydrated/dehydrated --register --accept-terms --config /dehydrated/config/
/dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/