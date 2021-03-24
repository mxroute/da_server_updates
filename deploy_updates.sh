#!/bin/bash

# Get rid of the last batch
rm -rf /root/da_server_updates

# Get 'er done
cd /root && git clone https://github.com/mxroute/da_server_updates
