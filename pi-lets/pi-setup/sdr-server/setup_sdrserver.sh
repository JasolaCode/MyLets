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
	echo "install/remove/upgrade golang instance in the RPi environment."
	echo ""
	echo "Options:" # this area shows how to parse parameters into the script as intended with brief definitions
	echo "  -i, --install     Perform a fresh install of golang on the RPi."
	echo "  -u, --upgrade     Upgrade an existing instance of golang (as previously installed by this script)."
	echo "  -r, --remove      Remove an existing instance of golang (as previously installed by this script)."
	echo "  -h, --help        Display usage information for this script."
	echo ""
	exit 0 # exit without error
} # end of usage() function

function remove {
	echo "- remove() function hasn't been implemented yet"; exit 0 # exit with no error
}

function upgrade {
	echo "- upgrade() function hasn't been implemented yet"; exit 0 # exit with no error
}

function install {
	HMDIR=$(echo ~)
	echo -e "${CYN}- Updating and upgrading package environment"
	sudo apt-get install git cmake libusb-1.0-0.dev build-essential # install dependencies, creating dir for the server to be in
	
	if [ -d  /usr/local/bin/sdr-server]; then
		echo -e "${GRN}- Directory /usr/local/bin/sdr-server already exists"
		cd /usr/local/bin/sdr-server
	else
		echo -e "${YLW}- Creating directory /usr/local/bin/sdr-server"
		mkdir /usr/local/bin/sdr-server && cd /usr/local/bin/sdr-server
	fi	
	
	git clone git://git.osmocom.org/rtl-sdr.git $HMDIR/repos/ #clone git repo to run the sdr-server operations
	cd $HMDIR/repos/rtl-sdr/
	
	mkdir build # installation process according to repo instructions
	cd build
	cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
	make
	echo "- Performing make install"
	make install
	ldconfig
	echo "- Performing install-udev-rules for non-root user access"
	make install-udev-rules

	# expect output of 'lsusb' to include: Bus 001 Device 003: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
	if [ echo $(lsusb) | grep "DVB-T" ]; then
		echo -e "${GRN}- Device ${PUR}$(echo $(lsusb) | grep "DVB-T")${GRN} successfully attached"
	else
		echo -e "${RED}- RTL Device failed to attach"; exit 1 # exit with general error
	fi # end of lsusb if

	# the below line needs to be injected into the file being mentioned 
	echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="adm", MODE="0666", SYMLINK+="rtl_sdr"' >> /etc/udev/rules.d/20.rtlsdr.rules

	if [ grep -q 'SYMLINK+="rtl_sdr"' ]; then
		echo -e "${GRN}- File /etc/udev/rules.d/20.rtlsdr.rules successfully updated with rules"
	else
		echo -e "${RED}- Failed to update rules in file /etc/udev/rules.d/20.rtlsdr.rules"
	fi	# end of SYMLINK if

	echo "- Adding symlink for RTL dongle"
	# Add a symlink when dongle is attached
	udevadm control --reload-rules
	udevadm trigger

	
	if [ -d /dev/rtl_sdr ]; then # ensure that this directory is created by udev
		echo -e "${GRN}- Successfully created symlink for device /dev/rtl_sdr"
	else
		echo -e "${RED}- Faied to create symlink for device /dev/rtl_sdr"
	fi # end of /dev/rtl_sdr if

	#test the device
	echo $(rtl_test)

	echo -e "${CLR}run ${CYN}rtl_tcp -a 192.168.0.154"
	echo -e "${CLR}Use 'lsusb' to list the currently plugged in devices"
	echo -e "${CLR}In GQRX, for I/O device, put in ${CYN}rtl_tcp=192.168.0.154:1234"
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
