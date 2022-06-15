#!/bin/bash

# We can't just run custombuild's "update all" method or the gap between recompiling a service
# and reapplying it's custom config is too long, so we should add here the other services that
# we notice DA updating via the panel, and just update them manually. They may even be insignificant to our use case.


# Ensure Apache hostname redirect to webmail is working
sed -i "s/HOSTNAMEHERE/$(hostname -f)/g" /root/da_server_updates/apache/index.html
cp /root/da_server_updates/apache/index.html /var/www/html

# Update packages
sh /usr/local/directadmin/custombuild/build update

# Update all of the junk no one wants to think about
sh /usr/local/directadmin/custombuild/build letsencrypt
sh /usr/local/directadmin/custombuild/build nghttp2
sh /usr/local/directadmin/custombuild/build curl
sh /usr/local/directadmin/custombuild/build lego
sh /usr/local/directadmin/custombuild/build clamav
sh /usr/local/directadmin/custombuild/build libxml2
sh /usr/local/directadmin/custombuild/build libxslt
sh /usr/local/directadmin/custombuild/build freetype
sh /usr/local/directadmin/custombuild/build bubblewrap
sh /usr/local/directadmin/custombuild/build imapsync
sh /usr/local/directadmin/custombuild/build ioncube
sh /usr/local/directadmin/custombuild/build redis

# Update DirectAdmin
sh /usr/local/directadmin/scripts/getDA.sh current

# Update Dovecot
sh /root/da_server_updates/dovecot/update_dovecot.sh

# Update exim
sh /root/da_server_updates/exim/update_exim.sh

# Update Snappy
sh /root/da_server_updates/snappy/upgrade_snappy.sh

# Update Roundcube
sh /root/da_server_updates/update_roundcube.sh

# Enable ioncube
sh /usr/local/directadmin/custombuild/build set ioncube yes

# Update/build PHP
sh /usr/local/directadmin/custombuild/build php
