#!/bin/bash

for i in $(cat /root/da_server_updates/exim); do echo "$i" >> /etc/spam_recipients; done
sort /etc/spam_recipients | uniq >> /etc/spam_recipients2
rm -f /etc/spam_recipients
mv /etc/spam_recipients2 /etc/spam_recipients
