#!/bin/bash

# Set variables
SNAPPY_DIR="/var/www/html/snappy"
BACKUP_BASE="/root/backup/snappy"
BACKUP_DIR="${BACKUP_BASE}/snappy_backup_$(date +%Y%m%d_%H%M%S)"
LATEST_VERSION=$(curl -s https://api.github.com/repos/the-djmaze/snappymail/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Check if Snappy directory exists
if [ ! -d "$SNAPPY_DIR" ]; then
    echo "Error: Snappy directory not found at $SNAPPY_DIR"
    exit 1
fi

# Ensure backup base directory exists
if [ ! -d "$BACKUP_BASE" ]; then
    echo "Creating backup base directory: $BACKUP_BASE"
    mkdir -p "$BACKUP_BASE"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup base directory. Aborting."
        exit 1
    fi
fi

# Create backup
echo "Creating backup in $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create backup directory. Aborting."
    exit 1
fi
cp -R "$SNAPPY_DIR" "$BACKUP_DIR"

# Download latest version
echo "Downloading Snappy version $LATEST_VERSION..."
wget "https://github.com/the-djmaze/snappymail/releases/download/$LATEST_VERSION/snappymail-${LATEST_VERSION#v}.zip" -O /tmp/snappy_latest.zip

# Check if download was successful
if [ ! -f /tmp/snappy_latest.zip ]; then
    echo "Error: Failed to download the latest version. Aborting update."
    exit 1
fi

# Extract new version
echo "Extracting new version..."
unzip -q /tmp/snappy_latest.zip -d /tmp/snappy_update

# Preserve configuration and data
echo "Preserving configuration and data..."
cp "$SNAPPY_DIR/data/DATA.php" "/tmp/snappy_update/data/" 2>/dev/null
cp "$SNAPPY_DIR/data/_data_/default.ini" "/tmp/snappy_update/data/_data_/" 2>/dev/null
cp -R "$SNAPPY_DIR/data/_data_/" "/tmp/snappy_update/data/" 2>/dev/null

# Replace old version with new version
echo "Updating Snappy..."
rm -rf "$SNAPPY_DIR"
mv "/tmp/snappy_update" "$SNAPPY_DIR"

# Set correct permissions and ownership
echo "Setting correct permissions and ownership..."
chown -R webapps:webapps "$SNAPPY_DIR"
find "$SNAPPY_DIR" -type d -exec chmod 755 {} \;
find "$SNAPPY_DIR" -type f -exec chmod 644 {} \;

# Clean up
echo "Cleaning up..."
rm /tmp/snappy_latest.zip

echo "Snappy has been updated to version $LATEST_VERSION"
echo "A backup of the previous version is available at $BACKUP_DIR"
echo "Ownership of $SNAPPY_DIR has been set to webapps:webapps"
