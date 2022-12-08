#!/bin/bash

rm -f /etc/heloblocks
rm -f /etc/exim.acl_check_helo.pre.conf
cp /root/da_server_updates/exim/exim.acl_check_helo.pre.conf /etc
cp /root/da_server_updates/exim/heloblocks /etc
killall -9 exim
systemctl restart exim
