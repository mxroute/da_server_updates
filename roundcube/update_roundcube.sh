#!/bin/bash
set -e

WORK="/root/working/roundcube"
VERSION="1.6.13"
TARGET="/var/www/html/roundcubemail-1.6.11"
TARBALL="roundcubemail-${VERSION}.tar.gz"
URL="https://github.com/roundcube/roundcubemail/releases/download/${VERSION}/${TARBALL}"

rm -rf "$WORK"
mkdir -p "$WORK"
wget -q -O "${WORK}/${TARBALL}" "$URL"
tar -zxf "${WORK}/${TARBALL}" -C "$WORK"
echo "y" | "${WORK}/roundcubemail-${VERSION}/bin/installto.sh" "$TARGET"
chown -R webapps: "$TARGET"
