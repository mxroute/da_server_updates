#!/bin/bash
# What a wonderful MySQL update that required this

yum downgrade mysql-community-* -y
yum install python3-dnf-plugin-versionlock -y
for i in mysql-community-client mysql-community-client-plugins mysql-community-common mysql-community-devel mysql-community-icu-data-files mysql-community-libs mysql-community-server; do dnf versionlock $i; done
