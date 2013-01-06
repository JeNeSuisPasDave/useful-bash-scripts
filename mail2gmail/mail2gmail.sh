#! /bin/bash
#

# User specific settings
#

# The userid of your Google account. Typically this is the first part 
# of your gmail address (e.g. "samiam" of "samiam@gmail.com").
#
USER_=NotSet

# Create an application password for your Google account and set the 
# password here. Or you can just set it to nothing (PASSWORD_=) and
# you will be prompted for the application password.
#
PASSWORD_=NotSet

# The label used if not provided on the command line. IMPORT seems
# like a reasonable default, but you will have to create that label
# in GMail if you don't have it already.
#
DEFAULT_LABEL_=IMPORT

# ------------------------------------------------
# NO CHANGES SHOULD BE REQUIRED BEYOND HERE !!!
# ------------------------------------------------


# help() ------------------------------
# Print out command syntax
#
help() {
	echo "Syntax is:"
	echo "  python imap_upload.py mbox-filename [gmail-label]"
}

# badArgs() ---------------------------
# Report problems with arguments
#
badArgs() {
	echo "Missing or extra arguments."
	help
	exit 2
}

mustSetUser() {
	echo "You must edit this script file to set your GMail user account."
	exit 4
}

mustSetPassword() {
	echo "You must edit this script file to set your GMail application password."
	exit 6
}

# accept arguments
#
if [ -z "$1" ]
then
	badArgs
else
	MBOX_=$1
fi
if [ -z "$2" ]
then
	LABEL_=$DEFAULT_LABEL_
else
	LABEL_=$2
fi
if [ ! -z "$3" ]
then
	badArgs
fi

# if --help, -?, -h, then show help
#
if [[ "--help" = $MBOX_ ]] \
|| [[ "-h" = $MBOX_ ]] \
|| [[ "-?" = $MBOX_ ]]
then
	help
	exit 0
fi

# Ensure that user account and password have been set
#
if [[ "NotSet" = $USER_ ]]
then
  mustSetUser
fi
if [ ! -z "$PASSWORD_" ] \
&& [[ "NotSet" = $PASSWORD_ ]]
then
  mustSetPassword
fi

# execute the command
#
python imap_upload.py --gmail --box="$LABEL_" \
  --user=$USER_ --password=$PASSWORD_ $MBOX_

#
# EOF