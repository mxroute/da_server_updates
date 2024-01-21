#!/bin/bash

# Define variables
PUSHTOKEN=$(cat /root/pushover_token)
PUSHUSER=$(cat /root/pushover_user)
HOSTNAME=$(hostname)

# Step 1: Check email queue
email_queue=$(exim -bpc)
if [ "$email_queue" -le 500 ]; then
  exit
fi

# Step 2: Check if "dns_already_alerted" file is more than 12 hours old
if [ -e /root/dns_already_alerted ]; then
  file_age=$(find /root/dns_already_alerted -mmin +720)
  if [ -n "$file_age" ]; then
    /usr/bin/curl -S -F "token=$PUSHTOKEN" \
    -F "user=$PUSHUSER" \
    -F "title=$HOSTNAME dns_already_alerted old" \
    -F "message=Delete dns_already_alerted on $HOSTNAME" https://api.pushover.net/1/messages.json
  else
    exit
  fi
fi

# Step 3: Check exim logs for "failed in smart_route router"
log_lines=$(grep "filtergroup" /var/log/exim/mainlog | tail -n 1000)
if [ -z "$(echo "$log_lines" | grep "failed in smart_route router")" ]; then
  /usr/bin/curl -S -F "token=$PUSHTOKEN" \
  -F "user=$PUSHUSER" \
  -F "title=Elevated Mail Queue" \
  -F "message=Elevated queue on $HOSTNAME" https://api.pushover.net/1/messages.json
else
  systemctl restart unbound
fi

# Step 4: Check DNS resolution for filtergroup.mxroute.com
if dig +short @localhost filtergroup.mxroute.com; then
  for i in $(exim -bp | awk '{print $3}'); do exim -M $i; done
  /usr/bin/curl -S -F "token=$PUSHTOKEN" \
  -F "user=$PUSHUSER" \
  -F "title=Restarted unbound on $HOSTNAME" \
  -F "message=Restarted unbound on $HOSTNAME" https://api.pushover.net/1/messages.json
else
  /usr/bin/curl -S -F "token=$PUSHTOKEN" \
  -F "user=$PUSHUSER" \
  -F "title=$HOSTNAME Fucked" \
  -F "priority=2" \
  -F "expire=300" \
  -F "retry=30" \
  -F "message=$HOSTNAME experiencing DNS issue" https://api.pushover.net/1/messages.json
fi

# Step 5: Create "dns_already_alerted" file
touch /root/dns_already_alerted
