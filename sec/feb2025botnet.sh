#!/bin/bash

# Debug flag - set to 1 for debug mode, 0 for normal operation
DEBUG=0

# Get server's public IP
SERVER_IP=$(curl -4 -s ifconfig.me)

# Function to count occurrences and blackhole IPs with >100 matches
blackhole_frequent_offenders() {
    local pattern=$1
    local description=$2
    local log_file="/var/log/exim/mainlog"
    
    # Create a temporary file to store IP counts
    local tmp_file=$(mktemp)
    
    # Extract IPs and count occurrences
    grep -a "$pattern" "$log_file" | \
    awk -F'\\) \\[' '{print $2}' | \
    awk '{print $1}' | \
    sed 's/]//' | \
    sed 's/://' | \
    grep -v "127.0.0.1" | \
    grep -v '^[[:space:]]*$' | \
    sort | \
    uniq -c | \
    awk '$1 > 100 && $2 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {print $1, $2}' > "$tmp_file"
    
    if [ "$DEBUG" -eq 1 ]; then
        echo "=== $description ==="
        cat "$tmp_file"
        echo ""
    else
        # Add blackhole routes for frequent offenders
        while read -r count ip; do
            echo "Blocking IP $ip (count: $count) - $description"
            ip route add blackhole "$ip"
        done < "$tmp_file"
    fi
    
    rm "$tmp_file"
}

# Process different patterns
# First pattern - H= and authenticator failed
blackhole_frequent_offenders "H=\(${SERVER_IP//./[.]}\)|authenticator failed for \(${SERVER_IP//./[.]}\)" "Authentication Failures"

# Second pattern - Unauthenticated mail
blackhole_frequent_offenders "Unauthenticated mail not allowed from this range" "Unauthenticated Mail"

# Third pattern - Relay not permitted (first format)
blackhole_frequent_offenders "Relay not permitted" "Relay Not Permitted"

# Fourth pattern - Relay not permitted (second format)
if [ "$DEBUG" -eq 1 ]; then
    echo "=== Relay Not Permitted (Secondary Format) ==="
    grep "Relay not permitted" /var/log/exim/mainlog | \
    awk -F'F=' '{print $1}' | \
    grep -v -F "H=(" | \
    grep -v "X=" | \
    awk -F'\\[' '{print $2}' | \
    sed 's/]//' | \
    grep -v "127.0.0.1" | \
    grep -v '^[[:space:]]*$' | \
    sort | \
    uniq -c | \
    awk '$1 > 100 && $2 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {print $1, $2}'
    echo ""
else
    grep "Relay not permitted" /var/log/exim/mainlog | \
    awk -F'F=' '{print $1}' | \
    grep -v -F "H=(" | \
    grep -v "X=" | \
    awk -F'\\[' '{print $2}' | \
    sed 's/]//' | \
    grep -v "127.0.0.1" | \
    grep -v '^[[:space:]]*$' | \
    sort | \
    uniq -c | \
    awk '$1 > 100 && $2 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ {print $1, $2}' | \
    while read -r count ip; do
        echo "Blocking IP $ip (count: $count) - Relay Not Permitted (Secondary Format)"
        ip route add blackhole "$ip"
    done
fi

if [ "$DEBUG" -eq 0 ]; then
    # Unblock IPs belonging to customers caught in the crossfire
    while read -r ip; do
        echo "Unblocking whitelisted IP $ip"
        ip route del blackhole "$ip"
    done < /etc/unblockme

    # Restart exim
    echo "Restarting Exim service..."
    killall -9 exim
    systemctl restart exim
fi
