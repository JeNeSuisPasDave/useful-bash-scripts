#! /bin/bash
#
# Process a directory of git repos, fetching all remotes and updating
# the default local branch.
#
for dir in `find . -maxdepth 1 -type d -print | grep -v ^\.$ | grep -v ^\.\.$`; do
  echo -e "\033[1;32m${dir##*/}\033[0m"
  cd ${dir##*/}
  git fetch --all
  git remote prune origin
  git pull --ff-only
  cd ..
done
