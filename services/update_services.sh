#!/bin/bash

# We can't just run custombuild's "update all" method or the gap between recompiling a service
# and reapplying it's custom config is too long, so we should add here the other services that
# we notice DA updating via the panel, and just update them manually. They may even be insignificant to our use case.


# Ensure Apache hostname redirect to webmail is working
sed -i "s/HOSTNAMEHERE/$(hostname -f)/g" /root/da_server_updates/apache/index.html
cp /root/da_server_updates/apache/index.html /var/www/html

# Update packages
/usr/local/directadmin/custombuild/build update

# Update all of the junk no one wants to think about
/usr/local/directadmin/custombuild/build letsencrypt
/usr/local/directadmin/custombuild/build nghttp2
/usr/local/directadmin/custombuild/build curl
/usr/local/directadmin/custombuild/build lego
/usr/local/directadmin/custombuild/build clamav
/usr/local/directadmin/custombuild/build libxml2
/usr/local/directadmin/custombuild/build libxslt
/usr/local/directadmin/custombuild/build freetype
/usr/local/directadmin/custombuild/build bubblewrap
/usr/local/directadmin/custombuild/build imapsync
/usr/local/directadmin/custombuild/build redis
/usr/local/directadmin/custombuild/build imapsync
#/usr/local/directadmin/custombuild/build mysql
/usr/local/directadmin/custombuild/build jailshell
/usr/local/directadmin/custombuild/build phpmyadmin
/usr/local/directadmin/custombuild/build apache

# Update DirectAdmin
sh /usr/local/directadmin/scripts/getDA.sh current

# Enable ioncube
/usr/local/directadmin/custombuild/build set ioncube yes

# Update/build PHP
/usr/local/directadmin/custombuild/build php
/usr/local/directadmin/custombuild/build ioncube

# Update Dovecot
sh /root/da_server_updates/dovecot/update_dovecot.sh

# Update exim
sh /root/da_server_updates/exim/update_exim.sh

# Update Snappy
#sh /root/da_server_updates/snappy/upgrade_snappy.sh

# Update Roundcube
sh /root/da_server_updates/update_roundcube.sh
