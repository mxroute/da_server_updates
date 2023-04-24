#!/bin/bash

rm -f /etc/exim.strings.conf.custom
cp /root/da_server_updates/exim/exim.strings.conf.custom /etc
killall -9 exim
systemctl restart exim
systemctl status exim | grep Active:
