#!/bin/bash

# Rebuild exim

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build exim

# Refresh custom files with new copies

rm -f /etc/exim.variables.conf.custom
rm -f /etc/exim.easy_spam_fighter/variables.conf.custom
rm -f /etc/exim.strings.conf.custom
wget https://config.mxroute.com/update/exim/exim.variables.conf.custom -P /etc
wget https://config.mxroute.com/update/exim/easy/variables.conf.custom -P /etc/exim.easy_spam_fighter
wget https://config.mxroute.com/update/exim/exim.strings.conf.custom -P /etc

# Rebuild exim config

sh /usr/local/directadmin/custombuild/build exim_conf

# Add transport include

rm -f /etc/exim.transports.pre.conf
wget https://raw.githubusercontent.com/mxroute/da_server_updates/master/exim/exim.transports.pre.conf -P /etc

# Add router include

rm -f /etc/exim.routers.pre.conf
wget https://raw.githubusercontent.com/mxroute/da_server_updates/master/exim/exim.routers.pre.conf -P /etc

# Deploy custom exim.conf

rm -f /etc/exim.conf.bak
mv /etc/exim.conf /etc/exim.conf.bak
wget https://raw.githubusercontent.com/mxroute/da_server_updates/master/exim/exim.conf -P /etc

# If we don't kill exim before restarting it we cause downtime, if we do we face the tiniest of risks. Least risky play is kill -9 + restart.

killall -9 exim && systemctl restart exim
