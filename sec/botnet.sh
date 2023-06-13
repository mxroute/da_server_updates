#!/bin/bash

for i in $(cat /root/da_server_updates/sec/botnet.list); do ip route del blackhole $i; done
