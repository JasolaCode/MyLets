#!/bin/bash

# add-wifi-network.sh

GRN='\033[0;32m'        # Green
RED='\033[0;31m'        # Red
CLR='\033[0m'           # Reset Colour

NET_FILE="/etc/wpa_supplicant/wpa_supplicant.conf"

# ensure the wpa_supplicant package is installed
# sudo apt install wpasupplicant

# list wifi networks in the area
sudo iwlist wlan0 scanning | grep 'ESSID\|Frequency\|Quality' --color=auto

# get input for network name and pass
read -p "Enter your SSID to connect to: " NET_SSID
read -p "Enter your WPA Key: " NET_KEY

# declare variable with the SSID and PSK for the conf file
NET_CONFIG=eval$(sudo wpa_passphrase $NET_SSID $NET_KEY)

# if $NET_CONFIG has evaluated as expected
if [[ $NET_CONFIG =~ "psk=" ]]; then
	# append the multi-line string to file, piping variable resulted in one line
	sudo wpa_passphrase $NET_SSID $NET_KEY | sudo tee -a $NET_FILE

	# check if successfully appended
	if sudo grep -wq $NET_SSID $NET_FILE  &&  sudo grep -wq $NET_KEY $NET_FILE ; then	
		# print success
		echo -e "${GRN}- Added it to file!"
		# print for of next block	
		# remove '#psk=...' line from file
		sudo sed -i '/#psk=/d' $NET_FILE && echo -e "${GRN}- Removed line '#psk=...' from file ${NET_FILE}"
		# check if removed from file
		if sudo grep -wq '#psk=' $NET_FILE ; then
		  	# warn of manual intervention
			echo -e "${RED}- File ${NET_FILE} still contains line '#psk=...'. Manually remove"
			exit 1
		else
		  	# print success
		  	echo -e "${GRN}- Line '#psk=...' successfully removed from file: ${NET_FILE}"
		fi	
	else
	  	# warn of file
		echo -e "${RED}- The following lines were not properly added to file: ${NET_FILE} \n\n${NET_CONFIG}"
		exit 1
	fi
else
  	# warn of process
	echo -e "${RED}- The following lines were not properly added to file: ${NET_FILE} \n\n${NET_CONFIG}"
	exit 1
fi

echo -e "${CLR}Current wifi SSID connection listed below for each interface:"
iwconfig | grep ESSID --color=auto

while true; do

	read -p "$(echo -e "${CLR}Do you want to wait for the 'wpa_supplicant' to reload? (y/n) ")" NET_RELOAD

	case $NET_RELOAD in 
		[yY] ) echo "- Sleeping for 5 seconds then proceeding";
		  	sleep 5
			if iwconfig | grep -q $NET_SSID; then
				echo -e "${GRN}- Successfully connected to network ${CLR}'${NET_SSID}'"
				break
			else
				echo -e "${CLR}- Still not connected to network ${RED}'${NET_SSID}'"

				read -p "$(echo -e "${CLR}Do you want to reboot? (y/n)")" NET_REBOOT
				case $NET_REBOOT in
				  	[yY] ) echo -e "${CLR}- Rebooting device in 5 seconds"
					  	echo -e "- On device start, run the following command: ${GRN}iwconfig | grep ESSID --color=auto"
					  	sleep 5
						sudo reboot now;;
					[*] ) exit;;
				esac
			fi;;
		[nN] ) echo "- Exiting...";
			exit;;
		* ) echo -e "${RED}- Invalid Response";;
	esac
done
