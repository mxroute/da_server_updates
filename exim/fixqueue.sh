#!/bin/bash

# Problem statement:
# When the filter server rejects enough emails, exim thinks the filter server is down and stops trying to send mail to it until retry time.
#
# Temporary solution:
# Find when exim has done this and force a queue run

# Set the time limit to 15 minutes ago
time_limit=$(date +%s --date='15 minutes ago')

# Search the exim log for "filtergroup" and only show entries from the last 15 minutes
matches=$(grep -a "filtergroup" /var/log/exim/mainlog | while read line ; do
  timestamp=$(echo $line | awk '{print $1,$2}' | xargs -I {} date -d {} +%s)
  if [ $timestamp -ge $time_limit ]; then
    echo $line
  fi
done)

# check if matches are found
if [ -z "$matches" ]; then
  echo "Exim needs a kick. Forcing queue run."
  before_count=$(exim -bpc)
  current_time=$(date +"%Y-%m-%d %T")
  sh /root/da_server_updates/runqueue.sh
  after_count=$(exim -bpc)
  echo "Script run at $current_time. Emails: $((after_count - before_count))" >> /root/fixqueue_logs
else
  echo "Exim is working fine right now."
fi
