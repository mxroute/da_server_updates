#!/bin/bash
for i in $(cat /etc/susranges_whitelist); do ip route del blackhole $i; done
