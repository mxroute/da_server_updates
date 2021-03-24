#!/bin/bash

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build dovecot
sh /usr/local/directadmin/custombuild/build dovecot_conf

# Fix Dovecot limits

if grep -q "service lmtp" /etc/dovecot/dovecot.conf
then
        echo "Dovecot limits already in place."
else
cat >> /etc/dovecot/dovecot.conf <<EOL
service lmtp {
    vsz_limit = 8192 M
    process_limit = 4096
}

service imap {
  process_limit = 8192
}
EOL
sed -i 's/imap-login {/imap-login {\n  process_limit = 16384/g' /etc/dovecot/dovecot.conf
fi

# Reinstall quota notifications
rm -f /etc/dovecot/conf.d/91-quota-warning.conf
rm -f /usr/local/bin/quota-warning.sh
wget -O /etc/dovecot/conf.d/91-quota-warning.conf http://files1.directadmin.com/services/all/91-quota-warning.conf
wget -O /usr/local/bin/quota-warning.sh http://files1.directadmin.com/services/all/quota-warning.sh
chmod 755 /usr/local/bin/quota-warning.sh

# For good measure

echo "default_client_limit = 8192" >> /etc/dovecot/dovecot.conf

# Restart Dovecot
systemctl restart dovecot
