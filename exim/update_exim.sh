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

# Fix problematic exim ACL

if grep -q "#deny message = HELO_IS_LOCAL_DOMAIN" /etc/exim.conf
then
        echo "Exim ACL already commented out."
else
        sed -i 's/deny message = HELO_IS_LOCAL_DOMAIN/#deny message = HELO_IS_LOCAL_DOMAIN/g' /etc/exim.conf
        sed -i 's/condition = ${if match_domain{$sender_helo_name/#condition = ${if match_domain{$sender_helo_name/g' /etc/exim.conf
        sed -i 's/hosts = ! +relay_hosts/#hosts = ! +relay_hosts/g' /etc/exim.conf
fi

# If we don't kill exim before restarting it we cause downtime, if we do we face the tiniest of risks. Least risky play is kill -9 + restart.

killall -9 exim && systemctl restart exim
