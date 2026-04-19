#!/bin/bash
#
# migrate_to_etc_exim.sh
#
# One-time migration: move MXroute-maintained exim data files from /etc/
# to /etc/exim/ so the full ACL data surface lives under one directory
# that can be rsynced to a new server.
#
# Safe to re-run. For each file:
#   - If old path doesn't exist: skip.
#   - If new path doesn't exist: move old -> new.
#   - If both exist and are identical: remove old.
#   - If both exist and differ: stop and warn (manual reconcile).
#
# Run on each server once before deploying the updated ACL/config files.

set -u

DEST_DIR="/etc/exim"

FILES=(
    aclwhitelist
    aifilter-domains
    bannedspoofing
    firebaseapp_whitelist
    googlegroups_whitelist
    heloblocks
    onmicrosoft_whitelist
    overquota
    ovhranges
    sendgrid_whitelist
    solutions_whitelist
    spam_recipients
    spam_senders
    spoofwhitelist
    susranges
    susranges_domainwhitelist
    susranges_protected_domains
    susranges_whitelist
)

if [[ ! -d "$DEST_DIR" ]]; then
    mkdir -p "$DEST_DIR"
    echo "Created $DEST_DIR"
fi

moved=0
skipped=0
identical=0
conflicts=()

for name in "${FILES[@]}"; do
    old="/etc/$name"
    new="$DEST_DIR/$name"

    if [[ ! -e "$old" ]]; then
        skipped=$((skipped + 1))
        continue
    fi

    if [[ ! -e "$new" ]]; then
        mv "$old" "$new"
        echo "Moved $old -> $new"
        moved=$((moved + 1))
        continue
    fi

    # Both exist. Compare.
    if cmp -s "$old" "$new"; then
        rm -f "$old"
        echo "Removed $old (identical to $new)"
        identical=$((identical + 1))
    else
        conflicts+=("$name")
        echo "CONFLICT: $old and $new both exist and differ. Not touched." >&2
    fi
done

echo
echo "Summary: moved=$moved identical=$identical skipped=$skipped conflicts=${#conflicts[@]}"

if (( ${#conflicts[@]} > 0 )); then
    echo
    echo "Conflicts to reconcile manually:" >&2
    for c in "${conflicts[@]}"; do
        echo "  diff /etc/$c $DEST_DIR/$c" >&2
    done
    exit 1
fi

echo
echo "Migration complete. Remember to:"
echo "  - Deploy the updated ACL/config files that reference /etc/exim/*"
echo "  - Restart exim:  killall -9 exim && systemctl restart exim"
