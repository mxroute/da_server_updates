#!/bin/bash

# Enable SpamAssassin for all accounts

# If they have no filters configured, give them a baseline
for i in $(find /etc/virtual -name filter.conf)
        do
                if ! grep -q "high_score_block" $i; then
                        echo "high_score=20" >> $i
                        echo "high_score_block=yes" >> $i
                        echo "where=delete" >> $i
                fi
        done

# SA is dependent on user_prefs files so if there isn't one, make one
for username in $(ls /usr/local/directadmin/data/users);
        do
                DIR=/home/$username/.spamassassin
                mkdir -p $DIR
                UP=$DIR/user_prefs
                  if [ ! -s ${UP} ]; then
                     echo 'required_score 20.0' > ${UP}
                     echo 'report_safe 1' >> ${UP}
                     chown $username:$username  ${UP}
                     chmod 644 ${UP}
        fi
        chown  ${username}:mail $DIR
        chmod 771 $DIR
done

# Reload SA configs
echo "action=rewrite&value=spamd" >> /usr/local/directadmin/data/task.queue
