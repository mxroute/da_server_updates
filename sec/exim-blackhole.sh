#!/bin/bash

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root to add ip routes"
    exit 1
fi

# Set up logging
LOG_FILE="/var/log/exim-blackhole.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "Starting Exim log monitor at $(date)"

# Function to check if IP is already blackholed
is_blackholed() {
    local ip=$1
    ip route show | grep -q "blackhole $ip"
    return $?
}

# Function to add IP to blackhole
blackhole_ip() {
    local ip=$1
    if ! is_blackholed "$ip"; then
        ip route add blackhole "$ip"
        echo "$(date): Blackholed IP: $ip"
    fi
}

# Main processing loop
tail -F /var/log/exim/mainlog | while read -r line; do
    if echo "$line" | grep -q "H=.*51.15.184" && echo "$line" | grep -q "rejected RCPT.*Unauthenticated mail"; then
        # Extract the real IP (the second IP in square brackets)
        ip=$(echo "$line" | grep -o '\[[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\]' | tail -n1 | tr -d '[]')
        if [[ -n "$ip" ]] && [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            blackhole_ip "$ip"
        fi
    fi
done
