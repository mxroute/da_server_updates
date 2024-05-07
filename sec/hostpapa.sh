#!/bin/bash
# This script is step 1 in providing HostPapa with actionable abuse complaints about spam leaving their network

grep -wF -f /root/da_server_updates/sec/hostpapa_ips /var/log/exim/mainlog* >> /root/da_server_updates/sec/hostpapa_logs
