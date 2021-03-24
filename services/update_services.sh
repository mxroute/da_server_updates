#!/bin/bash

sh /usr/local/directadmin/custombuild/build update
sh /usr/local/directadmin/custombuild/build letsencrypt
sh /usr/local/directadmin/custombuild/build nghttp2
sh /usr/local/directadmin/custombuild/build curl
sh /usr/local/directadmin/custombuild/build lego
sh /usr/local/directadmin/custombuild/build clamav
sh /usr/local/directadmin/custombuild/build libxml2
sh /usr/local/directadmin/custombuild/build libxslt
sh /usr/local/directadmin/custombuild/build freetype
