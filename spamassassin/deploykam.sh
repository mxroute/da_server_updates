#!/bin/bash

wget https://mcgrail.com/downloads/kam.sa-channels.mcgrail.com.key -O /root/da_server_updates/kam.sa-channels.mcgrail.com.key
sa-update --import /root/da_server_updates/kam.sa-channels.mcgrail.com.key
sa-update --gpgkey 24C063D8 --channel kam.sa-channels.mcgrail.com
