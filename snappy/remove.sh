#!/bin/bash

# Check if the directory exists
if [ -d "/var/www/html/snappy" ]; then
    echo "Directory /var/www/html/snappy exists. Removing it..."
    rm -rf /var/www/html/snappy
    
    if [ $? -eq 0 ]; then
        echo "Directory removed successfully."
    else
        echo "Error: Failed to remove directory."
        exit 1
    fi
else
    echo "Directory /var/www/html/snappy does not exist."
fi

# Create the symlink
echo "Creating symlink from /var/www/html/snappy to /var/www/html/roundcube..."
ln -s /var/www/html/roundcube /var/www/html/snappy

if [ $? -eq 0 ]; then
    echo "Symlink created successfully."
else
    echo "Error: Failed to create symlink."
    exit 1
fi

# Set ownership
echo "Setting ownership to webapps:webapps..."
chown -vh webapps: /var/www/html/snappy

if [ $? -eq 0 ]; then
    echo "Ownership set successfully."
    echo "Script completed successfully!"
else
    echo "Error: Failed to set ownership."
    exit 1
fi
