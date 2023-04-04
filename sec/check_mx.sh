#!/bin/bash

# Check if input file is given
if [ -z "$1" ]; then
  echo "Please provide a file containing list of domains as input."
  exit 1
fi

# Create a temporary file for domains without MX records
temp_file=$(mktemp)

# Iterate through each domain in the input file
while read -r domain; do
  # Use dig to check if the domain has MX record
  if dig +nocmd +noall +answer -t MX "$domain" "@8.8.8.8" | grep -q MX; then
    # Remove domain from input file
    echo "$domain has MX record. Removing from input file."
  else
    # Add domain to temporary file
    echo "$domain" >> "$temp_file"
  fi
done < "$1"

# Replace the input file with the temporary file
mv "$temp_file" "$1"
