#!/bin/bash

# Remove nixstats monitoring agent

systemctl stop nixstatsagent
systemctl disable nixstatsagent
rm -f /etc/systemd/system/nixstatsagent

service nixstatsagent stop
update-rc.d -f nixstatsagent remove
rm -f /etc/init.d/nixstatsagent

rm -f /etc/nixstats.ini
rm -f /etc/nixstats-token.ini
pip uninstall nixstatsagent
userdel nixstats

systemctl stop nixstats
systemctl disable nixstats
rm -f /etc/systemd/system/nixstats
rm -rf /opt/nixstats/
