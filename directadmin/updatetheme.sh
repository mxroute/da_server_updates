#!/bin/bash

rm -rf /usr/local/directadmin/data/users/mxroute/skin_customizations/evolution
cp -R /root/da_server_updates/directadmin/evolution /usr/local/directadmin/data/users/mxroute/skin_customizations
chown -R diradmin. /usr/local/directadmin/data/users/mxroute/skin_customizations
