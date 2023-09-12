#!/bin/bash
# Sincerely, fuck these networks and the people who run them
# These networks are not only home to massive amounts of spammers, but also to overall attackers
# Blocking these networks will dramatically reduce brute force events on our servers,
# and also somewhat mitigate against users who have had their password made public through some compromise across the internet
# by reducing the malicious networks that can be used to test passwords from publicized databases
# against customer email accounts

ASNS="19624 43260 29470 213200 138687 209605 204843 203576 132372 202468 56485 398646 211237 136647 202306 205090 211252 213035 28098 29182 399471 43830 49392 49870 62212 211619 200019 43811 51447 208911 12695 136800 19531 34665"

for a in $ASNS
  do
    for b in $(whois -h whois.radb.net -- "-i origin AS$a" | grep 'route:' | awk '{print $2}')
      do ip route add blackhole $b
    done
done
