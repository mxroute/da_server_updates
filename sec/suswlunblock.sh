#!/bin/bash
for i in $(cat /etc/exim/susranges_whitelist); do ip route del blackhole $i; done
