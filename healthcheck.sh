if test "$(ls -A '/etc/dehydrated/certs')"; then
    echo "/etc/dehydrated/certs is not empty ->healthy"
    exit 0
else
    echo "/etc/dehydrated/certs is empty ->unhealthy"
    exit 1
fi
