#!/bin/bash

for i in $(ls /usr/local/directadmin/data/users);
        do
                sed -i 's/login_keys=OFF/login_keys=ON/g' /usr/local/directadmin/data/users/$i/user.conf
        done
