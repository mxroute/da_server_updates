#!/bin/bash
# Time to reduce obviously malicious traffic on our servers

for i in $(grep "H=(amazon.co.jp)" /var/log/exim/mainlog | awk '{print $4}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq); do ip route add blackhole $i; done

for i in $(grep 'H=.*\.beauty) ' /var/log/exim/mainlog | awk -F '\\) \\[' '{ print $2 }' | awk '{print $1}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq); do ip route add blackhole $i; done

for i in $(grep 'H=.*\.beauty ' /var/log/exim/mainlog | awk -F '\\) \\[' '{ print $2 }' | awk '{print $1}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq); do ip route add blackhole $i; done
