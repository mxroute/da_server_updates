#!/bin/bash

# Get server's public IP
SERVER_IP=$(curl -s ifconfig.me)

# Search Exim logs, strictly matching dotted decimal IP format
# Use [.] to ensure only literal dots are matched within the parentheses
grep -a -E "H=\(${SERVER_IP//./[.]}\)|authenticator failed for \(${SERVER_IP//./[.]}\)" /var/log/exim/mainlog
