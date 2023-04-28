#!/bin/bash

rm -f /etc/dovecot/conf.d/90-sieve.conf
cp /root/da_server_updates/dovecot/90-sieve.conf /etc/dovecot/conf.d
systemctl reload dovecot
