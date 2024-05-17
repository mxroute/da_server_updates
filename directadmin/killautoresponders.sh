#!/bin/bash

DOMAINLIST=$(cat /etc/virtual/domains)

for i in $DOMAINLIST
  do
    rm -f /etc/virtual/$i/autoresponder.conf
    touch /etc/virtual/$i/autoresponder.conf
    chown mail. /etc/virtual/$i/autoresponder.conf
    chmod 0600 /etc/virtual/$i/autoresponder.conf
    rm -f /etc/virtual/$i/reply/*
  done
