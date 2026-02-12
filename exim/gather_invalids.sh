#!/bin/bash
rm -f /var/log/exim/spam_recipient_staging
for i in $(grep -a "Recipient address rejected: Domain not found" /var/log/exim/mainlog | grep -v "cuoly.com" | grep -v "askjdmiller.com" | awk '{print $3}' | sort | uniq)
	do
		for a in $(grep -a $i /var/log/exim/mainlog | grep "Domain not found" | grep -v "cuoly.com" | grep -v "askjdmiller.com" | awk -F'==' '{print $2}' | awk '{print $1}' | awk -F'@' '{print $2}' | sort | uniq)
			do
				echo "$a" >> /var/log/exim/spam_recipient_staging
				for i in $(exim -bp | grep -v "D " | grep $a -B 1 | awk '{print $3}'); do exim -Mg $i; done
			done
	done

sort /var/log/exim/spam_recipient_staging | uniq >> /var/log/exim/spam_recipient_staging2
rm -f /var/log/exim/spam_recipient_staging
mv /var/log/exim/spam_recipient_staging2 /var/log/exim/spam_recipient_staging
