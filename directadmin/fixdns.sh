#!/bin/bash
# This script is designed to force our SPF record into DirectAdmin DNS zones
# For two reasons:
# 1. DA ignores our attempts to edit the templates for this.
# 2. Despite adding "ONLY USE DKIM KEYS HERE" and begging people to read their new service email, EVERY SINGLE NEW CUSTOMER ignores the welcome email, ignores the warning, and takes the default SPF record from the DA DNS page.

# Get the public facing IP address of the server and assign it to "IPADDR" variable
IPADDR=$(curl -s http://whatismyip.akamai.com/)

# Replace "ip4:$IPADDR" with "include:mxroute.com" in all .db files in /etc/bind
sed -i "s/ip4:$IPADDR/include:mxroute.com/g" /etc/bind/*.db

# Now we pray to every god in history that we never have to speak of this again.