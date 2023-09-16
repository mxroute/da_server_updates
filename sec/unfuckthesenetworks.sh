#!/bin/bash
# These networks have been deemed clean after previously having been considered to not be so, and are now being unfucked on our network.

ASNS="43811"

for a in $ASNS
  do
    for b in $(whois -h whois.radb.net -- "-i origin AS$a" | grep 'route:' | awk '{print $2}')
      do ip route del blackhole $b
    done
done
