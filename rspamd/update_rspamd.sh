#!/bin/bash

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build rspamd


# Add custom rules
if [ -d "/etc/rspamd" ]
then
	rm -rf /etc/rspamd.bak
	cp -R /etc/rspamd /etc/rspamd.bak
	yum install git -y
	git --work-tree=/etc/rspamd --git-dir=/etc/rspamd/.git init
	git --work-tree=/etc/rspamd --git-dir=/etc/rspamd/.git remote add origin https://github.com/mxroute/rspamd_rules
	rm -rf /etc/rspamd/local.d
	rm -rf /etc/rspamd/maps
	rm -rf /etc/rspamd/maps.d
	rm -rf /etc/rspamd/override.d
	git --work-tree=/etc/rspamd --git-dir=/etc/rspamd/.git reset --hard
	git --work-tree=/etc/rspamd --git-dir=/etc/rspamd/.git pull origin master
else
	echo "Rspamd is not installed on this system."
fi

# Make rspamd run for everyone
rm -f /etc/exim/rspamd/check_message.conf
wget https://config.mxroute.com/update/rspamd/check_message.conf -P /etc/exim/rspamd

systemctl restart rspamd
killall -9 exim && systemctl restart exim
systemctl restart redis
