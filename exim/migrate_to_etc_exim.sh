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

# Deploy the updated ACL include files from the local repo clone.
# These stay in /etc/ (NOT /etc/exim/); only the data files they reference moved.
REPO_EXIM="/root/da_server_updates/exim"
ACL_INCLUDES=(
    exim.acl_check_helo.pre.conf
    exim.acl_check_message.pre.conf
    exim.acl_check_recipient.pre.conf
)

if [[ ! -d "$REPO_EXIM" ]]; then
    echo
    echo "WARNING: $REPO_EXIM not found. Skipping ACL include deployment." >&2
    echo "Clone the repo to /root/da_server_updates and re-run, or deploy the" >&2
    echo "ACL files manually." >&2
    exit 1
fi

echo
echo "Deploying ACL includes from $REPO_EXIM to /etc/ ..."
for acl in "${ACL_INCLUDES[@]}"; do
    src="$REPO_EXIM/$acl"
    dst="/etc/$acl"
    if [[ ! -f "$src" ]]; then
        echo "  MISSING $src, skipping" >&2
        continue
    fi
    cp "$src" "$dst"
    echo "  Deployed $dst"
done

echo
echo "Restarting exim ..."
killall -9 exim 2>/dev/null
systemctl restart exim
echo "Done."
