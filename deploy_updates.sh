#!/bin/bash

rm -rf /root/update
mkdir -p /root/update/{dovecot,exim,roundcube,rspamd,services}

wget https://config.mxroute.com/update/dovecot/update_dovecot.sh -P /root/update/dovecot
wget https://config.mxroute.com/update/exim/update_exim.sh -P /root/update/exim
wget https://config.mxroute.com/update/roundcube/update_roundcube.sh -P /root/update/roundcube
wget https://config.mxroute.com/update/rspamd/update_rspamd.sh -P /root/update/rspamd
wget https://config.mxroute.com/update/services/update_services.sh -P /root/update/services
