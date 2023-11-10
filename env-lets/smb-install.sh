#!/bin/bash
#
#smb-install.sh

set -e # easiest thing for a try/catch block

function usage { # example of a --help parameter which is parsed through to display information
	echo "" # $0 is a default variable used for the filename of script
	echo "Usage: $0 [-u|--user] [-d|--directory] [-h|--help]" # an understandable layout to display paramaters for script
	echo "Download and install the latest version of samba. Creates file share."
	echo ""
	echo "Options:" # shows how to parse parameters into the script as intended with brief definitions
	echo "  -u, --user         Define user for samba login fom remote machine. This value is required."
	echo "  -d, --directory    Define directory for the samba share. Will create path if it doesn't exist, default path will be /home/$(whoami)/smb_share"
	echo "  -h, --help         Display usage information for this script."
	echo ""
	exit 0 # exit without error
}

function install {
	MYIP=$(ip addr show $(ip route | awk '/default/ { print $5 }') | grep "inet" | head -n 1 | awk '/inet/ {print $2}' | cut -d'/' -f1)

	sudo apt install samba -y
	echo "- Installed samba version: $(samba --version)"

	echo "- Creating ~/smb_share directory" && sudo mkdir $SMBDIR
	sudo tee -a /etc/samba/smb.conf <<EOF
[smb_share]
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
}

if [ $# -eq 0 ]; then # if no params are parsed through, display the -h|--help menu using the usage() function
	echo "$0: no parameter parsed"
  	usage; exit 0 # exit without error
fi # end of $# if

while [[ $# -gt 0 ]]; do # while loop is used to assign paramaters parsed through in command line
	case $1 in # $1 represents a parsed in variable
		-u|--user) # for parameters which accept a value, we use two 'shift'/s
			SMBUSER="$2" # assigns the value parsed with -u to variable
			shift
			shift;;
		-d|--directory)
			SMBDIR="$2" # sets variable SMBDIR to parse path
			shift
			shift
			;;	
		-h|--help) # for parameters that don't require a value, only one 'shift' is required
			usage # calls function usage() to be run
			shift
			;;
		*) # I clearly don't know how to use it... Help me out by showing the usage() function
			echo "$0: incorrect parameter  parsed"
		  	usage # calls function usage() to be run
			shift
			;;
	esac # end of $1 case
done # end of $# while

if [ -z "$SMBUSER" ]; then # defining required paramaters for script
	echo "Missing required option: -u|--user"
	usage # print for own help
fi # end of STRINGLENGTH if

if [ -z "$SMBDIR" ]; then # defining required paramaters for script
 	SMBDIR=/home/$(whoami)/smb_share
fi # end of STRINGLENGTH if

install
