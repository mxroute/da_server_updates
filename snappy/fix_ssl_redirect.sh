#!/bin/bash

if grep -q "RewriteCond" /var/www/html/snappy/.htaccess
then
        echo Snappy SSL redirect already in place."
else
        sed -i '1 s/^/RewriteRule \(\.\*\) https\:\/\/\%\{HTTP_HOST\}\%\{REQUEST\_URI\} \[R\=301\,L\]\n/' /var/www/html/snappy/.htaccess
        sed -i '1 s/^/RewriteCond \%\{HTTPS\} off\n/' /var/www/html/snappy/.htaccess
        sed -i '1 s/^/RewriteEngine On\n/' /var/www/html/snappy/.htaccess
fi
