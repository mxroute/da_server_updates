#!/bin/bash
#
# fix_report_safe.sh - Fix report_safe setting in SpamAssassin user_prefs files
#
# Deploy to each server and run via pdsh. Handles home, home2, home3, etc.
#
# The sed regex matches: ^report_safe<whitespace><number>
# and replaces with: report_safe 0
#

COUNT=0

for HOMEDIR in /home* ; do
    if [[ -d "$HOMEDIR" ]]; then
        find "$HOMEDIR" -path '*/.spamassassin/user_prefs' -type f 2>/dev/null | while read -r FILE; do
            if grep -q '^report_safe[[:space:]]\+[1-9]' "$FILE" 2>/dev/null; then
                sed -i 's/^report_safe[[:space:]]\+[0-9]\+/report_safe 0/' "$FILE"
                echo "Fixed: $FILE"
                ((COUNT++))
            fi
        done
    fi
done

echo "Done. Fixed files on $(hostname)"
