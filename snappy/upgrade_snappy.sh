#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

GITHUB_URL="https://github.com/the-djmaze/snappymail/releases/latest"
YOUR_SERVER_FOLDER="/var/www/html/snappy/"

# UPGRADING Snappymail
#
# I've found this to be working fine when upgrading my Snappymail. The
# commands should be used at your own risk. I take no responsibility.
#
# This example assumes that Snappymail is installed in the following
# folder;
#
#     /var/www/snappy.somesite.com/ -- see $YOUR_SERVER_FOLDER
#
# Change the path to match your setup. 
#
# By Uwe Bieling <pychi@gmx.de>

# Safty First ... make a backup
mkdir -p /root/snappybackup
cd $YOUR_SERVER_FOLDER && cd ..
tar -czf backup_snappymail_`date +%Y%m%d`.tar.gz $YOUR_SERVER_FOLDER
mv backup_snappymail_`date +%Y%m%d`.tar.gz /root/snappybackup

# Download last release to /tmp
cd /tmp
curl -L -s $GITHUB_URL | grep -m 1 "href.*snappymail.*tar.gz" | sed "s/^.*href=\"//g" | sed "s/\".*$//g" | wget --base=http://github.com -i - -O snappy.tar.gz

# extract last release to folder
tar -xzvf snappy.tar.gz -C $YOUR_SERVER_FOLDER

# set permissions
find $YOUR_SERVER_FOLDER -type d -exec chmod 755 {} \;
find $YOUR_SERVER_FOLDER -type f -exec chmod 644 {} \;
chown -R webapps. $YOUR_SERVER_FOLDER

echo -e "\033[1;32mFinished upgrading snappymail ... \033[0m"

# Addition for MXroute
# Force redirect to https
if grep -q "RewriteCond" /var/www/html/snappy/.htaccess
then
        echo "Snappy SSL redirect already in place."
else
        sed -i '1 s/^/RewriteRule \(\.\*\) https\:\/\/\%\{HTTP_HOST\}\%\{REQUEST\_URI\} \[R\=301\,L\]\n/' /var/www/html/snappy/.htaccess
        sed -i '1 s/^/RewriteCond \%\{HTTPS\} off\n/' /var/www/html/snappy/.htaccess
        sed -i '1 s/^/RewriteEngine On\n/' /var/www/html/snappy/.htaccess
fi
