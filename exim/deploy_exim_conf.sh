#!/bin/bash

rm -f /etc/exim.conf.bak
mv /etc/exim.conf /etc/exim.conf.bak
wget https://raw.githubusercontent.com/mxroute/da_server_updates/master/exim/exim.conf -P /etc
killall -9 exim && systemctl restart exim
