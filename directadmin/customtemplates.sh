#!/bin/bash

for i in $(ls /root/da_server_updates/directadmin/templates/custom); do rm -f /usr/local/directadmin/data/templates/custom/$i && cp /root/da_server_updates/directadmin/templates/custom/$i /usr/local/directadmin/data/templates/custom; done

mkdir -P /usr/local/directadmin/data/templates/custom
chown -R diradmin. /usr/local/directadmin/data/templates/custom
chmod 0644 /usr/local/directadmin/data/templates/custom/*
