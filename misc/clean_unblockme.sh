#!/bin/bash

sort /etc/unblockme | uniq >> /etc/unblockme2
rm -f /etc/unblockme
mv /etc/unblockme2 /etc/unblockme
