#!/bin/bash
# This script finds emails in the exim logs that come from subdomains and Google servers. No reason.

LOG_FILE="/var/log/exim/mainlog"
SUBDOMAIN_PATTERN="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}"
GOOGLE_SERVER_PATTERN="H=[a-zA-Z0-9.-]+\.google\.com"
IGNORE_PATTERN="bounces.google.com"

rm -f /var/log/exim/filtered_log_entries.txt

if [ ! -f "$LOG_FILE" ]; then
  echo "Log file not found: $LOG_FILE"
  exit 1
fi

grep -E "$SUBDOMAIN_PATTERN" "$LOG_FILE" | grep -E "$GOOGLE_SERVER_PATTERN" | grep -v "$IGNORE_PATTERN" | while read -r line ; do
  sender=$(echo "$line" | grep -oP '(?<=<= )[^\s]+')
  domain=$(echo "$sender" | awk -F'@' '{print $2}')
  if [[ $domain == *.*.* ]]; then
    echo "$line" >> /var/log/exim/filtered_log_entries.txt
  fi
done

if [ -s filtered_log_entries.txt ]; then
  echo "Filtered log entries saved to filtered_log_entries.txt:"
  cat filtered_log_entries.txt
else
  echo "No matching log entries found."
fi
