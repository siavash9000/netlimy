#!/usr/bin/env bash
echo "PRODUCTION=$PRODUCTION"
if [ "$PRODUCTION" == "true" ] ; then
    echo "adding dehydrated tor cron"
    echo " 0 24 * * *     /dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/conf" >> /etc/crontabs/root
    crond -c /etc/crontabs -f &
    echo "starting nginx"
    nginx -c /dehydrated/config/nginx_dehydrated.conf -g 'daemon off;' &
    echo "creating /domains.txt"
    echo "$DOMAINS" > /domains.txt
    echo "starting dehydrated"
    /dehydrated/dehydrated --cron --accept-terms --config /dehydrated/config/conf
fi
/website_updater.sh
