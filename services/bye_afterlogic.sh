#!/bin/bash

rm -rf /var/www/html/afterlogic
mkdir -p /var/www/html/afterlogic

cat >> /var/www/html/afterlogic/index.html <<EOL
<meta http-equiv="Refresh" content="0; url='https://webmail.mxroute.com'" />
EOL

chown -R webapps. /var/www/html/afterlogic
