#!/bin/bash

config_file="/usr/local/directadmin/conf/directadmin.conf"

# Remove the line "pop_disk_usage_cache=1" if it exists
sed -i '/^pop_disk_usage_cache=1$/d' "$config_file"

# Check if the line "pop_disk_usage_dovecot_quota=0" exists
if grep -q "^pop_disk_usage_dovecot_quota=0$" "$config_file"; then
    # Change the line to "pop_disk_usage_dovecot_quota=1"
    sed -i 's/^pop_disk_usage_dovecot_quota=0$/pop_disk_usage_dovecot_quota=1/' "$config_file"
else
    # Check if the line "pop_disk_usage_dovecot_quota" exists at all
    if ! grep -q "^pop_disk_usage_dovecot_quota" "$config_file"; then
        # Add the line "pop_disk_usage_dovecot_quota=1" to the end of the file
        echo "pop_disk_usage_dovecot_quota=1" >> "$config_file"
    fi
fi

# Restart the directadmin service
systemctl restart directadmin
