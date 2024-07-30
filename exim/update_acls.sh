#!/bin/bash

rm -f /etc/spam_recipients
cp /root/da_server_updates/exim/spam_recipients /etc
rm -f /etc/exim.acl_check_recipient.pre.conf
cp /root/da_server_updates/exim/exim.acl_check_recipient.pre.conf /etc
rm -f /etc/exim.acl_check_message.pre.conf
cp /root/da_server_updates/exim/exim.acl_check_message.pre.conf /etc

rm -f /etc/spam_senders_temp
cat /etc/spam_senders >> /etc/spam_senders_temp
cat /root/da_server_updates/exim/spam_senders >> /etc/spam_senders_temp
rm -f /etc/spam_senders
sort /etc/spam_senders_temp | uniq >> /etc/spam_senders
