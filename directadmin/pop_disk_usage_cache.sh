#!/bin/bash

config_file="/usr/local/directadmin/conf/directadmin.conf"
search_string="pop_disk_usage_cache"
new_line="pop_disk_usage_cache=1"

# Check if the string exists in the file
if grep -q "$search_string" "$config_file"; then
    echo "Pop usage disk cache already enabled."
else
    # Append the new line to the file
    echo "$new_line" >> "$config_file"

    # Restart the service
    systemctl restart directadmin

    echo "Pop usage disk cache enabled."
fi
