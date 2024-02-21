#!/bin/bash

for i in $(cat /root/da_server_updates/sec/ransom.list); do ip route add blackhole $i; done
