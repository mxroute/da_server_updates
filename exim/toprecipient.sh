#!/bin/bash

grep -a "> for" /var/log/exim/mainlog | awk -F'> for' '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -n | tail -1
