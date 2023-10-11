#!/bin/bash

IDS=$(for i in $(exim -bp | grep -v "D " | grep -E '^[0-9]{1,2}h\s' | awk '{print $3}'); do grep $i /var/log/exim/mainlog | grep "Recipient address rejected: Domain not found"; done | awk '{print $3}' | uniq)

for a in $IDS; do exim -Mg $a; done
