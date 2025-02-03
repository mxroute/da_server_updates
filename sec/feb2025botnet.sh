#!/bin/bash

# Get server's public IP
SERVER_IP=$(curl -4 -s ifconfig.me)

# Search Exim logs, strictly matching dotted decimal IP format
# Return list of IPs involved
grep -a -E "H=\(${SERVER_IP//./[.]}\)|authenticator failed for \(${SERVER_IP//./[.]}\)" /var/log/exim/mainlog | awk -F'\\) \\[' '{print $2}' | awk '{print $1}' | sed 's/]//' | sed 's/://' | sort | uniq | grep -v 127.0.0.1
