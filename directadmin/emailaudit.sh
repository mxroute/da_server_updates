#!/bin/bash

find /var/log/directadmin -name "emailaudit.log" -delete
grep "created by" /var/log/directadmin/system.log.1 | grep Email | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq -c | sort -n | tail -10 >> /var/log/directadmin/emailaudit.log
