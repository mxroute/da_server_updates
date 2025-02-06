#!/bin/bash

# Define constants
CONFIG_FILE="/usr/local/directadmin/conf/directadmin.conf"
SEARCH_STRING="disk_usage_suspend"
APPEND_STRING="disk_usage_suspend=1"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_message "Error: This script must be run as root"
    exit 1
fi

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_message "Error: Configuration file $CONFIG_FILE not found"
    exit 1
fi

# Check if file is readable
if [[ ! -r "$CONFIG_FILE" ]]; then
    log_message "Error: Cannot read configuration file $CONFIG_FILE"
    exit 1
fi

# Check if file is writable
if [[ ! -w "$CONFIG_FILE" ]]; then
    log_message "Error: Cannot write to configuration file $CONFIG_FILE"
    exit 1
fi

# Search for the string in the config file
if grep -q "^${SEARCH_STRING}" "$CONFIG_FILE"; then
    log_message "Setting '$SEARCH_STRING' already exists in $CONFIG_FILE"
    exit 0
else
    # Append the string to the file
    log_message "Appending '$APPEND_STRING' to $CONFIG_FILE"
    echo "$APPEND_STRING" >> "$CONFIG_FILE"
    
    if [[ $? -ne 0 ]]; then
        log_message "Error: Failed to append to $CONFIG_FILE"
        exit 1
    fi
    
    # Restart DirectAdmin
    log_message "Restarting DirectAdmin services"
    killall -9 directadmin
    systemctl restart directadmin
    
    if [[ $? -ne 0 ]]; then
        log_message "Error: Failed to restart DirectAdmin services"
        exit 1
    fi
    
    log_message "Configuration updated and services restarted successfully"
fi

exit 0
