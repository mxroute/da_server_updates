#!/bin/bash

# Fix eximstats database

/scripts/restartsrv_tailwatchd --stop
/scripts/restartsrv_eximstats --stop
find /var/cpanel -name 'eximstats_db*' -exec mv -v {}{,.$(date +%s)} \;
/usr/local/cpanel/bin/updateeximstats
/scripts/import_exim_data /var/log/exim_mainlog
/scripts/slurp_exim_mainlog --force
/scripts/restartsrv_eximstats
/scripts/restartsrv_tailwatchd --start
