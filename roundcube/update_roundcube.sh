#!/bin/bash

# Set Variables

RCMYSQLPASS=$(grep "password" /var/www/html/roundcube/config/my.cnf | sed 's/password=//')
RCPLUGINS=(persistent_login advanced_search)

# Make backup

rm -rf /root/temp/backups/roundcube
mkdir -p /root/temp/backups/roundcube
cp -R /var/www/html/roundcube /root/temp/backups/roundcube

# Run update

/usr/local/directadmin/custombuild/build roundcube

# Set SSL Redirect

if grep -q "RewriteCond" /var/www/html/roundcube/.htaccess
then
        echo "Roundcube SSL redirect already in place."
else
        sed -i '1 s/^/RewriteRule \(\.\*\) https\:\/\/\%\{HTTP_HOST\}\%\{REQUEST\_URI\} \[R\=301\,L\]\n/' /var/www/html/roundcube/.htaccess
        sed -i '1 s/^/RewriteCond \%\{HTTPS\} off\n/' /var/www/html/roundcube/.htaccess
        sed -i '1 s/^/RewriteEngine On\n/' /var/www/html/roundcube/.htaccess
fi

# Install persistent_login

if [ -d "/var/www/html/roundcube/plugins/persistent_login" ]
then
	echo "Persistent login already installed."
else
	yum install git -y
	cd /var/www/html/roundcube/plugins
	git clone https://github.com/texxasrulez/persistent_login
	mv /var/www/html/roundcube/plugins/persistent_login/config.inc.php.dist /var/www/html/roundcube/plugins/persistent_login/config.inc.php
	chown -R webapps. /var/www/html/roundcube/plugins
	mysql -uda_roundcube -p"$RCMYSQLPASS" da_roundcube < /var/www/html/roundcube/plugins/persistent_login/SQL/mysql.initial.sql
fi

# Install advanced_search

	cd /var/www/html/roundcube/plugins
	git clone https://github.com/mxroute/advanced_search
	mv /var/www/html/roundcube/plugins/advanced_search/config.inc.php.dist /var/www/html/roundcube/plugins/advanced_search/config.inc.php
	chown -R webapps. /var/www/html/roundcube/plugins

# Add plugins to config

if grep -q ${RCPLUGINS[0]} /var/www/html/roundcube/config/config.inc.php
then
        echo "Plugins already installed."
else
        for i in ${RCPLUGINS[@]}
        do
		sed -i "s/managesieve',/managesieve',\n    '$i',/g" /var/www/html/roundcube/config/config.inc.php
		echo "$i installed."
        done
fi

unset RCMYSQLPASS
unset RCPLUGINS
