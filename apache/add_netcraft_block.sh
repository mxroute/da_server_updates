#!/bin/bash

HTACCESS="/var/www/html/.htaccess"
BLOCK_RULES='RewriteEngine On
RewriteCond %{HTTP_USER_AGENT} NetcraftSurveyAgent [NC]
RewriteRule .* - [R=404,L]'

if [ ! -f "$HTACCESS" ]; then
    echo "$BLOCK_RULES" > "$HTACCESS"
    echo "Created $HTACCESS with Netcraft block rules."
else
    if grep -q "NetcraftSurveyAgent" "$HTACCESS"; then
        echo "Netcraft block rules already present in $HTACCESS. No changes made."
        exit 0
    fi
    tmpfile=$(mktemp)
    echo "$BLOCK_RULES" > "$tmpfile"
    echo "" >> "$tmpfile"
    cat "$HTACCESS" >> "$tmpfile"
    mv "$tmpfile" "$HTACCESS"
    echo "Netcraft block rules added to top of $HTACCESS."
fi

chown webapps: /var/www/html/.htaccess
chmod 755 /var/www/html/.htaccess
