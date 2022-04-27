#!/bin/bash
# Deploy standardized DA layout for evolution theme

mv /usr/local/directadmin/data/users/mxroute/skin_customizations/evolution/config.json /usr/local/directadmin/data/users/mxroute/skin_customizations/evolution/config.json$(date +%s)
wget https://raw.githubusercontent.com/mxroute/da_server_updates/master/directadmin/config.json -P /usr/local/directadmin/data/users/mxroute/skin_customizations/evolution
wget https://raw.githubusercontent.com/mxroute/da_server_updates/master/directadmin/logo2.png -P /usr/local/directadmin/data/users/mxroute/skin_customizations/evolution
chown diradmin. /usr/local/directadmin/data/users/mxroute/skin_customizations/evolution/*
systemctl restart directadmin
