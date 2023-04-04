#!/bin/bash
rm -f /var/log/exim/spam_recipient_staging
for i in $(grep "Recipient address rejected: Domain not found" /var/log/exim/mainlog | awk '{print $3}' | sort | uniq)
	do
		for a in $(grep $i mainlog | grep "Domain not found" | awk -F'==' '{print $2}' | awk '{print $1}' | awk -F'@' '{print $2}' | sort | uniq)
			do
				echo "$a" >> /var/log/exim/spam_recipient_staging
				for i in $(exim -bp | grep -v "D " | grep $a -B 1 | awk '{print $3}'); do exim -Mrm $i; done
			done
	done
