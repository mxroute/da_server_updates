#!/bin/bash

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build exim

rm -f /etc/exim.variables.conf.custom
rm -f /etc/exim.easy_spam_fighter/variables.conf.custom
rm -f /etc/exim.strings.conf.custom
wget https://config.mxroute.com/update/exim/exim.variables.conf.custom -P /etc
wget https://config.mxroute.com/update/exim/easy/variables.conf.custom -P /etc/exim.easy_spam_fighter
wget https://config.mxroute.com/update/exim/exim.strings.conf.custom -P /etc

sh /usr/local/directadmin/custombuild/build exim_conf

# Fix exim ACL
if grep -q "#deny message = HELO_IS_LOCAL_DOMAIN" /etc/exim.conf
then
        echo "Exim ACL already commented out."
else
        sed -i 's/deny message = HELO_IS_LOCAL_DOMAIN/#deny message = HELO_IS_LOCAL_DOMAIN/g' /etc/exim.conf
        sed -i 's/condition = ${if match_domain{$sender_helo_name/#condition = ${if match_domain{$sender_helo_name/g' /etc/exim.conf
        sed -i 's/hosts = ! +relay_hosts/#hosts = ! +relay_hosts/g' /etc/exim.conf
fi

killall -9 exim && systemctl restart exim
