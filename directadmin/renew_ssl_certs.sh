#!/bin/bash

# Set the log file path
LOG_FILE="/var/log/letsencrypt/$(date +%Y-%m-%d).log"

# Function to check certificate expiration
check_cert_expiration() {
    local domain="$1"
    local timeout_duration=10  # Timeout in seconds
    local expiration_date
    local debug_output
    
    debug_output=$(timeout $timeout_duration bash -c "openssl s_client -servername $domain -connect $domain:443 </dev/null 2>&1 | openssl x509 -noout -enddate 2>&1")
    expiration_date=$(echo "$debug_output" | grep "notAfter=" | cut -d= -f2)
    
    if [ -z "$expiration_date" ]; then
        echo "Error: Unable to fetch expiration date for $domain" >> "$LOG_FILE"
        echo "Debug output:" >> "$LOG_FILE"
        echo "$debug_output" >> "$LOG_FILE"
        return 1
    fi
    
    local expiration_epoch=$(date -d "$expiration_date" +%s 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: Invalid date format received for $domain" >> "$LOG_FILE"
        echo "Expiration date: $expiration_date" >> "$LOG_FILE"
        return 1
    fi
    
    local current_epoch=$(date +%s)
    local days_until_expiry=$(( (expiration_epoch - current_epoch) / 86400 ))
    echo $days_until_expiry
}

# Function to renew certificate
renew_cert() {
    local domain="$1"
    local output=$(/usr/local/directadmin/scripts/letsencrypt.sh renew "$domain" secp384r1)
    echo "$output"
    if [[ $output == *"has been created successfully!"* ]]; then
        echo "Certificate for $domain has been renewed successfully." >> "$LOG_FILE"
    else
        echo "Certificate renewal for $domain failed. Output: $output" >> "$LOG_FILE"
    fi
}

# Function to test network connectivity
test_network() {
    if ! ping -c 1 -W 5 8.8.8.8 > /dev/null 2>&1; then
        echo "Error: Network connectivity issue detected." >> "$LOG_FILE"
        return 1
    fi
    return 0
}

# Main script
echo "SSL Certificate Renewal Process - $(date)" > "$LOG_FILE"

# Test network connectivity
if ! test_network; then
    echo "Exiting due to network connectivity issues." >> "$LOG_FILE"
    exit 1
fi

while read -r ROOTDOMAIN; do
    echo "Checking $ROOTDOMAIN..." >> "$LOG_FILE"
    
    for SUBDOMAIN in "mail" "webmail"; do
        FULLDOMAIN="${SUBDOMAIN}.${ROOTDOMAIN}"
        echo "Checking $FULLDOMAIN..." >> "$LOG_FILE"
        
        if ! nc -z -w5 $FULLDOMAIN 443 2>/dev/null; then
            echo "Error: Unable to connect to $FULLDOMAIN on port 443" >> "$LOG_FILE"
            continue
        fi
        
        DAYS_UNTIL_EXPIRY=$(check_cert_expiration "$FULLDOMAIN")
        
        if [ $? -ne 0 ]; then
            echo "Skipping $FULLDOMAIN due to error in checking expiration." >> "$LOG_FILE"
            continue
        fi
        
        if [ "$DAYS_UNTIL_EXPIRY" -le 30 ]; then
            echo "$FULLDOMAIN expires in $DAYS_UNTIL_EXPIRY days. Renewing..." >> "$LOG_FILE"
            renew_cert "$ROOTDOMAIN"
            break  # Only need to renew once per root domain
        else
            echo "$FULLDOMAIN expires in $DAYS_UNTIL_EXPIRY days. No action needed." >> "$LOG_FILE"
        fi
    done
done < <(ls /etc/dovecot/conf/sni | sed 's/.conf//')

# Reload services
systemctl reload httpd && systemctl reload dovecot && systemctl reload exim
echo "Services reloaded: httpd, dovecot, exim" >> "$LOG_FILE"

echo "SSL Certificate Renewal Process Completed - $(date)" >> "$LOG_FILE"
