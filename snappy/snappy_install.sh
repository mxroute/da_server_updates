#!/bin/bash

rm -rf /var/www/html/snappy
rm -f /var/www/html/snappymail-2.11.0.zip
wget https://github.com/the-djmaze/snappymail/releases/download/v2.11.0/snappymail-2.11.0.zip -P /var/www/html
unzip /var/www/html/snappymail-2.11.0.zip -d /var/www/html/snappy
chown -R webapps. /var/www/html/snappy
find /var/www/html/snappy -type d -exec chmod 755 {} \;
find /var/www/html/snappy -type f -exec chmod 644 {} \;
curl -I https://$(hostname)/snappy
