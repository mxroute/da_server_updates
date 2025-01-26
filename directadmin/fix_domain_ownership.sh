#!/bin/bash

# Log file for operations
LOG_FILE="/var/log/domain_ownership_fix.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_message "Error: This script must be run as root"
    exit 1
fi

# Check if the users directory exists
if [[ ! -d "/usr/local/directadmin/data/users" ]]; then
    log_message "Error: DirectAdmin users directory not found"
    exit 1
fi

# Initialize counters
processed_items=0
error_count=0

# Process each user
log_message "Starting ownership fix process..."

for USER in $(ls /usr/local/directadmin/data/users); do
    user_domain_dir="/usr/local/directadmin/data/users/$USER/domains"
    
    if [[ -d "$user_domain_dir" ]]; then
        log_message "Processing domains directory for user: $USER"
        
        # Change ownership of the domains directory and all contents recursively
        if chown -R diradmin:diradmin "$user_domain_dir" 2>/dev/null; then
            count=$(find "$user_domain_dir" -type f -o -type d | wc -l)
            processed_items=$((processed_items + count))
            log_message "Successfully processed $count items for user $USER"
        else
            error_count=$((error_count + 1))
            log_message "Error: Failed to process items for user $USER"
        fi
    else
        log_message "Warning: Domains directory not found for user $USER"
    fi
done

# Print summary
log_message "Process completed:"
log_message "Total items processed (files and directories): $processed_items"
log_message "Total errors encountered: $error_count"

exit 0
