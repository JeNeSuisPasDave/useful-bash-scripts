#! /bin/bash
#
# Process a directory of mirrored git repos, updating from the remote.
#
for dir in `find . -maxdepth 1 -type d -print | grep -v ^\.$ | grep -v ^\.\.$`; do
  echo -e "\033[1;32m${dir##*/}\033[0m"
  cd ${dir##*/}
  git remote update --prune
  cd ..
done
