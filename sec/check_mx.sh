#!/bin/bash

# Check if input file is given
if [ -z "$1" ]; then
  echo "Please provide a file containing list of domains as input."
  exit 1
fi

# Create a temporary file for domains with MX records
temp_file=$(mktemp)

# Iterate through each domain in the input file
while read -r domain; do
  # Use nslookup to check if the domain has MX record
  if nslookup -q=mx "$domain" 8.8.8.8 >/dev/null; then
    echo "$domain has MX record. Removing from input file."
    # Add domain to temporary file
    echo "$domain" >> "$temp_file"
  fi
done < "$1"

# Replace the input file with the temporary file
mv "$temp_file" "$1"
