#!/bin/bash
# I don't need to renew SSL certificates for internal server to server communication, and I'm tired of customers asking me about it. In a highly controlled environment, suppressing this error serves no purpose other than to reduce customer questions.

sed -i '/certificate has expired cert/d' /var/log/exim/mainlog
