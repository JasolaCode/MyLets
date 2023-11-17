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
	echo "install/remove/upgrade bettercap instance in the RPi environment."
	echo ""
	echo "Options:" # this area shows how to parse parameters into the script as intended with brief definitions
	echo "  -i, --install     Perform a fresh install of Bettercap on the RPi."
	echo "  -u, --upgrade     Upgrade an existing instance of a Bettercap install (as previously installed by this script)."
	echo "  -r, --remove      Remove an existing instance of Bettercap (as previously installed by this script)."
	echo "  -h, --help        Display usage information for this script."
	echo ""
	exit 0 # exit without error
} # end of usage() function

function grep_file_check() { # perform grep checks from within specified files
	local PHRASE="$1" # first value parsed to function
	local INFILE="$2" # second value parsed to function
	
	if [ grep -q $PHRASE $INFILE ]; then # main if statement to check for PHRASE in INFILE
		echo "${GRN}- File $INFILE successfully updated with $PHRASE"
	else
		echo "${RED}- Failed to update $INFILE, doesn't contain $PHRASE"; exit 1 # exit with general error
	fi # end of grep if
} # end of grep_file_check() function

function remove {
	echo "- remove() function hasn't been implemented yet"; exit 0 # exit with no error
}	# end of remove() function

function upgrade {
	echo "- upgrade() function hasn't been implemented yet"; exit 0 # exit with no error
} # end of upgrade() function

function install {
	if [ $(go --version &> /dev/null) ]; then
		echo -e "${RED}- go package has not been found on the machine. Install using $(find ../ -print | grep -i setup_golang.sh) script in MyLets."; exit 0 # exit with no error
	fi # end of --version if

	echo -e "- Setting ${BLU}SWAP_SIZE=1024${CLR} in /etc/dphys-swapfile"
	sed -i 's/CONF_SWAPSIZE=.*/SWAP_SIZE=1024/g' /etc/dphys-swapfile # change the configuration in the file **/etc/dphys-swapfile**
	grep_file_check "SWAP_SIZE=1024" /etc/dphys-swapfile # swap_size check in file
	# The default value in Raspbian is:
	# CONF_SWAPSIZE=100
	# We will need to change this to:
	# CONF_SWAPSIZE=1024
	# Then you need to stop and start the service that manages the swapfile own Rasbian:
	/etc/init.d/dphys-swapfile stop # isn't run through systemctl
	/etc/init.d/dphys-swapfile start # cannot reboot/restart
	if [ echo $(free -m) | grep -q "1024"  ]; then # verify the change was successfully implemented
		echo "${GRN}- SWAP_SIZE was successfully set to 1024"
	else
		echo "${RED}- Failed to set SWAP_SIZE to 1024 in file etc/dphys-swapfile"; exit 1 # exit with general error
	fi # end of $(free -m) if
	sudo apt-get install build-essential libpcap-dev libusb-1.0-0-dev libnetfilter-queue-dev git # Install the Bettercap dependencies
	if [ -d /usr/local/bin/bettercap ]; then # cd for the bettercap repo
		echo "${GRN}- /usr/local/bin/bettercap already exists"
		cd /usr/local/bin/bettercap
	else
		echo "${YLW}- Creating directory /usr/local/bin/bettercap"
		mkdir /usr/local/bin/bettercap && cd /usr/local/bin/bettercap # will cd on success of mkdir
	fi # end of bin/bettercap if
	git clone https://github.com/bettercap/bettercap.git # clone github.com/bettercap/bettercap... This one didn't work
	cd bettercap # idk how the below line works... kinda neat!
	echo "- Building from $(pwd) repo"
	make build # idk how this one works either... also neat!
	echo "- Make install from $(pwd)"
	make install # idk how this works either! need to look into it.
	echo -e "${CLR}- golang has successfully installed with version ${CYN}$(go --version)"
} # end of install() function

if (( $EUID != 0 )); then # check is script has been run as sudo
	echo "${YLW}- Run as root/sudo"
	usage; exit 0 # exit without error
fi # end of $EUID if

if [ $# -eq 0 ]; then # if no params are parsed through, display the -h|--help menu using the usage() function
	echo "${YLW}$0: no parameter parsed"
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
