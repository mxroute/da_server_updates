#!/bin/bash
# Had enough of rsyslog failing when 1100+ journal logs are present with no clear reason
# Replacing rsyslog with syslog-ng on all CentOS boxes

FILE=/etc/centos-release
if [ -f "$FILE" ]; then
    echo "CentOS box, proceeding."
    systemctl stop rsyslog
    systemctl disable rsyslog
    yum install syslog-ng -y
    systemctl enable syslog-ng
    systemctl start syslog-ng
else 
    echo "Not a CentOS box, failing."
fi
