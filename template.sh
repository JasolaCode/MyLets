#!/bin/bash
#
#template_script.sh

function usage { # example of a --help parameter which is parsed through to display information
	echo "" # $0 is a default variable used for the filename of script
	echo "Usage: $0 [-s|--stringlength] [-u|--uppercase] [-l|--lowercase] [-n|--nonums] [-h|--help]" # an understandable layout to display paramaters for script
	echo "Generate a string of minimum length 12, optionally change what can be generated in string."
	echo ""
	echo "Options:" # thi area shows how to parse parameters into the script as intended with brief definitions
	echo "  -s, --stringlength      Using an int, define the length of the string.There is no default value."
	echo "  -u, --uppercase         Define parameter to exclude uppercase alphabet characters from string."
	echo "  -l, --lowercase         Define paramter to exclude lowercase alphabet characters from string."
	echo "  -n, --nonums            Define to exclude number characters from string."
	echo "  -h, --help              Display usage information for this script."
	echo ""
	exit 0 # exit without error
}

function if_contains() { # make sure this function finishes with exit codes to manage if,else,while statements. Seen on line #26
	echo "- String contains $1"; exit 0 # exit without error
}

function generate_string { # placeholder to show if_contains() function parsing
	echo "- Blah blah, I make strings"
	if [ $(if_contains "inside") ]; then # using if_contains() function to resolve if statement
		echo "- It is in the string!"
	else
		echo "- It's not in the string"
	fi
}

#########################
# Main Function Content #
#########################

if (( $EUID != 0 )); then # check is script has been run as sudo
	echo "- Run as root/sudo"
	usage; exit 0 # exit without error
fi # end of $EUID if

if [ $# -eq 0 ]; then # if no params are parsed through, display the -h|--help menu using the usage() function
	echo "$0: no parameter parsed"
  	usage; exit 0 # exit without error
fi # end of $# if

while [[ $# -gt 0 ]]; do # while loop is used to assign paramaters parsed through in command line
	case $1 in # $1 represents a parsed in variable
		-s|--stringlength) # for parameters which accept a value, we use two 'shift'/s
			STRINGLENGTH="$2" # assigns the value parsed with -s to variable
			shift
			shift;;
		-u|--uppercase) # for parameters that don't require a value, only one 'shift' is required
			UPPERCASE=true # sets variable UPPERCASE to true
			shift
			;;
		-l|--lowercase) # for parameters that don't require a value, only one 'shift' is required
			LOWERCASE=true # sets variable LOWERCASE to true
			shift
			;;
		-n|--nonums) # for parameters that don't require a value, only one 'shift' is required
			NONUMS=true # sets variable NONUMS to true
			shift
			;;
		-h|--help) # for parameters that don't require a value, only one 'shift' is required
			usage # calls function usage() to be run
			shift
			;;
		*) # I clearly don't know how to use it... Help me out by showing the usage() function
			echo "$0: incorrect parameter parsed"
		  	usage # calls function usage() to be run
			shift
			;;
	esac # end of $1 case
done # end of $# while

if [ -z "$STRINGLENGTH" ]; then # defining required paramaters for script
	echo "Missing required option: -s|--stringlength"
	usage # print for own help
fi # end of STRINGLENGTH if


#######################
# Main Script Content #
#######################

generate_string

# a helpful way to display variables at time of exiting script
echo ""
echo "---SHOWING INPUT VARIABLES---"
echo ""
echo "[-s|--stringlength] = $STRINGLENGTH"
echo "[-u|--uppercase] = $UPPERCASE"
echo "[-l|--lowercase] = $LOWERCASE"
echo "[-n|--nonums] = $NONUMS"
