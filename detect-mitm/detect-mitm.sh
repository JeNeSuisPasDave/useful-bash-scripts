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
fp_expected_="A8:8E:F2:E4:9A:14:49:C8:A9:42:61:AC:B2:7F:95:20:78:A3:FF:62"
testHost_ $host_ $fp_expected_

host_="www.facebook.com"
fp_expected_="13:D0:37:6C:2A:B2:14:36:40:A6:2D:08:BB:71:F5:E9:EF:57:13:61"
testHost_ $host_ $fp_expected_

host_="www.paypal.com"
fp_expected_="DA:F3:F6:D5:3D:57:CF:CC:1C:12:37:83:67:E3:A5:39:9D:44:AE:CB"
testHost_ $host_ $fp_expected_

host_="www.wikipedia.org"
fp_expected_="DA:AA:A4:9B:AD:0C:1F:A3:29:71:D8:CC:62:BA:72:D1:A4:DB:94:9F"
testHost_ $host_ $fp_expected_

host_="twitter.com"
fp_expected_="25:6E:40:25:23:C3:41:8E:1E:9A:01:85:44:84:58:AF:96:C4:A1:BE"
testHost_ $host_ $fp_expected_

host_="www.blogger.com"
fp_expected_="0D:A4:05:E9:C4:12:5A:88:01:99:5E:8B:68:55:34:8A:E9:A6:A8:01"
testHost_ $host_ $fp_expected_

host_="www.linkedin.com"
fp_expected_="E6:74:E6:A7:5C:6A:82:A9:2C:CE:25:DF:2A:DD:1C:85:A6:AD:F0:5C"
testHost_ $host_ $fp_expected_

host_="www.yahoo.com"
fp_expected_="E4:7E:24:8E:86:D2:BE:55:C0:4D:41:A1:C2:0E:06:96:56:B9:8E:EC"
testHost_ $host_ $fp_expected_

host_="wordpress.com"
fp_expected_="E7:79:0C:AA:9D:68:F4:C1:0C:FF:36:C4:F6:2B:1A:06:C2:75:D7:74"
testHost_ $host_ $fp_expected_

host_="www.wordpress.com"
fp_expected_="4D:AF:92:8D:30:39:74:A0:C6:D3:5A:B6:CB:A2:54:66:59:FE:D4:F4"
testHost_ $host_ $fp_expected_

host_="github.com"
fp_expected_="D7:12:E9:69:65:DC:F2:36:C8:74:C7:03:7D:C0:B2:24:A9:3B:D2:33"
testHost_ $host_ $fp_expected_
