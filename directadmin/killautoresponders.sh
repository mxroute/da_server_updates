#!/bin/bash

# Kill autoresponders created with DirectAdmin

DOMAINLIST=$(cat /etc/virtual/domains)
for i in $DOMAINLIST
  do
    rm -f /etc/virtual/$i/autoresponder.conf
    touch /etc/virtual/$i/autoresponder.conf
    chown mail. /etc/virtual/$i/autoresponder.conf
    chmod 0600 /etc/virtual/$i/autoresponder.conf
    rm -f /etc/virtual/$i/reply/*
  done

# Kill the ability to create autoresponders with Roundcube

sed -i "s/\$config\['managesieve_vacation'\] = 1/\$config\['managesieve_vacation'\] = 0/" /var/www/html/roundcube/plugins/managesieve/config.inc.php
