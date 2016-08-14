#!/bin/bash

# This bash script should set up a PPTPD VPN on a fresh install. 

# Usage: sudo ./vpn-setup.bash

# See https://www.digitalocean.com/community/tutorials/how-to-setup-your-own-vpn-with-pptp
# for the original setup instructions (steps 1-4).

secrets="/etc/ppp/chap-secrets"
pptpdConfig="/etc/pptpd.conf"
ip=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install pptpd

sudo echo "localip $1" >> $pptpdConfig
sudo echo "remoteip 10.0.0.100-200" >> $pptpdConfig

sudo echo "ms-dns 8.8.8.8" >> $secrets
sudo echo "ms-dns 8.8.4.4" >> $secrets

sudo service pptpd restart

sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

sysctl -p

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && iptables-save
sudo iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
sudo iptables -I INPUT -s 10.0.0.0/8 -i ppp0 -j ACCEPT
sudo iptables --append FORWARD --in-interface eth0 -j ACCEPT

echo "VPN setup complete."
echo "Edit authentication information in $secrets"
echo "Syntax: username pptpd password *"

