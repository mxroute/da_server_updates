#!/bin/bash

sed -i 's/letsencrypt_list=mail:webmail/letsencrypt_list=mail:webmail:mailadmin/g' /usr/local/directadmin/conf/directadmin.conf
sed -i 's/letsencrypt_list_selected=mail:webmail/letsencrypt_list_selected=mail:webmail:mailadmin/g' /usr/local/directadmin/conf/directadmin.conf
systemctl restart directadmin

mkdir /var/www/html/panel
cat >> /var/www/html/panel/.htaccess <<EOL
SetEnvIf Request_URI "^(.*)" PORT=2222

RewriteEngine On
RewriteBase /

# CORS
Header add Access-Control-Allow-Origin "*"

# HTTPS
RewriteCond %{HTTPS} !=on
RewriteCond %{ENV:HTTPS} !=on
RewriteRule ^(.*) https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# PORT
RewriteCond %{SERVER_PORT} !^%{ENV:PORT}$
RewriteRule ^(.*) https://%{HTTP_HOST}:%{ENV:PORT}%{REQUEST_URI} [L,R=301]

# RPROXY
# RewriteRule ^(.*) http://localhost:${ENV:PORT}/$1 [P]
EOL

chown -R webapps. /var/www/html/panel
