#!/bin/bash

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build rspamd


# Add custom rules
if [ -d "/etc/rspamd" ]
then
	rm -rf /etc/rspamd.bak
	cp -R /etc/rspamd /etc/rspamd.bak
	yum install git -y
	rm -rf /etc/rspamd/rspamd_rules
	cd /etc/rspamd
	git clone https://github.com/mxroute/rspamd_rules
	rm -rf lists
	rm -rf local.d
	rm -rf override.d
	mv rspamd_rules/lists .
	mv rspamd_rules/local.d .
	mv rspamd_rules/override.d .
else
	echo "Rspamd is not installed on this system."
fi

systemctl restart rspamd
killall -9 exim && systemctl restart exim
systemctl restart redis
