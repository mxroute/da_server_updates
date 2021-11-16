#!/bin/bash

# We don't forward emails that consistently get rejected, and that leads to bounces.
# We're not ready to pick and choose who to send bounces to at the source server,
# so the bounces stack up even though we're not delivering bounces to Google and Facebook.
# This is a bandaid.

if grep -q "fuckingbounces" /var/spool/cron/crontabs/root
then
  echo "Cron already installed."
else
  echo "0 * * * * /bin/bash /root/fuckingbounces.sh >/dev/null 2>&1" >> /var/spool/cron/crontabs/root
  chmod +x /root/fuckingbounces.sh
fi

if grep -q "fuckingbounces" /var/spool/cron/root
then
  echo "Cron already installed."
else
  echo "0 * * * * /bin/bash /root/fuckingbounces.sh >/dev/null 2>&1" >> /var/spool/cron/root
  chmod +x /root/fuckingbounces.sh
fi

for i in $(exim -bp | grep noreply-dmarc-support -B 1 | awk '{print $3}'); do exim -Mrm $i; done
for i in $(exim -bp | grep facebookmail.com -B 1 | awk '{print $3}'); do exim -Mrm $i; done
