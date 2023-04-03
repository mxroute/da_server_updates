#!/bin/bash

# Check if input file is given
if [ -z "$1" ]; then
  echo "Please provide a file containing list of domains as input."
  exit 1
fi

# Iterate through each domain in the input file
while read -r domain; do
  # Use nslookup to check if the domain has MX record
  if nslookup -q=mx "$domain" 8.8.8.8 >/dev/null; then
    echo "$domain"
  fi
done < "$1"
