#! /bin/sh
#
# Arguments: pbuser pbpwd subdirectories
#

badArgs() {
	echo "Install failed. Bad argument list."
	echo "Arguments are pinboard userid, pinboard password, user subdirectory \
without leading or trailing directory separator. For example: \"./install.sh \
pbuser pbpwd Documents/Backups/Pinboard\""
	exit 2
}

# Capture substitution values
#
if [ -z "$1" ]
then
	badArgs
else
	PBUSER_=$1
fi
if [ -z "$2" ]
then
	badArgs
else
	PBPWD_=$2
fi
if [ -z "$3" ]
then
	badArgs
else
	SUBDIR_=$3
	SUBDIRQ_=`echo -n $3 | sed 's!/!\\\\/!g' | sed "s/\-n //"`
fi
UID_=`whoami`

# Copy script to SUBDIR_
#
SCRIPTTGT_=/Users/$UID_/$SUBDIR_/backup-pinboard.sh
AGENTTGT_=/Users/$UID_/Library/LaunchAgents/net.localhost.PinboardBackup.plist
OVERWRITE_=0
if [ -e "$SCRIPTTGT_" ] \
|| [ -e "$AGENTTGT_" ]
then
	echo -n "Do you want to overwrite existing files? [yes/no] "
	read YN_
	if [[ "yes" -ne $YN_ ]]
	then
		echo "Aborting install; existing files."
		exit 4
	fi
	OVERWRITE_=1
fi

echo "Starting."

if [ -e "$AGENTTGT_" ]
then
	launchctl unload -w -S Background "$AGENTTGT_"
	echo "... Unloaded agent"
fi

cat backup-pinboard.sh | \
	sed s/{{pbuser}}/$PBUSER_/ | \
	sed s/{{pbpwd}}/$PBPWD_/ > \
	"$SCRIPTTGT_"
chmod u+x "$SCRIPTTGT_"
chmod go-rwx "$SCRIPTTGT_"
echo "... Installed backup script"
cat net.localhost.PinboardBackup.plist | \
	sed s/{{userid}}/$UID_/ | \
	sed "s/{{subdir}}/$SUBDIRQ_/" > \
	"$AGENTTGT_"
echo "... Installed user agent plist file"

launchctl load -w -S Background "$AGENTTGT_"
echo "... loaded agent to schedule backup script execution"

# Get out
#
echo "Done."
exit 0
#
# EOF