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

# Captures the headers
#
# IFS=$'\r\n' GLOBIGNORE='*' command eval \
#   'headers_=( $( curl -I -L -s $url_ | egrep "^HTTP|^Location:" ) )'
IFS=$'\n' GLOBIGNORE='*' command eval \
  'allheaders_=( $( curl -I -L -s $url_ ) )'
IFS=$'\n' lines_="${allheaders_[*]}"
IFS=$'\n' GLOBIGNORE='*' command eval \
  'headers_=( $( echo "$lines_" | egrep "^HTTP|^Location:" ) )'

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
    if (( 404 == $code_ )); then
      # 'Not Found' is OK; site might not support HEAD requests
      continue
    elif (( 200 > $code_ )) || (( 400 <= $code_ )); then
      quality_=1
      long_url_="$url_"
    fi
    continue
  fi

  # Update location
  #
  re_='^Location:\ ([^ ][^ ]*)'
  if [[ ${headers_[i]} =~ $re_ ]]; then
    long_url_="${BASH_REMATCH[1]}"
  fi
done

# strip CR and LF
#
long_url_="${long_url_//$'\r'/}"
long_url_="${long_url_//$'\n'/}"

# if stdout is going to the terminal, include a line feed; otherwise not
#
if [ -t 1 ]; then
  echo "$long_url_"
else
  echo -n "$long_url_"
fi

# Get out
#
exit $quality_
