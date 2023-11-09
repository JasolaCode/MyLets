#!/bin/bash
#
#smb-install.sh

set -e

MYIP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)
read -p "Enter username of samba user: " SMBUSER

sudo apt install samba -y
echo "- Installed samba version: $(samba --version)"

sudo tee -a /etc/samba/smb.conf <<EOF
[${SMBUSER}]
	path = /home/${SMBUSER}/smb_share
	browseable = yes
	read only = no
EOF

echo "- Starting smbd/nmbd services "
sudo service smbd start
sudo service nmbd start

echo "- Creating samba user $SMBUSER"
sudo smbpasswd -a $SMBUSER
echo "Use the UNC Path: \\$MYIP"
