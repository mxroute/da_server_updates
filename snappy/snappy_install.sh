#!/bin/bash

wget https://github.com/the-djmaze/snappymail/releases/download/v2.11.0/snappymail-2.11.0.zip -P /var/www/html
unzip /var/www/html/snappymail-2.11.0.zip -d /var/www/html/snappy
chown -R webapps. /var/www/html/snappy
