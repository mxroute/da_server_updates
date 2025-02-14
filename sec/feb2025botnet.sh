#!/bin/bash

for i in $(grep "Relay not permitted" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq -c | sort -n | awk '$1 >= 30 && NF == 2' | awk '{print $2}'); do ip route add blackhole $i; done

for i in $(grep "Mail not accepted from default assigned hostnames" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq -c | sort -n | awk '$1 >= 30 && NF == 2' | awk '{print $2}'); do ip route add blackhole $i; done

for i in $(grep "Unauthenticated mail not allowed from this range" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq -c | sort -n | awk '$1 >= 30 && NF == 2' | awk '{print $2}'); do ip route add blackhole $i; done

for i in $(cat /etc/unblockme); do ip route del blackhole $i; done

killall -9 exim
systemctl restart exim
