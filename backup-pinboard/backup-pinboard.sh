#! /bin/sh
#

trap "echo [backup-pinboard.sh] Caught SIGTERM!!; exit 2" SIGTERM
echo "[backup-pinboard.sh] Starting ..."

# function sleepFor()
#
# Sleep for $1 number of seconds
#
sleepFor() {
	SLPSECS_=$1
	SLPCNT_=0
	while [[ $SLPCNT_ -lt $SLPSECS_ ]]
	do
		let "SLPCNT_ += 1"
		sleep 1
	done
}

# Get number of copies to keep
#
if [ -z "$1" ]
then
	SAVECNT_=10
else
	SAVECNT_=$1
fi

# Get today's date
#
DTNOW_=`date "+%Y%m%d"`

# Get all the bookmarks in XML format
#
sleepFor 320
curl https://{{pbuser}}:{{pbpwd}}@api.pinboard.in/v1/posts/all \
  --retry 1 --retry-delay 320 -o pinboard-bookmarks.xml
if [[ 0 -ne $? ]]
then
  echo "[backup-pinboard.sh] Failed to retrieve the bookmarks in XML format."
  echo "[backup-pinboard.sh] ... Exiting"
  exit $?
fi
if [ -e "pinboard-bookmarks.xml" ]
then
	cp "pinboard-bookmarks.xml" "pinboard-bookmarks.$DTNOW_.xml"
fi

# Get all the bookmarks in JSON format
#
sleepFor 320
curl https://{{pbuser}}:{{pbpwd}}@api.pinboard.in/v1/posts/all?format=json \
  --retry 1 --retry-delay 320 -o pinboard-bookmarks.json
if [[ 0 -ne $? ]]
then
  echo "[backup-pinboard.sh] Failed to retrieve the bookmarks in JSON format."
  echo "[backup-pinboard.sh] ... Exiting"
  exit $?
fi
if [ -e "pinboard-bookmarks.json" ]
then
	cp "pinboard-bookmarks.json" "pinboard-bookmarks.$DTNOW_.json"
fi

# Clean up the older XML files
#
NXML_=`ls -1 *.*.xml | wc -l`
if [[ 10 -lt $NXML_ ]]
then
	let "NDEL_ = $NXML_ - 10"
	for file in `ls -1 *.*.xml`
	do
	    if [[ 0 -lt $NDEL_ ]]
	    then
			rm $file
			let "NDEL_ -= 1"
		fi
	done
fi

# Clean up the older JSON files
#
NJSON_=`ls -1 *.*.json | wc -l`
if [[ 10 -lt $NJSON_ ]]
then
	let "NDEL_ = $NJSON_ - 10"
	for file in `ls -1 *.*.json`
	do
	    if [[ 0 -lt $NDEL_ ]]
	    then
			rm $file
			let "NDEL_ -= 1"
		fi
	done
fi

# Get out
#
echo "[backup-pinboard.sh] ... Exiting"
exit 0
#
# EOF