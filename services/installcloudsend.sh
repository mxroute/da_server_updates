#!/bin/bash
# This is installed on servers to help quickly send account backups to NextCloud.
# Primarily used when accounts are terminated for policy violations.
# We'll create a folder in NextCloud, set it to shared and to accept uploads, and then set a password on it.

sudo curl -o '/usr/local/bin/cloudsend' 'https://gist.githubusercontent.com/tavinus/93bdbc051728748787dc22a58dfe58d8/raw/cloudsend.sh' && sudo chmod +x /usr/local/bin/cloudsend
