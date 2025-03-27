#!/bin/bash
for i in $(ip route | grep blackhole | awk '{print $2}'); do ip route del blackhole $i; done
