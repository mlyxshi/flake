#!/bin/sh
case "$1" in
    bound)
        ip addr add "$ip/$subnet" dev eth0
        ip route add "$router" dev eth0 
        ip route add default via "$router"
        for srv in $dns; do
            echo "nameserver $srv"
        done > /etc/resolv.conf
        ;;
esac