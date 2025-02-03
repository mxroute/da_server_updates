#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Check if required files exist
if [[ ! -f "/root/da_server_updates/sec/botnet.list" ]]; then
    echo "Error: botnet.list not found"
    exit 1
fi

if [[ ! -f "/var/log/exim/mainlog" ]]; then
    echo "Error: exim mainlog not found"
    exit 1
fi

# Process each IP
while IFS= read -r ip; do
    # Skip empty lines or malformed IPs
    if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        continue
    fi

    # Check if IP appears in log with "in:"
    if grep -F "$ip" /var/log/exim/mainlog | grep -F "in:"; then
        # Remove IP from blackhole routing
        ip route del blackhole "$ip" 2>/dev/null

        # Add IP to unblock list if not already present
        if ! grep -q "^$ip$" /etc/unblockme 2>/dev/null; then
            echo "$ip" >> /etc/unblockme
        fi

        echo "Processed IP: $ip"
    fi
done < "/root/da_server_updates/sec/botnet.list"

echo "IP processing completed"
