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
	echo "Run script as with 'sudo -i'."
	echo "Configure a new wifi network for the RPi device"
	echo ""
	echo "Options:" # this area shows how to parse parameters into the script as intended with brief definitions
	echo "  -s, --setup       Perform a full setup to join a new wifi network."
	echo "  -n, --netscan     Scan for networks in the area on specified interface."
	echo "  -r, --reload      Reload the wpa_supplicant in an attempt to join an already known network."
	echo "  -i, --interface   List interface devices and their connections."
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

function setup { # function setup() will be called when parsing -s|--setup
	function netscan { # function netscan() will be called when parsing -n|--netscan
		iwlist wlan0 scanning | grep 'ESSID\|Frequency\|Quality' --color=auto # list wifi networks in the area
	} # end of netscan() function
	
	function reload { # function reload() will be called when parsing -r|--reload
		if [ -z "$NET_SSID" ]; then # if the variable doesn't exist, prompt for it
			read -p "Enter your SSID to connect to: " NET_SSID
		fi # end of NET_SSID if
		while true; do # enter while loop for case descision
			read -p "$(echo -e "${CLR}Do you want to wait for the 'wpa_supplicant' to reload? (y/n) ")" NET_RELOAD
			case $NET_RELOAD in # y/Y or n/N input handling for NET_RELOAD
				[yY] ) echo "- Sleeping for 5 seconds then proceeding";
					sleep 5
					if iwconfig | grep -q $NET_SSID; then # check if connected to NET_SSID netowrk
						echo -e "${GRN}- Successfully connected to network ${CLR}'${NET_SSID}'"
						break
					else
						echo -e "${CLR}- Still not connected to network ${RED}'${NET_SSID}'"
						read -p "$(echo -e "${CLR}Do you want to reboot RPi? (y/n)")" NET_REBOOT # purpose of reboot is for full setup
						case $NET_REBOOT in # y/Y or n/N input handling for NET_REBOOT
							[yY] ) echo -e "${CLR}- Rebooting device in 5 seconds"
								echo -e "- On device start, run the following command: ${GRN}${0} --interface"
								sleep 5
								reboot now
								;;
							[*] ) exit
								;;
						esac # end of NET_REBOOT case
					fi # end of iwconfig if
					;;
				[nN] ) echo "${CLR}- Exiting...";
					exit
					;;
				* ) echo -e "${RED}- Invalid Response"
					;;
			esac # end of NET_RELOAD case
		done # end of while true loop
	} # end of reload() function
	
	function interface { # function interface() will be called when parsing -i|--interface
		echo -e "${CLR}Current wifi SSID connection listed below for each interface:"
		iwconfig | grep ESSID --color=auto # use --color to maintain colour in output, makes it easier on end-user
	} # end of interface() function
	
	NET_FILE="/etc/wpa_supplicant/wpa_supplicant.conf" # this could be a parsed variable in future?

	apt-get install wpasupplicant	
	netscan # call netscan() function 

	# get input for network name and pass
	read -p "Enter your SSID to connect to: " NET_SSID
	read -p "Enter your WPA Key: " NET_KEY
	NET_CONFIG=eval$(wpa_passphrase $NET_SSID $NET_KEY) # declare variable with the SSID and PSK for the conf file

	if [[ $NET_CONFIG =~ "psk=" ]]; then # if $NET_CONFIG has evaluated as expected
		wpa_passphrase $NET_SSID $NET_KEY | tee -a $NET_FILE # append the multi-line string to file, piping variable resulted in one line

		if grep -wq $NET_SSID $NET_FILE  &&  grep -wq $NET_KEY $NET_FILE ; then	# check if successfully appended
			echo -e "${GRN}- Added $NET_SSID to file!"
			sed -i '/#psk=/d' $NET_FILE && echo -e "${GRN}- Removed line '#psk=...' from file ${NET_FILE}" # remove '#psk=...' line from file
			if grep -wq '#psk=' $NET_FILE ; then # check if removed from file
				echo -e "${YLW}- File ${NET_FILE} still contains line '#psk=...'. Manually remove"; exit 0 # warn of manual intervention
			else
				echo -e "${GRN}- Line '#psk=...' successfully removed from file: ${NET_FILE}"
			fi # end of NET_FILE if
		else
			echo -e "${RED}- The following lines were not properly added to file: ${NET_FILE} \n\n${NET_CONFIG}"; exit 1
		fi # end of NET_SSID if
	else
		echo -e "${RED}- The following lines were not properly added to file: ${NET_FILE} \n\n${NET_CONFIG}"; exit 1
	fi # end of NET_CONFIG if
	
	interface # call interface() function 
	reload # call reload() function 
} # end of setup() function

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
		-s|--setup) # for parameters which accept a value, we use two 'shift'/s
			setup # calls function setup() to be run, exits with no error
			shift
			;;
		-n|--netscan) # for parameters that don't require a value, only one 'shift' is required
			netscan; exit 0 # calls function netscan() to be run, exits with no error
			shift
			;;
		-r|--reload) # for parameters that don't require a value, only one 'shift' is required
			reload; exit 0 # calls function reload() to be run, exits with no error
			shift
			;;
		-i|--interface) # for parameters which accept a value, we use two 'shift'/s
			interface; exit 0 # calls function interface() to be run, exit with no error
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
