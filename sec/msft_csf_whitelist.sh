#!/bin/bash
# msft_csf_whitelist.sh
# Fetches Microsoft 365 IPv4 ranges, removes any matching IPs from csf.deny,
# and ensures all ranges are present in csf.ignore.

set -euo pipefail

FEED_URL="https://endpoints.office.com/endpoints/worldwide?clientrequestid=b10c5ed1-bad1-445f-b386-b919946339a9"
CSF_IGNORE="/etc/csf/csf.ignore"
IGNORE_MARKER="# Microsoft 365 IPv4 ranges"

echo "[*] Fetching Microsoft 365 endpoint feed..."
RAW=$(curl -fsSL "$FEED_URL")

if [[ -z "$RAW" ]]; then
    echo "[!] Failed to fetch feed. Aborting."
    exit 1
fi

# Extract only IPv4 addresses/CIDRs (exclude IPv6)
MSFT_IPS=$(echo "$RAW" | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?"' | tr -d '"' | sort -u)

if [[ -z "$MSFT_IPS" ]]; then
    echo "[!] No IPv4 addresses found in feed. Aborting."
    exit 1
fi

TOTAL=$(echo "$MSFT_IPS" | wc -l)
echo "[*] Found $TOTAL unique Microsoft IPv4 ranges."

# --- Step 1: Remove any Microsoft IPs from csf.deny ---
# csf.deny contains individual IPs blocked by lfd, not ranges.
# We check each blocked IP against the Microsoft CIDR ranges using Python.
echo ""
echo "[*] Checking csf.deny for IPs falling within Microsoft ranges..."

MATCHES=$(python3 - <<PYEOF
import ipaddress

ranges_raw = """$MSFT_IPS"""
msft_ranges = []
for line in ranges_raw.strip().splitlines():
    line = line.strip()
    if not line:
        continue
    try:
        msft_ranges.append(ipaddress.ip_network(line, strict=False))
    except ValueError:
        pass

try:
    with open("/etc/csf/csf.deny", "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            token = line.split()[0]
            try:
                candidate = ipaddress.ip_network(token, strict=False)
                if candidate.version != 4:
                    continue
                for msft in msft_ranges:
                    if candidate.subnet_of(msft) or candidate == msft:
                        print(token)
                        break
            except ValueError:
                pass
except FileNotFoundError:
    pass
PYEOF
)

REMOVED=0
if [[ -z "$MATCHES" ]]; then
    echo "    [+] No Microsoft IPs found in csf.deny."
else
    while IFS= read -r ip; do
        echo "    [!] Found $ip in csf.deny (within a Microsoft range) -- removing..."
        csf -dr "$ip" && REMOVED=$((REMOVED + 1)) || echo "    [!] csf -dr $ip failed"
    done <<< "$MATCHES"
    echo "    [+] Removed $REMOVED entries from csf.deny."
fi

# --- Step 2: Ensure all Microsoft IPv4 ranges are in csf.ignore ---
echo ""
echo "[*] Updating csf.ignore..."

if grep -qF "$IGNORE_MARKER" "$CSF_IGNORE" 2>/dev/null; then
    echo "    [*] Removing existing Microsoft block from csf.ignore..."
    sed -i "/$IGNORE_MARKER/d" "$CSF_IGNORE"
fi

ADDED=0
SKIPPED=0

{
    echo ""
    echo "$IGNORE_MARKER (auto-updated $(date '+%Y-%m-%d %H:%M:%S'))"
} >> "$CSF_IGNORE"

while IFS= read -r ip; do
    if grep -qF "$ip" "$CSF_IGNORE" 2>/dev/null; then
        SKIPPED=$((SKIPPED + 1))
    else
        echo "$ip $IGNORE_MARKER" >> "$CSF_IGNORE"
        ADDED=$((ADDED + 1))
    fi
done <<< "$MSFT_IPS"

echo "    [+] Added $ADDED new entries to csf.ignore ($SKIPPED already present)."

# --- Step 3: Reload CSF to apply changes ---
echo ""
echo "[*] Reloading CSF..."
csf -r

echo ""
echo "[+] Done. Microsoft 365 IPv4 ranges are whitelisted and csf.deny is clean."
