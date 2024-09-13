#!/bin/bash

# File containing the log
LOG_FILE="/var/log/exim/mainlog"

# File containing whitelisted login addresses
WHITELIST_FILE="/var/log/exim/whitelist.txt"

# Output log file
OUTPUT_LOG="/var/log/exim/sender_audit.log"

# Minimum number of unique sender addresses to flag
MIN_SENDER_ADDRESSES=2

# Clear the previous log
find /var/log/exim -name sender_audit.log -delete

# Check if whitelist file exists, create if it doesn't
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "Whitelist file not found. Creating an empty whitelist file."
    touch "$WHITELIST_FILE"
fi

# Function to get domain from email address
get_domain() {
    echo "$1" | awk -F'@' '{print $2}'
}

# Get unique login addresses, excluding whitelisted ones
login_addresses=$(grep -a -E '(login:|plain:)' "$LOG_FILE" | awk -F'in:' '{print $2}' | awk '{print $1}' | sort | uniq | grep -vf "$WHITELIST_FILE")

# Function to get sender addresses for a given login, excluding those with matching domains
get_sender_addresses() {
    local login="$1"
    local login_domain=$(get_domain "$login")
    grep -a "in:$login" "$LOG_FILE" | awk -F'<=' '{print $2}' | awk '{print $1}' | sort | uniq | while read -r sender; do
        sender_domain=$(get_domain "$sender")
        if [ "$sender_domain" != "$login_domain" ]; then
            echo "$sender"
        fi
    done
}

# Process each login address and write results to the output log
{
    echo "SMTP Sender Audit Log - $(date)"
    echo "=================================="
    
    while IFS= read -r login; do
        sender_addresses=$(get_sender_addresses "$login")
        sender_count=$(echo "$sender_addresses" | wc -l)
        
        if [ "$sender_count" -ge "$MIN_SENDER_ADDRESSES" ]; then
            echo -n "User $login sent mail as: "
            echo "$sender_addresses" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g'
            echo " (Total: $sender_count)"
        fi
    done <<< "$login_addresses"
    
    echo "=================================="
} >> "$OUTPUT_LOG"
