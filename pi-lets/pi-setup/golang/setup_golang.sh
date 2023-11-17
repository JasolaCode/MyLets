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
	sudo apt-get update && sudo apt-get upgrade -y # update/upgrade existing packages

	if [ -d ~/golang ]; then # if the directory exists
		echo "- ~/golang directory already exists"
		cd ~/golang
	else
		echo "${YLW}- Creating ~/golang directory"
		mkdir ~/golang && cd ~/golang
	fi # end of ~/golang if
	
	# this line will need to be changed to some degree. I need to compensate for future version changes to the URL
	wget https://dl.google.com/go/go1.14.4.linux-armv6l.tar.gz  # version will change, alter the URL to match the new URL
	sudo tar -C /usr/local -xzf go1.14.4.linux-armv61.tar.gz # Extract the package into your local folder
	rm go1.14.4.linux-armv61.tar.gz # not necessary to remove the .tar after install if you want to keep it
	
	echo 'GOPATH=$HOME/golang' >> ~/.profile # Append the following lines to the end of the file
	echo 'PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.profile
	source ~/.profile # Update the shell with the changes
	
	if [ $(go --version &> /dev/null) ]; then # check if golang has successfully installed
		echo "${RED}- golang didn't install properly, cannot find version"; exit 1 # exit with general error
	fi # end of --version if
	
	echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc # Append the following lines to the end of the file

	source ~/.bashrc # Run the following to implement the changes
	
	if [ echo $PATH | grep -q "GOROOT/bin" ]; then # To check that it implemented fine
		echo -e "${GRN}- golang v$(go --version) successfully installed"
	else
		echo -e "${RED}- golang failed to install"
	fi # end of $PATH if
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
