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
cert_files_processed=0
error_count=0

# Process each user
log_message "Starting ownership fix process..."

for USER in $(ls /usr/local/directadmin/data/users); do
    user_domain_dir="/usr/local/directadmin/data/users/$USER/domains"
    
    if [[ -d "$user_domain_dir" ]]; then
        log_message "Processing domains directory for user: $USER"
        
        # First, handle certificate and key files
        while IFS= read -r -d '' file; do
            if chown diradmin:access "$file" 2>/dev/null; then
                cert_files_processed=$((cert_files_processed + 1))
                log_message "Set special ownership for: $file"
            else
                error_count=$((error_count + 1))
                log_message "Error: Failed to set special ownership for: $file"
            fi
        done < <(find "$user_domain_dir" -type f \( \
            -name "*.cacert" -o \
            -name "*.cert" -o \
            -name "*.cert.combined" -o \
            -name "*.key" -o \
            -name "*.cert.creation_time" \
        \) -print0)
        
        # Then handle all remaining files and directories
        while IFS= read -r -d '' item; do
            # Skip files that we already processed above
            if [[ "$item" =~ \.(cacert|cert|cert\.combined|key|cert\.creation_time)$ ]]; then
                continue
            fi
            
            if chown diradmin:diradmin "$item" 2>/dev/null; then
                processed_items=$((processed_items + 1))
            else
                error_count=$((error_count + 1))
                log_message "Error: Failed to process: $item"
            fi
        done < <(find "$user_domain_dir" -print0)
        
        log_message "Completed processing for user $USER"
    else
        log_message "Warning: Domains directory not found for user $USER"
    fi
done

# Print summary
log_message "Process completed:"
log_message "Total regular items processed: $processed_items"
log_message "Total certificate/key files processed: $cert_files_processed"
log_message "Total errors encountered: $error_count"

exit 0
