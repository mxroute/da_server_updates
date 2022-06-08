#!/bin/bash

# This is a work in progress for deploying new MXroute servers

# Variables
HOSTNAME=$1
IFACENAME=$(route | grep default | awk '{print $8}')
IP4=$(/sbin/ip -o -4 addr list $IFACENAME | awk '{print $4}' | cut -d/ -f1)

# Prep for scripts

apt install git net-tools -y
cd /root && git clone https://github.com/mxroute/da_server_updates
for bashscript in $(find /root/da_server_updates ".sh" | grep -v ".git"); do chmod +x $bashscript; done

# Set hostname
hostnamectl set-hostname $HOSTNAME

# Install DirectAdmin

wget https://www.directadmin.com/setup.sh
chmod 755 setup.sh
./setup.sh auto

# Set hostname SSL

cd /usr/local/directadmin/scripts
./letsencrypt.sh request_single $HOSTNAME 4096

cd /usr/local/directadmin
./directadmin set ssl 1
./directadmin set carootcert /usr/local/directadmin/conf/carootcert.pem
./directadmin set ssl_redirect_host $HOSTNAME
service directadmin restart

# Setup custom subdomains

mkdir -p /usr/local/directadmin/data/templates/custom

cat >> /usr/local/directadmin/data/templates/custom/virtual_host2.conf.CUSTOM.4.post <<EOL
</VirtualHost>
<VirtualHost |IP|:|PORT_80| |MULTI_IP|>
   ServerName webmail.|DOMAIN|
   ServerAdmin |ADMIN|
   DocumentRoot /var/www/html/roundcube
   CustomLog /var/log/httpd/domains/|DOMAIN|.bytes bytes
   CustomLog /var/log/httpd/domains/|DOMAIN|.log combined
   ErrorLog /var/log/httpd/domains/|DOMAIN|.error.log
   <IfModule !mod_ruid2.c>
       SuexecUserGroup webapps webapps
   </IfModule>
EOL

cat >> /usr/local/directadmin/data/templates/custom/virtual_host2_secure.conf.CUSTOM.4.post <<EOL
</VirtualHost>
<VirtualHost |IP|:|PORT_443| |MULTI_IP|>
   ServerName webmail.|DOMAIN|
   ServerAdmin |ADMIN|
   DocumentRoot /var/www/html/roundcube

   SSLEngine on
   SSLCertificateFile |CERT|
   SSLCertificateKeyFile |KEY|
   |CAROOT|

   CustomLog /var/log/httpd/domains/|DOMAIN|.bytes bytes
   CustomLog /var/log/httpd/domains/|DOMAIN|.log combined
   ErrorLog /var/log/httpd/domains/|DOMAIN|.error.log
   <IfModule !mod_ruid2.c>
       SuexecUserGroup webapps webapps
   </IfModule>
EOL

# Update custombuild

cd /usr/local/directadmin
mv custombuild custombuild_1.x
wget -O custombuild.tar.gz http://files.directadmin.com/services/custombuild/2.0/custombuild.tar.gz
tar xvzf custombuild.tar.gz
cd custombuild
./build
./build all d
./build rewrite_confs

# Set LE defaults

cd /usr/local/directadmin
./directadmin set letsencrypt_list mail:webmail
./directadmin set letsencrypt_list_selected mail:webmail
./directadmin set letsencrypt_max_requests_per_week 20
./directadmin set letsencrypt_multidomain_cert 2
./directadmin set letsencrypt_renewal_success_notice 1

# Custom RBLs

cat >> /etc/exim.strings.conf.custom <<EOL
RBL_DNS_LIST==bl.mxrbl.com
EOL

# Custom Exim variables

cp /root/da_server_updates/exim/exim.variables.conf.custom /etc

# Mail SNI

cd /usr/local/directadmin
echo mail_sni=1 >> conf/directadmin.conf
service directadmin restart
cd custombuild
./build update
./build set eximconf yes
./build set eximconf_release 4.5
./build set dovecot_conf yes
./build exim_conf
./build dovecot_conf

# DKIM

cd /usr/local/directadmin
./directadmin set dkim 1
cd /usr/local/directadmin/custombuild
./build update
./build exim
./build eximconf

# Webmail one-click

cd /usr/local/directadmin
./directadmin set one_click_webmail_login 1
service directadmin restart
cd custombuild
./build update
./build dovecot_conf
./build exim_conf
./build roundcube

