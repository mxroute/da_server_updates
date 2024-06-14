#!/bin/bash

# Step 1: Change LF_DISTSMTP to 0
sed -i '/^LF_DISTSMTP =/c\LF_DISTSMTP = "0"' /etc/csf/csf.conf

# Step 2: Restart CSF
csf -r

# Step 3: Unban any IPs caught in this rule
for i in $(grep "distributed smtpauth" csf.deny | awk '{print $1}'); do csf -dr $i; done
