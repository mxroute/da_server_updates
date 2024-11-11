#!/bin/bash

echo "" >> /etc/exim.acl_check_recipient.pre.conf
cat /root/da_server_updates/exim/exim.acl_check_recipient.pre.conf >> /etc/exim.acl_check_recipient.pre.conf
rm -f /etc/bannedspoofing
wget -O /etc/bannedspoofing https://raw.githubusercontent.com/mxroute/da_server_updates/refs/heads/master/exim/bannedspoofing
killall -9 exim && systemctl restart exim
