#!/bin/bash

# set colour variables to use in the file
BLK='\033[01;30m'   # Black
RED='\033[01;31m'   # Red
GRN='\033[01;32m'   # Green
YLW='\033[01;33m'   # Yellow
BLU='\033[01;34m'   # Blue
PUR='\033[01;35m'   # Purple
CYN='\033[01;36m'   # Cyan
WHT='\033[01;37m'   # White
CLR='\033[00m'      # Reset

function usage { # example of a --help parameter which is parsed through to display information
	echo "" # $0 is a default variable used for the filename of script
	echo "Usage: $0 [-i|--install] [-u|--upgrade] [-r|--remove] [-h|--help]" # an understandable layout to display paramaters for script
	echo "Run script as sudo with 'sudo -i'."
	echo "install/remove/upgrade SSH with BlueZ instance in the RPi environment."
	echo ""
	echo "Options:" # this area shows how to parse parameters into the script as intended with brief definitions
	echo "  -i, --install     Perform a fresh install of SSH with BlueZ on the RPi."
	echo "  -u, --upgrade     Upgrade an existing instance of SSH with BlueZ (as previously installed by this script)."
	echo "  -r, --remove      Remove an existing instance of SSH with BlueZ (as previously installed by this script)."
	echo "  -h, --help        Display usage information for this script."
	echo ""
	exit 0 # exit without error
} # end of usage() function

function file_check() { # perform grep checks from within specified files
	local INFILE="$1" # first value parsed to function
	
	if [ -f $INFILE ]; then # main if statement to check for PHRASE in INFILE
		echo -e "${GRN}- File $INFILE successfully created"
	else
		echo -e "${RED}- Failed to create $INFILE"; exit 1 # exit with general error
	fi # end of grep if
} # end of file_check() function

function remove {
	echo "- remove() function hasn't been implemented yet"; exit 0 # exit with no error
}

function upgrade {
	echo "- upgrade() function hasn't been implemented yet"; exit 0 # exit with no error
}

function install {
	echo -e "${CYN}- Updating and upgrading package environment"
	apt-get update && sudo apt-get upgrade -y # upgrade all to newest version
	echo -e "${CYN}- Installing bluez-tools"
	apt-get install bluez-tools # The Re4son kernel ships with BlueZ

	# create the 3 following files for the network
	# Create and populate pan0 network device file
	tee /etc/systemd/network/pan0.netdev <<EOF
[NetDev]
Name=pan0
Kind=bridge
EOF

	file_check /etc/systemd/network/pan0.netdev

	# Create and populate pan0 network interface file
	tee /etc/systemd/network/pan0.network <<EOF
[Match]
Name=pan0

[Network]
Address=172.20.1.1/24
DHCPServer=yes
EOF
	
	file_check /etc/systemd/network/pan0.network

	# Create and populate the agent service unit file for bt-agent
	tee /etc/systemd/system/bt-agent.service <<EOF
[Unit]
Description=Bluetooth Auth Agent
[Service]
ExecStart=/usr/bin/bt-agent -c NoInputNoOutput
Type=simple
[Install]
WantedBy=multi-user.target
EOF

	file_check /etc/systemd/system/bt-agent.service
	
	# Create and populate the agent service unit file for bt-network
	tee /etc/systemd/system/bt-network.service <<EOF
[Unit]
Description=Bluetooth NEP PAN
After=pan0.network
[Service]
ExecStart=/usr/bin/bt-network -s nap pan0
Type=simple
[Install]
WantedBy=multi-user.target
EOF

	file_check /etc/systemd/system/bt-network.service
	
	# restart all services, before pairing
	echo "- Enabling required bluetooth services"
	systemctl enable systemd-networkd
	systemctl enable bt-agent
	systemctl enable bt-network
	
	echo "- Starting required bluetooth services"
	systemctl start systemd-networkd
	systemctl start bt-agent
	systemctl start bt-network

	bt-adapter --set Discoverable 1 # set, ready to pair

	echo -e "${CLR}- Ready to pair ${CYN}$(hostname)"
	echo -e "${CLR}Once paired, run the following command: ${CYN}sudo bt-adapter - set Discoverable 0"
} # end of install() function

if (( $EUID != 0 )); then # check is script has been run as sudo
	echo -e "${YLW}- Run as root/sudo"
	usage; exit 0 # exit without error
fi # end of $EUID if

if [ $# -eq 0 ]; then # if no params are parsed through, display the -h|--help menu using the usage() function
	echo -e "${YLW}$0: no parameter parsed"
  	usage; exit 0 # exit without error
fi # end of $# if

while [[ $# -gt 0 ]]; do # while loop is used to assign paramaters parsed through in command line
	case $1 in # $1 represents a parsed in variable
		-i|--install) # for parameters which accept a value, we use two 'shift'/s
			install # calls function install() to be run
			shift
			;;
		-r|--remove) # for parameters that don't require a value, only one 'shift' is required
			remove # calls function remove() to be run
			shift
			;;
		-u|--upgrade) # for parameters that don't require a value, only one 'shift' is required
			upgrade # calls function upgrade() to be run
			shift
			;;
		-h|--help) # for parameters that don't require a value, only one 'shift' is required
			usage # calls function usage() to be run
			shift
			;;
		*) # I clearly don't know how to use it... Help me out by showing the usage() function
			echo "${YLW}$0: incorrect parameter parsed"
		  	usage # calls function usage() to be run
			shift
			;;
	esac # end of $1 case
done # end of $# while
