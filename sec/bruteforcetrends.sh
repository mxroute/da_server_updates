#!/bin/bash

for i in $(grep "authenticator failed for (USER)" /var/log/exim/mainlog | awk '{print $8}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq); do ip route add blackhole $i; done
for i in $(grep "authenticator failed for (ADMIN)" /var/log/exim/mainlog | awk '{print $8}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort | uniq); do ip route add blackhole $i; done
