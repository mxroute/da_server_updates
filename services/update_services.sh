#!/bin/bash

# We can't just run custombuild's "update all" method or the gap between recompiling a service
# and reapplying it's custom config is too long, so we should add here the other services that
# we notice DA updating via the panel, and just update them manually. They may even be insignificant to our use case.

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build letsencrypt
sh /usr/local/directadmin/custombuild/build nghttp2
sh /usr/local/directadmin/custombuild/build curl
sh /usr/local/directadmin/custombuild/build lego
sh /usr/local/directadmin/custombuild/build clamav
sh /usr/local/directadmin/custombuild/build libxml2
sh /usr/local/directadmin/custombuild/build libxslt
sh /usr/local/directadmin/custombuild/build freetype
