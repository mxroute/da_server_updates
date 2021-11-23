#!/bin/bash

# Let's make sure Google IPs aren't blocked by automation, we'll monitor for brute force via Google POP3 another way

for i in $(grep google /etc/csf/csf.deny | awk '{print $1}'); do csf -dr $i; done

rm -f /etc/csf/csf.ignore
cat >> /etc/csf/csf.ignore <<EOL
###############################################################################
# Copyright 2006-2018, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################
# The following IP addresses will be ignored by all lfd checks
# One IP address per line
# CIDR addressing allowed with a quaded IP (e.g. 192.168.254.0/24)
# Only list IP addresses, not domain names (they will be ignored)
#

127.0.0.1
159.69.116.204
35.190.247.0/24
64.233.160.0/19
66.102.0.0/20
66.249.80.0/20
72.14.192.0/18
74.125.0.0/16
108.177.8.0/21
173.194.0.0/16
209.85.128.0/17
216.58.192.0/19
216.239.32.0/19
172.217.0.0/19
172.217.32.0/20
172.217.128.0/19
172.217.160.0/20
172.217.192.0/19
172.253.56.0/21
172.253.112.0/20
108.177.96.0/19
35.191.0.0/16
130.211.0.0/22
EOL

csf -r
