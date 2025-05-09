#!/bin/bash

grep "mailbox for user is full" /var/log/exim/mainlog | awk -F'TO:' '{print $2}' | awk '{print $1}' | sed 's/<//' | sed 's/>://' | sort | uniq -c | sort -n | tail -25 | awk '{print $2}' >> /etc/overquota
