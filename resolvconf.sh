#!/bin/bash

unlink /etc/resolv.conf
rm -f /etc/resolv.conf
cp /root/da_server_updates/resolv.conf /etc
