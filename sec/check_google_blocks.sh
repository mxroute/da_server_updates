#!/bin/bash
# Sometimes a Google IP slips into mitigation
# and if Google is being abusive, we are required to bend over and take it
# otherwise customers will be gone in 60 seconds.
# This is to mitigate that possibility.

for i in $(nmap -sL -n 209.85.128.0/17 | grep 'Nmap scan report for' | cut -f 5 -d ' '); do ip route del blackhole $i && csf -dr $i; done
for i in $(nmap -sL -n 34.64.0.0/10 | grep 'Nmap scan report for' | cut -f 5 -d ' '); do ip route del blackhole $i && csf -dr $i; done
