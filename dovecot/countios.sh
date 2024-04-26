#!/bin/bash

grep "Notification sent successfully" maillog | awk -F'imap\\(' '{print $2}' | awk -F')' '{print $1}' | sort | uniq | wc -l
