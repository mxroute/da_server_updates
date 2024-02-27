#!/bin/bash

# Function to validate the domain format
validate_domain() {
  if [[ "$1" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
    return 0  # Valid
  else
    return 1  # Invalid
  fi
}

# ***** MAIN SCRIPT LOGIC *****

# Check for correct number of arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

domain="$1"

# Validate domain format
validate_domain "$domain"
if [ $? -ne 0 ]; then
  echo "Invalid domain format."
  exit 1
fi

# Add the domain to /etc/virtual/domains
# (Make sure this is the correct path for your system)
if ! grep -qFx "$domain" /etc/virtual/domains; then
  echo "Adding domain: $domain"
  echo "$domain" >> /etc/virtual/domains

else
  echo "Domain already exists in /etc/virtual/domains"
fi
