#!/bin/bash

# Adapting to kill off RBLs outside of SA entirely
unlink /etc/virtual/use_rbl_domains
touch /etc/virtual/use_rbl_domains
chown mail. /etc/virtual/use_rbl_domains
chmod 0644 /etc/virtual/use_rbl_domains

# The original version of this script, still helpful for processing the above
rm -f /etc/exim.strings.conf.custom
cp /root/da_server_updates/exim/exim.strings.conf.custom /etc
killall -9 exim
systemctl restart exim
systemctl status exim | grep Active:
