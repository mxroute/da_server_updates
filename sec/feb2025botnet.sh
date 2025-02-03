#!/bin/bash

# Get server's public IP
SERVER_IP=$(curl -4 -s ifconfig.me)

# Search Exim logs, strictly matching dotted decimal IP format
# Return list of IPs involved
grep -a -E "H=\(${SERVER_IP//./[.]}\)|authenticator failed for \(${SERVER_IP//./[.]}\)" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sed 's/://' | sort | uniq | grep -v 127.0.0.1

# Blackhole the IPs involved
for i in $(grep -a -E "H=\(${SERVER_IP//./[.]}\)|authenticator failed for \(${SERVER_IP//./[.]}\)" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sed 's/://' | sort | uniq | grep -v 127.0.0.1); do ip route add blackhole $i; done

# New list
for i in $(grep "Unauthenticated mail not allowed from this range" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq); do ip route add blackhole $i; done

# Another list
for i in $(grep "Relay not permitted" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sort | uniq); do ip route add blackhole $i; done

# Thank you, next
for i in $(grep "Relay not permitted" /var/log/exim/mainlog | awk -F'F=' '{print $1}' | grep -v -F "H=("  | grep -v "X=" | awk -F'\\[' '{print $2}' | sed 's/]//' | sort | uniq); do ip route add blackhole $i; done

# Unblock IPs belonging to customers caught in the crossfire
for i in $(cat /etc/unblockme); do ip route del blackhole $i; done

# Restart exim, this can't wait for procs to close naturally
killall -9 exim
systemctl restart exim
