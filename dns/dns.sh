#!/bin/bash
# Deploy DNS resolvers

rm -f /etc/resolv.conf.bak
mv /etc/resolv.conf /etc/resolv.conf.bak
cp /root/da_server_updates/dns/resolv.conf /etc
