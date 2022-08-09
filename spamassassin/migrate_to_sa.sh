#!/bin/bash

sed -i 's/required_score 25.0/required_score 15.0/g' /home/*/.spamassassin/user_prefs
sed -i 's/high_score=25/high_score=15/g' /etc/virtual/*/filter.conf
echo "action=rewrite&value=spamd" >> /usr/local/directadmin/data/task.queue
