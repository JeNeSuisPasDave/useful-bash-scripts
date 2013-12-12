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
  if [ -z "$1" ]
  then
    return 1
  elif [ -z "$2" ]
  then
    return 2
  fi

  fingerprint_=$(echo -n | openssl s_client -connect $1:443 2>/dev/null \
    | openssl x509 -noout -fingerprint | cut -f2 -d'=')

  echo $fingerprint_
  if [ "$2" = "$fingerprint_" ]
  then
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
  if [[ 0 -eq $rc_ ]]
  then
    echo "$1: ok"
  else
    echo "$1: FAILED!!"
    echo "  expected: $2"
    echo "    actual: $fp_actual_"
  fi
}

host_="www.grc.com"
fp_expected_="05:0A:A7:C3:5F:85:F0:A8:5B:14:1D:B6:7F:67:8C:60:4F:2D:DE:D3"
testHost_ $host_ $fp_expected_

host_="www.facebook.com"
fp_expected_="13:D0:37:6C:2A:B2:14:36:40:A6:2D:08:BB:71:F5:E9:EF:57:13:61"
testHost_ $host_ $fp_expected_

host_="www.paypal.com"
fp_expected_="43:04:31:90:BA:8A:98:97:0C:60:B1:E9:E1:F7:0C:DC:FE:A2:85:D2"
testHost_ $host_ $fp_expected_

host_="www.wikipedia.org"
fp_expected_="DA:AA:A4:9B:AD:0C:1F:A3:29:71:D8:CC:62:BA:72:D1:A4:DB:94:9F"
testHost_ $host_ $fp_expected_

host_="twitter.com"
fp_expected_="C3:1F:6D:53:92:F2:CB:48:0A:42:79:8C:1F:BE:70:82:1D:D8:82:51"
testHost_ $host_ $fp_expected_

host_="www.blogger.com"
fp_expected_="3C:7E:F4:39:46:C1:8A:B6:F4:EB:B8:C6:A4:8C:C0:23:54:11:DC:8D"
testHost_ $host_ $fp_expected_

host_="www.linkedin.com"
fp_expected_="1B:9F:9F:CD:D6:DC:CA:1F:FF:50:86:56:29:09:8A:FB:10:CD:E3:89"
testHost_ $host_ $fp_expected_

host_="www.yahoo.com"
fp_expected_="E4:7E:24:8E:86:D2:BE:55:C0:4D:41:A1:C2:0E:06:96:56:B9:8E:EC"
testHost_ $host_ $fp_expected_

host_="wordpress.com"
fp_expected_="1A:C1:3B:AE:40:2C:67:BC:1E:EA:BD:5A:E1:4F:AE:8C:B3:A1:FE:17"
testHost_ $host_ $fp_expected_

host_="www.wordpress.com"
fp_expected_="4D:AF:92:8D:30:39:74:A0:C6:D3:5A:B6:CB:A2:54:66:59:FE:D4:F4"
testHost_ $host_ $fp_expected_

host_="github.com"
fp_expected_="D7:12:E9:69:65:DC:F2:36:C8:74:C7:03:7D:C0:B2:24:A9:3B:D2:33"
testHost_ $host_ $fp_expected_