# CSF Profile
mv /etc/csf/csf.conf /etc/csf/csf.conf.original
wget https://raw.githubusercontent.com/mxroute/da_server_updates/master/csf.conf -P /etc/csf
yum install unzip -y
unzip csf.zip
csf -r

# Exim plus aliasing

mkdir -p /etc/exim
cat >> /etc/exim/local_part_suffix.conf <<"EOF"
local_part_suffix = +*
local_part_suffix_optional
EOF

# SFTP Backups

yum install sshpass -y
cd /usr/local/directadmin/scripts/custom/
git clone https://github.com/poralix/directadmin-sftp-backups.git
cp -f directadmin-sftp-backups/ftp_download.php ./
cp -f directadmin-sftp-backups/ftp_list.php ./
cp -f directadmin-sftp-backups/ftp_upload.php ./
chmod 700 ftp_*.php
chown diradmin:diradmin ftp_*.php

# Install rspamd

cd /usr/local/directadmin/custombuild
./build update
./build set eximconf yes
./build set eximconf_release 4.5
./build set blockcracking no
./build set easy_spam_fighter yes
./build set spamd rspamd
./build set exim yes
./build exim
./build rspamd
./build exim_conf

# Custom DA Templates

mkdir -p /usr/local/directadmin/data/templates/custom
cat >> /usr/local/directadmin/data/templates/custom/mail_settings.html <<EOL
|LANG_ACCOUNT_READY|:<br><br>

<table class=list cellpadding=3 cellspacing=1>
<tr><td class=list2 align=right><b>|LANG_USERNAME|:</b></td><td class=list2>|USER|@|DOMAIN|</td></tr>
<tr><td class=list  align=right><b>|LANG_PASSWORD|:</b></td><td class=list >|EMAIL_PASS|</td></tr>
<tr><td class=list2 align=right><b>|LANG_POP_IMAP|:</b></td><td class=list2>$HOSTNAME</td></tr>
<tr><td class=list align=right><b>|LANG_SMTP|:</b></td><td class=list>$HOSTNAME</td></tr>
</table>
EOL

# Fix IP session tie

/usr/local/directadmin/directadmin set disable_ip_check 1 && systemctl restart directadmin

# Fix WHMCS referrer

echo "https://accounts.mxroute.com" >> /usr/local/directadmin/data/templates/custom/referer_check.allow
systemctl restart directadmin

# Deploy ClamAV

cd /usr/local/directadmin/custombuild
./build update
./build set clamav yes
./build clamav

# Set DA Admin Pass

PASS=$(uuidgen)
echo -e "$PASS\n$PASS" | (passwd --stdin admin)
echo "DA Username: admin" >> /root/creds
echo "DA Password: $PASS" >> /root/creds
unset PASS
chmod 600 /root/creds

# Get packages

cd /usr/local/directadmin/data/users/admin
wget https://config.mxroute.com/deploy/packages.zip
yum install unzip -y
unzip packages.zip
for i in $(ls /usr/local/directadmin/data/users/admin/packages); do echo $i >> /usr/local/directadmin/data/users/admin/packages.list; done
sed -i 's/.pkg//g' /usr/local/directadmin/data/users/admin/packages.list
chown diradmin. /usr/local/directadmin/data/users/admin/packages.list
chown -R diradmin. /usr/local/directadmin/data/users/admin/packages

# Fix admin skin

sed -i 's/skin=evolution/skin=power_user/g' /usr/local/directadmin/data/users/admin/user.conf

# Disable DA ticket system

rm -f /usr/local/directadmin/data/users/admin/ticket.conf
cat >> /usr/local/directadmin/data/users/admin/ticket.conf <<"EOF"
ON=yes
active=no
email=ticketsupport@mxroute.com
html=Follow <a href="https://mxroute.com/support">this link</a> for support.
new=0
newticket=0
EOF
chown diradmin. /usr/local/directadmin/data/users/admin/ticket.conf

# Set Limits

echo "0" > /etc/virtual/limit
echo "7200" > /etc/virtual/user_limit

# Run updates/customizations

sh /root/da_server_updates/exim/update_exim.sh
sh /root/da_server_updates/roundcube/update_roundcube.sh
sh /root/da_server_updates/rspamd/update_rspamd.sh

# Install template customizations

sh /root/da_server_updates/directadmin/updatetheme.sh

# Finisher

echo "Don't forget to add $IP4 to the filter servers and install Crossbox"
