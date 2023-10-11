#!/bin/bash
# Logic to be used by an upcoming project

grep "Sender verify failed" /var/log/exim/mainlog | awk -F'F=' '{print $2}' | awk '{print $1}' | sort | uniq | awk -F'@' '{print $2}' | sed 's/>//' | sort | uniq
