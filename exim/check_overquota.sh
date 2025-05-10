#!/bin/bash

OVERQUOTA_FILE="/etc/overquota"
TEMP_FILE="/tmp/overquota_tmp.$$"
DEBUG=0  # Set to 1 for debug mode

# Allow debug mode via CLI
if [[ "$1" == "--debug" ]]; then
    DEBUG=1
    echo "Running in debug mode. No changes will be made."
fi

if [[ ! -f "$OVERQUOTA_FILE" ]]; then
    echo "File $OVERQUOTA_FILE not found."
    exit 1
fi

touch "$TEMP_FILE"

while IFS= read -r user; do
    [[ -z "$user" ]] && continue

    output=$(doveadm quota get -u "$user" 2>/dev/null)
    if [[ $? -ne 0 || -z "$output" ]]; then
        echo "Error: Failed to get quota for $user"
        continue
    fi

    # Get value and limit from STORAGE line using awk
    storage_line=$(echo "$output" | awk '/STORAGE/ {print $2, $3}')
    value=$(echo "$storage_line" | awk '{print $1}')
    limit=$(echo "$storage_line" | awk '{print $2}')

    if [[ -z "$value" || -z "$limit" ]]; then
        echo "Could not parse STORAGE quota for $user: $output"
        continue
    fi

    if [[ "$limit" == "-" ]]; then
        if [[ $DEBUG -eq 1 ]]; then
            echo "[DEBUG] $user has unlimited quota, would remove"
        else
            echo "$user has unlimited quota, removing from list"
            continue
        fi
    elif [[ "$value" =~ ^[0-9]+$ && "$limit" =~ ^[0-9]+$ ]]; then
        if (( value < limit )); then
            if [[ $DEBUG -eq 1 ]]; then
                echo "[DEBUG] $user is under quota ($value < $limit), would remove"
            else
                echo "$user is under quota ($value < $limit), removing from list"
                continue
            fi
        else
            if [[ $DEBUG -eq 1 ]]; then
                echo "[DEBUG] $user is still over quota ($value >= $limit), keeping"
            fi
        fi
    else
        echo "Unexpected non-numeric value or limit for $user: value='$value', limit='$limit'"
        continue
    fi

    echo "$user" >> "$TEMP_FILE"

done < "$OVERQUOTA_FILE"

if [[ $DEBUG -eq 0 ]]; then
    mv "$TEMP_FILE" "$OVERQUOTA_FILE"
else
    echo "[DEBUG] Final list that would remain in $OVERQUOTA_FILE:"
    cat "$TEMP_FILE"
    rm -f "$TEMP_FILE"
fi
