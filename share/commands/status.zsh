gs() {
  local gitopts
  local opts

  gitopts=( $(echo "${@}" | command grep -o -E "(--( (.*)))$" | command sed -E "s/^-- ?//") )
  opts=( $(echo "$@" | sed -E "s/(.*)(--( .*))$/\1/g") )

  # Remove the git options from the regular options array
  set -- "${opts[@]}"

  #
  # Parse ZOMGit options
  #
  local opt_filter
  opt_filter=()

  zparseopts -K -D f:=opt_filter -filter:=opt_filter

  if (( ${#gitopts[@]} > 0 )); then
    command git status ${gitopts[@]}
  else
    local filter=""

    if (( ${#opt_filter[@]} > 0 )); then
      filter="--filter ${opt_filter[${#opt_filter[@]}]}"
    fi

    zomgit status ${filter}
  fi
}
