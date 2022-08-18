#!/bin/bash
# Deploy SpamAssassin, removing rspamd from production

cd /usr/local/directadmin/custombuild
./build set spamd spamassassin
./build spamassassin

sh /root/da_server_updates/exim/update_exim.sh
