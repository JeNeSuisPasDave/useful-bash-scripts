#! /bin/sh
#
# Arguments: subdirectories
#

badArgs() {
	echo "Install failed. Bad argument list."
	echo "Arguments are pinboard userid, pinboard password, user subdirectory"
	exit 2
}

# Capture substitution values
#
if [ -z "$1" ]
then
	badArgs
else
	SUBDIR_=$1
	SUBDIRQ_=`echo -n $1 | sed 's!/!\\\\/!g' | sed "s/\-n //"`
fi
UID_=`whoami`

# Remove scripts
#
SCRIPTTGT_=/Users/$UID_/$SUBDIR_/backup-pinboard.sh
AGENTTGT_=/Users/$UID_/Library/LaunchAgents/net.localhost.PinboardBackup.plist

echo SUBDIR_ is $SUBDIR_

echo "Starting."

if [ -e "$AGENTTGT_" ]
then
	launchctl unload -w -S Background "$AGENTTGT_"
	echo "... Unloaded agent"
fi
if [ -e "$AGENTTGT_" ]
then
	rm "$AGENTTGT_"
	echo "... Removed agent plist file"
fi
if [ -e "$SCRIPTTGT_" ]
then
	rm "$SCRIPTTGT_"
	echo "... Removed backup script file"
fi

# Get out
#
echo "Done."
exit 0
#
# EOF