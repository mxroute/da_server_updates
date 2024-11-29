#!/bin/bash

# Script to replace the value 7200 with 9600 in limit files under /etc/virtual
# Usage: ./update_limits.sh

# Base directory where domain directories are located
BASE_DIR="/etc/virtual"

# Counter for modified files
modified_count=0

# Function to check if a file contains only a number
is_number_only() {
    local content=$(cat "$1")
    if [[ "$content" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Main loop through all domain directories
for domain_dir in "$BASE_DIR"/*/; do
    if [ ! -d "$domain_dir" ]; then
        continue
    fi

    limit_dir="${domain_dir}limit"
    if [ ! -d "$limit_dir" ]; then
        continue
    fi

    # Process files in the limit directory
    for limit_file in "$limit_dir"/*; do
        if [ ! -f "$limit_file" ]; then
            continue
        fi

        # Check if file contains only a number
        if is_number_only "$limit_file"; then
            # Check if the content is 7200
            if [ "$(cat "$limit_file")" = "7200" ]; then
                # Backup the file first
                cp "$limit_file" "${limit_file}.bak"
                
                # Replace the content
                echo "9600" > "$limit_file"
                
                echo "Updated: $limit_file"
                ((modified_count++))
            fi
        else
            echo "Warning: Skipping $limit_file - contains non-numeric content"
        fi
    done
done

echo "9600" > /etc/virtual/user_limit
echo "Process complete. Modified $modified_count files."
