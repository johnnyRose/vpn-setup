#!/bin/bash

secrets="/etc/ppp/chap-secrets"
pptpdConfig="/etc/pptpd.conf"

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install pptpd



sudo echo "localip $1" >> $pptpdConfig
sudo echo "remoteip 10.0.0.100-200" >> $pptpdConfig

echo "Edit authentication information in $secrets"
echo "syntax: username pptpd password *"

sudo echo "ms-dns 8.8.8.8" >> $secrets
sudo echo "ms-dns 8.8.4.4" >> $secrets

sudo service pptpd restart

sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

sysctl -p

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && iptables-save
sudo iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
sudo iptables -I INPUT -s 10.0.0.0/8 -i ppp0 -j ACCEPT
sudo iptables --append FORWARD --in-interface eth0 -j ACCEPT

echo "complete"

