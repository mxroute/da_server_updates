#!/bin/bash
# The list being deployed here is not public, but this is to help identify spam warmup companies that make their way into MXroute again.
# This in response to finding 3 customers who were running spam warmup systems and flying under the radar.

cat >> /etc/exim.acl_check_recipient.pre.conf <<EOL

deny    senders     = nwildlsearch*@;/etc/warmup_senders
        message     = Logged for review as likely involved with spam warmup service
EOL

# Restarting exim without killing it actually causes more downtime in our environment
# So kill it, restart it, report that it's up
killall -9 exim && systemctl restart exim && systemctl status exim | grep "Active:"
