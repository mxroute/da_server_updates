#!/bin/bash

grep "mailbox for user is full" /var/log/exim/mainlog | awk -F'\*\*' '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -n | tail
