#!/bin/bash

# Make sure working dir exists
mkdir -p /var/log/exim/spoofcheck
rm -f /var/log/exim/spoofcheck/exim_ids
rm -f /var/log/exim/spoofcheck/exim_logs

# Get exim IDs
for i in $(grep -E "login:|plain:" /var/log/exim/mainlog | grep "<=" | awk '{print $3}')
        do echo $i >> /var/log/exim/spoofcheck/exim_ids
done

# Gather logs
for i in $(cat /var/log/exim/spoofcheck/exim_ids)
        do grep $i /var/log/exim/mainlog >> /var/log/exim/spoofcheck/exim_logs
done

# Start the fun
for i in $(cat /var/log/exim/spoofcheck/exim_ids)
        do
                LOGGEDIN=$(grep $i /var/log/exim/spoofcheck/exim_logs | awk -F'A=' '{print $2}' | awk '{print $1}' | head -1 | sed 's/login://' | sed 's/plain://')
                SENDER=$(grep $i /var/log/exim/spoofcheck/exim_logs | awk -F'<=' '{print $2}' | awk '{print $1}' | head -1)
                if [ "$LOGGEDIN" != "$SENDER" ]; then
                        echo "$LOGGEDIN sent mail as $SENDER" >> /var/log/exim/spoofcheck/spooflogs
                fi
        done
