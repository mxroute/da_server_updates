#!/bin/bash

rm -f /etc/exim.acl_check_recipient.pre.conf
wget -O /etc/exim.acl_check_recipient.pre.conf https://raw.githubusercontent.com/mxroute/da_server_updates/refs/heads/master/exim/exim.acl_check_recipient.pre.conf
rm -f /etc/bannedspoofing
wget -O /etc/bannedspoofing https://raw.githubusercontent.com/mxroute/da_server_updates/refs/heads/master/exim/bannedspoofing
killall -9 exim && systemctl restart exim
