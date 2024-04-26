#!/bin/bash
# This is a temporary aid to our brute force protection system as we work on modifying how the system works

for i in $(grep "Incorrect authentication data" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]://' | grep -v "159.69.116.204" | grep -v "5.161.52.248" | grep -v "127.0.0.1" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq -c | sort -n | tail -100 | awk '{print $2}'); do ip route add blackhole $i; done
