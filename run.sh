#!/usr/bin/env bash
echo "PRODUCTION=$PRODUCTION"
if [ "$PRODUCTION" == "true" ] ; then
    echo "performing PRODUCTION stuff"
    echo " 0 24 * * *     /dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/conf" >> /etc/crontabs/root
    crond -c /etc/crontabs -f &
    nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
    /dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/conf
fi
/website_updater.sh
