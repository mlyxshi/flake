#!/bin/sh
case "$1" in
    bound|renew)
        ip addr add "$ip/$mask" dev eth0
        [ "$mask" = "32" ] && onlink="onlink" || onlink=""
        ip route add default via "$router" dev eth0 $onlink
        for srv in $dns; do
            echo "nameserver $srv"
        done > /etc/resolv.conf
        ;;
esac