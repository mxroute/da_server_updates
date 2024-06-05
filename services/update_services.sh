#!/bin/bash

# We can't just run custombuild's "update all" method or the gap between recompiling a service
# and reapplying it's custom config is too long, so we should add here the other services that
# we notice DA updating via the panel, and just update them manually. They may even be insignificant to our use case.


# Ensure Apache hostname redirect to webmail is working
sed -i "s/HOSTNAMEHERE/$(hostname -f)/g" /root/da_server_updates/apache/index.html
cp /root/da_server_updates/apache/index.html /var/www/html

# Update packages
da build update
da build update_system

# Update all of the junk no one wants to think about
da build letsencrypt
da build nghttp2
da build curl
da build lego
da build clamav
da build libxml2
da build libxslt
da build freetype
da build bubblewrap
da build imapsync
da build redis
#da build mysql
da build jailshell
da build phpmyadmin
da build apache

# Update DirectAdmin
sh /usr/local/directadmin/scripts/getDA.sh current

# Enable ioncube
da build set ioncube yes

# Update/build PHP
da build php
da build ioncube

# Update Dovecot
sh /root/da_server_updates/dovecot/update_dovecot.sh

# Update exim
sh /root/da_server_updates/exim/update_exim.sh

# Update Snappy
#sh /root/da_server_updates/snappy/upgrade_snappy.sh

# Update Roundcube
sh /root/da_server_updates/roundcube/update_roundcube.sh
