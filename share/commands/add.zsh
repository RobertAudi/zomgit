ga() {
  local gitopts
  local fileopts
  local options
  local files

  gitopts=()
  options=()

  if (( $# == 0 )); then
    fileopts="."
    options=( --filter unstaged )
  else
    local opts

    gitopts=( $(echo "${@}" | command grep -o -E "(--( (.*)))$" | command sed -E "s/^-- ?//") )
    opts=( $(echo "$@" | sed -E "s/(.*)(--( .*))$/\1/g") )

    # Remove the git options from the regular options array
    set -- "${opts[@]}"

    #
    # Parse ZOMGit options
    #
    local opt_filter
    local opt_greedy
    local opt_refine

    opt_filter=( unstaged )
    opt_greedy=()
    opt_refine=()

    zparseopts -K -D f:=opt_filter -filter:=opt_filter g=opt_greedy G=opt_greedy -greedy=opt_greedy -no-greedy=opt_greedy r=opt_refine -refine=opt_refine

    local filter=${opt_filter[${#opt_filter}]}
    local greedy=${opt_greedy[${#opt_greedy}]}
    local refine=${#opt_refine}

    if [[ "${filter}" != "" ]]; then
      options=( $options --filter $filter )
    fi

    if [[ "${greedy}" != "" && "${greedy}" =~ "G|no" ]]; then
      options=( $options $greedy )
    fi

    if (( $refine > 0 )); then
      options=( $options --refine )
    fi

    if (( $# == 0 )); then
      fileopts="."
    else
      fileopts="$@"
    fi
  fi

  if (( ${#gitopts} == 0 )); then
    gitopts=( -A )
  else
    typeset -U gitopts
  fi

  files="$(zomgit find ${options[@]} ${fileopts} 2>&1)"
  local exitcode=$?

  if (( ${exitcode} > 0 )); then
    echo "${fg[red]}${files}${reset_color}"
    return ${exitcode}
  fi

  local params
  params=( add ${gitopts[@]} $(echo ${files} | command tr '\n' ' ') )

  if type hub > /dev/null; then
    command hub ${params[@]}
  elif type gh > /dev/null; then
    command gh ${params[@]}
  else
    command git ${params[@]}
  fi

  zomgit status
}

gau() {
  ga --filter untracked ${@}
}

gap() {
  ga ${@} -- -p
}
