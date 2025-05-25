#!/bin/bash

for i in $(awk '{print $2}' /etc/blackhole_backup); do ip route add blackhole $i; done
