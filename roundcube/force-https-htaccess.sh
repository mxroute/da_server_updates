#!/bin/bash
# Inserts a forced HTTP->HTTPS redirect at the top of the Roundcube .htaccess
# if one isn't already present.

HTACCESS="/var/www/html/roundcube/.htaccess"

if [[ ! -f "$HTACCESS" ]]; then
    echo "ERROR: $HTACCESS not found."
    exit 1
fi

# Check if an HTTPS redirect already exists anywhere in the file
if grep -qiE 'RewriteCond\s+%\{HTTPS\}\s+(off|!=on)' "$HTACCESS"; then
    echo "HTTPS redirect already present in $HTACCESS. No changes made."
    exit 0
fi

# Build the redirect block
read -r -d '' REDIRECT_BLOCK << 'EOF'
# Force HTTP to HTTPS
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>

EOF

# Capture original ownership and permissions
ORIG_OWNER=$(stat -c '%u:%g' "$HTACCESS")
ORIG_PERMS=$(stat -c '%a' "$HTACCESS")

# Prepend the block to the existing file
TMPFILE=$(mktemp)
printf '%s\n' "$REDIRECT_BLOCK" | cat - "$HTACCESS" > "$TMPFILE" \
    && chown "$ORIG_OWNER" "$TMPFILE" \
    && chmod "$ORIG_PERMS" "$TMPFILE" \
    && mv "$TMPFILE" "$HTACCESS"

echo "HTTPS redirect inserted at top of $HTACCESS."
