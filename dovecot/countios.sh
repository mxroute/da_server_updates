#!/bin/bash

zgrep "Notification sent successfully" /var/log/mail* | awk -F'imap\\(' '{print $2}' | awk -F')' '{print $1}' | sort | uniq | wc -l
