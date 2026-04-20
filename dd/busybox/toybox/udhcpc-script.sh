#!/bin/sh
case "$1" in
    bound|renew)
        ip addr add "$ip/$subnet" dev eth0
        [ "$subnet" = "32" ] && ip route via "$router" dev eth0 
        ip route add default via "$router" dev eth0 
        for srv in $dns; do
            echo "nameserver $srv"
        done > /etc/resolv.conf
        ;;
esac