#!/bin/bash

# Manual offset to DDOS mitigation possible false positive

for i in $(ip route | grep "blackhole 209.85" | awk '{print $2}'); do ip route del blackhole $i; done
