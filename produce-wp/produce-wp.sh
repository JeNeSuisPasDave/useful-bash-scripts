#! /bin/sh
#

# Check and capture command line arguments
#
PB_=x
FN_=x
if [ -z "$1" ]
then
	echo "Need to supply a filename (sans extension)."
	exit 1
fi
if [ -z "$2" ]
then
	FN_=$1
else
	FN_=$2
	PB_=$1
	if [ "-pb" != $PB_ ]
	then
		echo "Bad argument: $PB_"
		exit 2
	fi
fi

# Get the actual directory of the produce script so that we
# can find the munge-wp.pl script
#
DIR_=$( cd "$( dirname "$0" )" && pwd )

# Determine the input file
#
SRC_=$FN_.mmd
if [[ ! -f $SRC_ ]]
then
	SRC_=$1.md
fi
if [[ ! -f $SRC_ ]]
then
	echo Neither '$1.mmd' nor '$1.md' exist.
	echo Failed.
	exit 3
fi

# Determine the footnote distinguishing hex byte
#
FNHEX_=`echo -n $FN_ | md5 | sed  's/^..*\(..\)$/\1/'`

# Produced the Wordpress-ready output
#
if [ "-pb" == $PB_ ]
then
	multimarkdown $SRC_ | grep -v "^<?xml" \
		| /xpt/local/bin/tidy -wrap 0 \
		| perl $DIR_/munge-wp.pl -pb -fn $FNHEX_ | pbcopy
else
	multimarkdown $SRC_ | grep -v "^<?xml" \
		| /xpt/local/bin/tidy -wrap 0 \
		| perl $DIR_/munge-wp.pl -fn $FNHEX_ > $1.html
fi
