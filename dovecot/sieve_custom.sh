#!/bin/bash

rm -f /etc/dovecot/conf.d/90-sieve.conf
cp /root/da_server_updates/dovecot/90-sieve.conf /etc/dovecot/conf.d
systemctl reload dovecot

# I know it doesn't belong here but I'm doing it anyway
rm -f /etc/mail/spamassassin/local.cf
wget https://raw.githubusercontent.com/mxroute/spamassassin_rules/main/local.cf -O /etc/mail/spamassassin/local.cf
