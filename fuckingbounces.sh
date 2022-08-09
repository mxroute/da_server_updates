#!/bin/bash

# We don't forward emails that consistently get rejected, and that leads to bounces.
# We're not ready to pick and choose who to send bounces to at the source server,
# so the bounces stack up even though we're not delivering bounces to Google and Facebook.
# This is a bandaid.

for i in $(exim -bp | grep noreply-dmarc-support -B 1 | awk '{print $3}'); do exim -Mrm $i; done
for i in $(exim -bp | grep facebookmail.com -B 1 | awk '{print $3}'); do exim -Mrm $i; done
for i in $(exim -bp | grep "<>" | awk '{print $3}'); do exim -Mrm $i ;done
