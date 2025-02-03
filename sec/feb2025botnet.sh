#!/bin/bash

# Get server's public IP
SERVER_IP=$(curl -s ifconfig.me)

# Search Exim logs for both H= connections and authentication failures from our IP
grep -E "H=\(${SERVER_IP}\)|authenticator failed for \(${SERVER_IP}\)" /var/log/exim/mainlog
