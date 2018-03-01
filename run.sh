#!/usr/bin/env bash
if [ "$PRODUCTION" = true ] ; then
    echo " 0 24 * * *     /dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/conf" >> /etc/crontabs/root
    crond -c /etc/crontabs -f &
    nginx -c /dehydrated/config/nginx_dehydrated.conf -g 'daemon off;'
    /dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/conf
fi
/website_updater.sh
