#!/bin/bash

for i in $(cat /root/da_server_updates/sec/facebook_ips);
	do ip route del blackhole $i;
done
