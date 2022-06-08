#!/bin/bash

echo "" >> /etc/exim.acl_check_recipient.pre.conf
cat /root/da_server_updates/exim/exim.acl_check_recipient.pre.conf >> /etc/exim.acl_check_recipient.pre.conf
killall -9 exim && systemctl restart exim
