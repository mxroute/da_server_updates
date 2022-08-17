# To be executed on September 30, 2022
# Revoking all instances of Rainloop
# Replacing them with Snappy

#!/bin/bash

unlink /var/www/html/rainloop
rm -rf /var/www/html/rainloop
ln -s /var/www/html/snappy /var/www/html/rainloop
chown -vh webapps. /var/www/html/rainloop
