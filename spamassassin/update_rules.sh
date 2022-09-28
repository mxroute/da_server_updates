#!/bin/bash
rm -f /etc/mail/spamassassin/local.cf
wget https://raw.githubusercontent.com/mxroute/spamassassin_rules/main/local.cf -P /etc/mail/spamassassin
systemctl restart spamd
