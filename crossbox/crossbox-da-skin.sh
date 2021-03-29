#!/bin/bash

# Rename "Communications" menu to "Crossbox Apps" to clarify the division of the assets here

sed -i 's/Communication/Crossbox Apps/g' /usr/local/directadmin/data/users/mxroute/skin_customizations/evolution/config.json
