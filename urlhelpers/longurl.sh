#! /bin/bash
#

# Use curl to find the actual url after following any and all redirects
#
# Essentially, this is an a URL lengthener
#

# Requires curl
#
if ! type curl >/dev/null 2>&1; then
  echo "ERROR: Requires curl, but can't find curl.";
  exit 1;
fi

# -----------------------------------------------------------------------------+
# function longurl_method_head()
#
# Retrieves the ultimate URL, after following the chain of redirection,
# using the HTTP HEAD method.
#
function longurl_method_head() {

  longurl_method_head=""

  # First argument should be the URL
  #
  if [ -z "$1" ]; then
    return 0
  fi
  local url_="$1"
  local allheaders_=()
  local lines_=""
  local headers_=()
  local quality_=0
  local long_url_=""
  local showheaders_=0
  if [ ! -z "$2" ]; then
    showheaders_=$2
  fi

  # Clean out cookies
  #
  if [[ -f "/var/tmp/longurl.cookies" ]]; then
    rm /var/tmp/longurl.cookies
  fi

  # Captures the headers
  #
  IFS=$'\n' GLOBIGNORE='*' command eval \
    'allheaders_=( $( curl -I -b /var/tmp/longurl.cookies -c /var/tmp/longurl.cookies -L -s "$url_" ) )'
  IFS=$'\n' lines_="${allheaders_[*]}"
  IFS=$'\n' GLOBIGNORE='*' command eval \
    'headers_=( $( echo "$lines_" | egrep "^HTTP|^[Ll]ocation:" ) )'

  # Display the headers
  #
  if (( 0 != $showheaders_ )); then
    echo "$lines_"
  fi

  # Process the headers
  #
  quality_=0
  long_url_="$url_"
  for (( i=0; i < ${#headers_[@]}; ++i ))
  do
    # If we hit a bad header, then skip remaining lines
    #
    if (( 0 != $quality_ )); then
      continue
    fi

    # Check header
    #
    re_='^HTTP.*\ +([0-9]+)\ *'
    if [[ ${headers_[i]} =~ $re_ ]]; then
      code_=${BASH_REMATCH[1]}
      if (( 200 > $code_ )) || (( 400 <= $code_ )); then
        # fatal error
        quality_=1
        break
      elif (( 301 == $code_ )); then
        continue; # look for location header
      elif (( 302 == $code_ )); then
        continue; # look for location header
      elif (( 303 == $code_ )); then
        continue; # look for location header
      else
        break; # done looking, probably at end of redirection chain
      fi
    fi

    # Update location
    #
    re_='^[Ll]ocation:\ ([^ ].*)[ ]*$'
    if [[ ${headers_[i]} =~ $re_ ]]; then
      long_url_="${BASH_REMATCH[1]}"
    fi
  done

  # strip CR, LF
  #
  long_url_="${long_url_//$'\r'/}"
  long_url_="${long_url_//$'\n'/}"

  # strip bad encoding and embedded spaces
  #
  # long_url_="${long_url_//$'%[8A-F][0-9A-F]'/}"
  # long_url_="${long_url_//$' '/}"

  # Get out
  #
  longurl_method_head="${long_url_}"
  return $quality_
}

# -----------------------------------------------------------------------------+
# function longurl_method_get()
#
# Retrieves the ultimate URL, after following the chain of redirection,
# using the HTTP GET method.
#
function longurl_method_get() {

  longurl_method_get=""

  # First argument should be the URL
  #
  if [ -z "$1" ]; then
    return 0
  fi
  local url_="$1"
  local allheaders_=()
  local lines_=""
  local headers_=()
  local quality_=0
  local long_url_=""
  local showheaders_=0
  if [ ! -z "$2" ]; then
    showheaders_=$2
  fi

  # Clean out cookies
  #
  if [[ -f "/var/tmp/longurl.cookies" ]]; then
    rm /var/tmp/longurl.cookies
  fi

  # Captures the headers
  #
  IFS=$'\n' GLOBIGNORE='*' command eval \
    'allheaders_=( $( curl -i -b /var/tmp/longurl.cookies -c /var/tmp/longurl.cookies -L -s "$url_" ) )'
  IFS=$'\n' lines_="${allheaders_[*]}"
  IFS=$'\n' GLOBIGNORE='*' command eval \
    'headers_=( $( echo "$lines_" | egrep "^HTTP|^[Ll]ocation:" ) )'

  # Display the headers
  #
  if (( 0 != $showheaders_ )); then
    echo "$lines_"
  fi

  # Process the headers
  #
  quality_=0
  long_url_="$url_"
  for (( i=0; i < ${#headers_[@]}; ++i ))
  do
    # If we hit a bad header, then skip remaining lines
    #
    if (( 0 != $quality_ )); then
      continue
    fi

    # Check header
    #
    re_='^HTTP.*\ +([0-9]+)\ *'
    if [[ ${headers_[i]} =~ $re_ ]]; then
      code_=${BASH_REMATCH[1]}
      if (( 200 > $code_ )) || (( 400 <= $code_ )); then
        # fatal error
        quality_=1
        break
      elif (( 301 == $code_ )); then
        continue; # look for location header
      elif (( 302 == $code_ )); then
        continue; # look for location header
      elif (( 303 == $code_ )); then
        continue; # look for location header
      else
        break; # done looking, probably at end of redirection chain
      fi
    fi

    # Update location
    #
    re_='^[Ll]ocation:\ ([^ ].*)[ ]*$'
    if [[ ${headers_[i]} =~ $re_ ]]; then
      long_url_="${BASH_REMATCH[1]}"
    fi
  done

  # strip CR, LF
  #
  long_url_="${long_url_//$'\r'/}"
  long_url_="${long_url_//$'\n'/}"

  # strip bad encoding and embedded spaces
  #
  # long_url_="${long_url_//$'%[8A-F][0-9A-F]'/}"
  # long_url_="${long_url_//$' '/}"

  # Get out
  #
  longurl_method_get="${long_url_}"
  return $quality_
}

# parse arguments
#
argcount_=$#
args_=( "$@" )
showheaders_=0
url_=""
badargs_=0
showedhelp_=0
skip_=0
i=0
while (( argcount_ > $i )); do
  if (( 0 != $showedhelp_ )); then
    break;
  fi
  if (( 0 != $skip_ )); then
    skip_=0
    (( ++i ))
    continue
  fi
  case "${args_[$i]}" in
    -\?|-h|--help )
      echo "longurl [-I|--headers] URL"
      echo ""
      showedhelp_=1
      ;;
    -I|--headers )
      showheaders_=1
      ;;
    -* )
      echo "ERROR: unrecognized argument '${args_[$i]}'."
      echo ""
      echo "usage: longurl [-I|--headers] URL"
      echo ""
      badargs_=1
      ;;
    * )
      if [ ! -z "${url_}" ]; then
        echo "ERROR: unexpected argument '${args_[$i]}'."
        echo ""
        echo "usage: longurl [-I|--headers] URL"
        echo ""
        badargs_=1
      else
        url_="${args_[$i]}"
      fi
      ;;
  esac
  (( ++i ))
done

if (( 0 != $badargs_ )); then
  exit 1
fi
if (( 0 != $showedhelp_ )); then
  exit 1
fi
if [ -z "${url_}" ]; then
  echo "ERROR: Missing URL"
  echo ""
  echo "usage: longurl [-I|--headers] URL"
  echo ""
  exit 1
fi

longurl_method_head "${url_}" "${showheaders_}"
quality_=$?
long_url_="${longurl_method_head}"
if (( 0 != $quality_ )); then
  longurl_method_get "${url_}" "${showheaders_}"
  quality_=$?
  long_url_="${longurl_method_get}"
fi

# if stdout is going to the terminal, include a line feed; otherwise not
#
if [ -t 1 ]; then
  echo "${long_url_}"
else
  echo -n "${long_url_}"
fi

# Get out
#
exit $quality_
