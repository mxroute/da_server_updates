#!/bin/bash
# Sincerely, fuck these networks and the people who run them
# These networks are not only home to massive amounts of spammers, but also to overall attackers
# Blocking these networks will dramatically reduce brute force events on our servers,
# and also somewhat mitigate against users who have had their password made public through some compromise across the internet
# by reducing the malicious networks that can be used to test passwords from publicized databases
# against customer email accounts

ASNS="62838"

for a in $ASNS
  do
    for b in $(whois -h whois.radb.net -- "-i origin AS$a" | grep 'route:' | awk '{print $2}')
      do ip route del blackhole $b
    done
done
