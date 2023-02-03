rm -f /var/log/exim/spam_recipient_staging
for i in $(grep "Recipient address rejected: Domain not found" /var/log/exim/mainlog | awk '{print $3}' | sort | uniq)
	do
		for a in $(grep $i mainlog | grep -E 'login:|plain:' | awk -F'> for' '{print $2}' | grep "@" | awk -F'@' '{print $2}' | grep -v "\ ")
			do
				echo "*@$a" >> /var/log/exim/spam_recipient_staging
				for i in $(exim -bp | grep $a -B 1 | awk '{print $3}'); do exim -Mrm $i; done
			done
	done
