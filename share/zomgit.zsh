#!/usr/bin/env zsh

_zomgit_dir=$(dirname $(realpath $0))

# Default ZOMGit dir
export ZOMGIT_DIR=$HOME/.zomgit

# Default config
export ZOMGIT_STATUS_MAX_CHANGES=150

# Source all command files
for f in $_zomgit_dir/commands/*.zsh; do
  source $f
done
