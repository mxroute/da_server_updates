#!/bin/bash

for i in $(grep -a "Relay not permitted" /var/log/exim/mainlog | awk -F' \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq -c | sort -n | awk '$1 >= 100 && NF == 2' | awk '{print $2}'); do ip route add blackhole $i; done

for i in $(grep -a "Mail not accepted from default assigned hostnames" /var/log/exim/mainlog | awk -F' \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq -c | sort -n | awk '$1 >= 100 && NF == 2' | awk '{print $2}'); do ip route add blackhole $i; done

for i in $(grep -a "Unauthenticated mail not allowed from this range" /var/log/exim/mainlog | awk -F' \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq -c | sort -n | awk '$1 >= 100 && NF == 2' | awk '{print $2}'); do ip route add blackhole $i; done

for i in $(grep -a "is not authorized to send mail from" /var/log/exim/mainlog | awk -F' \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq -c | sort -n | awk '$1 >= 100 && NF == 2' | awk '{print $2}'); do ip route add blackhole $i; done

for i in $(grep -a "Too many failed recipients" /var/log/exim/mainlog | awk -F' \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq); do ip route add blackhole $i; done

for i in $(grep "Google Cloud has conditional access" /var/log/exim/mainlog | awk -F' \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq); do ip route add blackhole $i; done

for i in $(cat /etc/unblockme); do ip route del blackhole $i; done

for i in $(cat /etc/susranges_whitelist); do ip route del blackhole $i; done

#killall -9 exim
#systemctl restart exim
