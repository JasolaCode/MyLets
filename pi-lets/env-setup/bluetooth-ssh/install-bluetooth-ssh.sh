#!/bin/bash

# install-bluetooth-ssh.sh

CYN='\033[0;36m'         # Cyan
CLR='\033[0m'      # Reset

# upgrade all to newest version
sudo apt-get update && sudo apt-get upgrade -y

# The Re4son kernel ships with BlueZ
sudo apt install bluez-tools

# create the 3 following files for the network
sudo tee /etc/systemd/network/pan0.netdev <<EOF
[NetDev]
Name=pan0
Kind=bridge
EOF

sudo tee /etc/systemd/network/pan0.network <<EOF
[Match]
Name=pan0

[Network]
Address=172.20.1.1/24
DHCPServer=yes
EOF

sudo tee /etc/systemd/system/bt-agent.service <<EOF
[Unit]
Description=Bluetooth Auth Agent
[Service]
ExecStart=/usr/bin/bt-agent -c NoInputNoOutput
Type=simple
[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/bt-network.service <<EOF
[Unit]
Description=Bluetooth NEP PAN
After=pan0.network
[Service]
ExecStart=/usr/bin/bt-network -s nap pan0
Type=simple
[Install]
WantedBy=multi-user.target
EOF

# restart all services, ready to pair
sudo systemctl enable systemd-networkd
sudo systemctl enable bt-agent
sudo systemctl enable bt-network
sudo systemctl start systemd-networkd
sudo systemctl start bt-agent
sudo systemctl start bt-network

# set, ready to pair
sudo bt-adapter — set Discoverable 1

echo -e "${CLR}- Ready to pair ${CYN}$(hostname)"
echo -e "${CLR}Once paired, run the following command: ${CYN}sudo bt-adapter - set Discoverable 0"
