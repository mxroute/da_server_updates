#!/bin/bash
# Because fuck us I guess

# Get server's public IP
SERVER_IP=$(curl -s ifconfig.me)

# Search Exim logs for connections from our IP
grep "H=(${SERVER_IP})" /var/log/exim/mainlog
