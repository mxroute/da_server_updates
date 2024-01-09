#!/bin/bash

# Step 1: Change the string "-m 15" to "-m 25" in /etc/systemd/system/spamassassin.service
sed -i 's/-m 15/-m 25/' /etc/systemd/system/spamassassin.service

# Step 2: Reload systemd daemon
systemctl daemon-reload

# Step 3: Restart the spamd service
systemctl restart spamd
