#!/bin/bash

curl --max-time 15 localhost
if (( $? > 0 )); then
    systemctl restart httpd
fi
