#!/bin/bash
# This will deploy our custom virtual host templates used by DirectAdmin

# Delete previous templates
for i in $(ls /root/da_server_updates/apache/custom);
  do rm -f /usr/local/directadmin/data/templates/custom/$i;
done

# Deploy new ones
for i in $(ls /root/da_server_updates/apache/custom);
  do cp /root/da_server_updates/apache/custom/$i /usr/local/directadmin/data/templates/custom;
done

# Set ownership
chown diradmin. /usr/local/directadmin/data/templates/custom/*

# Reset permissions
chmod 0644 /usr/local/directadmin/data/templates/custom/*

# Rebuild user configs
echo "action=rewrite&value=httpd" >> /usr/local/directadmin/data/task.queue
