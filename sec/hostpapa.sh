#!/bin/bash
# This script is step 1 in providing HostPapa with actionable abuse complaints about spam leaving their network

while read -r ip; do
  grep -w "$ip" /var/log/exim/mainlog*
done < /root/da_server_updates/sec/hostpapa_ips >> /root/da_server_updates/sec/hostpapa_logs
