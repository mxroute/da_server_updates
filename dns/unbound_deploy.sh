#!/bin/bash

# Function to check if a command exists
command_exists() {
    type "$1" &> /dev/null
}

# Update and Install Unbound
if command_exists yum; then
    yum install unbound -y
elif command_exists apt; then
    apt update && apt install unbound -y
else
    echo "Neither yum nor apt is available. Exiting."
    exit 1
fi

# Backup existing unbound configuration
if [ -f /etc/unbound/unbound.conf.d/myunbound.conf ]; then
    mv /etc/unbound/unbound.conf.d/myunbound.conf /etc/unbound/unbound.conf.d/myunbound.conf.bak
fi

# Populate unbound configuration
cat > /etc/unbound/unbound.conf.d/myunbound.conf << 'EOF'
server:
    verbosity: 1
    num-threads: 2
    outgoing-range: 512
    num-queries-per-thread: 1024
    msg-cache-size: 32m
    rrset-cache-size: 64m
    cache-max-ttl: 86400
    infra-host-ttl: 60
    infra-lame-ttl: 120
    access-control: 127.0.0.0/8 allow
    access-control: 0.0.0.0/0 allow
    access-control: ::1 allow
    username: unbound
    directory: "/etc/unbound"
    logfile: "/var/log/unbound.log"
    use-syslog: no
    hide-version: yes
    so-rcvbuf: 4m
    so-sndbuf: 4m
    do-ip4: yes
    do-ip6: yes
    do-udp: yes
    do-tcp: yes

    # Add these lines to enable recursion:
    # Allow queries from local network
    local-zone: "." typetransparent
    local-data: "localhost A 127.0.0.1"
    local-data: "localhost AAAA ::1"

    # Root servers hints
    root-hints: "/etc/unbound/root.hints"

remote-control:
    control-enable: yes
    control-port: 953
    control-interface: 127.0.0.1
EOF

# Download root hints
wget -O /etc/unbound/root.hints https://www.internic.net/domain/named.cache

# Stop and disable named, then restart unbound
systemctl stop named
systemctl disable named
systemctl daemon-reload
systemctl restart unbound

# Backup and replace /etc/init.d/named
mkdir -p /root/oldconfigs
if [ -f /etc/init.d/named ]; then
    mv /etc/init.d/named /root/oldconfigs
fi

# Create a dummy named init script
cat > /etc/init.d/named << 'EOF'
#!/bin/sh
exit 0;
EOF

chmod 0755 /etc/init.d/named

# Replace "named=ON" with "named=OFF" in services.status
if [ -f /usr/local/directadmin/data/admin/services.status ]; then
    sed -i 's/named=ON/named=OFF/g' /usr/local/directadmin/data/admin/services.status
fi

# Restart directadmin
systemctl restart directadmin
