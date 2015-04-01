#! /bin/bash
#
# This script will detect whether there is an https proxy in between
# your client system and several well known, high value (targets for
# monitoring and attack) https servers.
#
# I heard about this fingerprinting technique for detecting MITM in an SSL/TLS
# channel from Steve Gibson of Gibson Research Corporation. See this page for
# much more detail about the technique, when and why it works, and when and
# why it isn't always useful.
#
# https://www.grc.com/fingerprints.htm
#
# Note: This code is based on a bash script found in this discussion on
# askubuntu.com:
#
# http://askubuntu.com/questions/156620/how-to-verify-the-ssl-fingerprint-by-command-line-wget-curl
#

keyfile_="keyfile.txt"

# checkFingerprint_() ---------------------------------------------------------+
#
# This method retrieves the X.509 certificate fingerprint from the https site
# and checks it agains the expected fingerprint
#
# Args:
#   $1: the hostname to check
#   $2: the expected fingerprint
#
# Returns:
#    $?: 0 if matched, 10 if unmatched, otherwise bad args
#    stdout: the detected fingerprint
#
checkFingerprint_() {
  if [ -z "$1" ]; then
    return 1
  elif [ -z "$2" ]; then
    return 2
  fi

  fingerprint_=$(echo -n | openssl s_client -connect $1:443 2>/dev/null \
    | openssl x509 -noout -fingerprint | cut -f2 -d'=')

  echo $fingerprint_
  if [ "$2" = "$fingerprint_" ]; then
    return 0
  else
    return 10
  fi
}

# checkFingerprint_() ---------------------------------------------------------+
#
# This method retrieves the X.509 certificate fingerprint from the https site
# and checks it agains the expected fingerprint
#
# Args:
#   $1: the hostname to check
#   $2: the expected fingerprint
#
testHost_() {
  fp_actual_=$(checkFingerprint_ $1 $2)
  rc_=$?
  if [[ 0 -eq $rc_ ]]; then
    echo "$1: ok"
    return 0
  else
    echo "$1: FAILED!!"
    echo "  expected: $2"
    echo "    actual: $fp_actual_"
    return 10
  fi
}

# updateFingerprints_() ---------------------------------------------------------+
#
# This method gets the current X.509 certificate fingerprint from the https site
# and writes it and the host DNS to the keyfile
#
updateFingerprints_() {
  tempfile_="temp.txt"
  > $tempfile_

  while read i; do
    host_="${i%% *}"
    fp_old_="${i##* }"
    fp_actual_=$(checkFingerprint_ $host_ $fp_old_)
    rc_=$?
    if [[ 0 -eq $rc_ ]]; then
      echo "$host_ - no change"
    else
      echo "$host_"
      echo "old: $fp_old_"
      echo "new: $fp_actual_"
    fi
    echo "$host_ $fp_actual_" >> $tempfile_
  done <$keyfile_

  mv $keyfile_ ${keyfile_}.bak
  mv $tempfile_ $keyfile_
}

# testHosts_() ---------------------------------------------------------+
#
# This method checks the X.509 certificate fingerprint from the https sites
# against the ones on file.
# If any don't match, gives the option to update
# the key file.
#
testHosts_() {
  failed_=0

  while read i; do
    host_="${i%% *}"
    fp_expected_="${i##* }"
    testHost_ $host_ $fp_expected_
    rc_=$?
    if [[ 0 -ne $rc_ ]]; then
      echo "rc: $rc_ host: $host_"
      failed_=1
    fi
  done <$keyfile_

  if [[ 0 -ne $failed_ ]]; then
    echo "Not all keys were correct. This could indicate a MITM attack,"
    echo " or that your keys are out of date. Update key file with new keys? [y/N]: "
    read ans_
    if [[ "$ans_" == "y" ]]; then
      updateFingerprints_
    fi
  fi
}

testHosts_


