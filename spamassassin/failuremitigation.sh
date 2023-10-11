#!/bin/bash
PTOKEN=$(cat /root/pushover_token)
PUSER=$(cat /root/pushover_user)
SERVER=$(hostname)

prev_count=0

count=$(grep "BSMTP input" /var/log/exim/mainlog | wc -l)

if [ -f /root/spamd_failure_alerted_today ] ; then

echo "Already alerted for this"

elif [ "$prev_count" -lt "$count" ] ; then

/usr/bin/curl -S -F "token=$PTOKEN" \
-F "user=$PUSER" \
-F "title=Spamd failure" \
-F "message=Spamd failed on $SERVER" https://api.pushover.net/1/messages.json
systemctl restart spamd

/usr/bin/touch /root/spamd_failure_alerted_today
/usr/bin/sed -i 's/BSMTP input/BSMTP_fixed/g' /var/log/exim/mainlog
rm -rf /root/spamd_failure_alerted_today

fi
