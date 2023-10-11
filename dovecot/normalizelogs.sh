#!/bin/bash

if [ -f /var/log/mail.log ] && [ ! -f /var/log/maillog ]; then
    ln -s /var/log/mail.log /var/log/maillog
elif [ -f /var/log/maillog ] && [ ! -f /var/log/mail.log ]; then
    ln -s /var/log/maillog /var/log/mail.log
fi
