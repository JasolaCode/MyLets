#!/bin/bash

#smb-install.sh

MYIP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)

sudo apt install samba -y
sudo tee -a /etc/samba/smb.conf <<EOF
[jasola]
	path = /home/jasola
	browseable = yes
	read only = no
EOF

sudo service smbd start
sudo service nmbd start

echo "Create a user with: sudo smbpasswd -a jasola"
echo "Use the UNC Path: \\$MYIP"
