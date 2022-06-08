#!/bin/bash

# Rebuild exim

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build exim

# Refresh custom files with new copies

rm -f /etc/exim.variables.conf.custom
rm -f /etc/exim.easy_spam_fighter/variables.conf.custom
rm -f /etc/exim.strings.conf.custom
cp /root/da_server_updates/exim/exim.variables.conf.custom /etc
cp /root/da_server_updates/exim/easy/variables.conf.custom /etc/exim.easy_spam_fighter
cp /root/da_server_updates/exim/exim.strings.conf.custom /etc

# Rebuild exim config

sh /usr/local/directadmin/custombuild/build exim_conf

# Add transport include

rm -f /etc/exim.transports.pre.conf
cp /root/da_server_updates/exim/exim.transports.pre.conf -P /etc

# Add router include

rm -f /etc/exim.routers.pre.conf
cp /root/da_server_updates/exim/exim.routers.pre.conf -P /etc

# Deploy custom exim.conf

rm -f /etc/exim.conf.bak
mv /etc/exim.conf /etc/exim.conf.bak
cp /root/da_server_updates/exim/exim.conf -P /etc

# If we don't kill exim before restarting it we cause downtime, if we do we face the tiniest of risks. Least risky play is kill -9 + restart.

killall -9 exim && systemctl restart exim
