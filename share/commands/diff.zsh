gd() {
  local gitopts
  local fileopts
  local options
  local files

  gitopts=()
  options=()

  if (( $# == 0 )); then
    fileopts="."
    options=( --filter modified )
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

    opt_filter=( modified )
    opt_greedy=()
    opt_refine=()

    zparseopts -K -D f:=opt_filter -filter:=opt_filter g=opt_greedy G=opt_greedy -greedy=opt_greedy -no-greedy=opt_greedy r=opt_refine -refine=opt_refine

    local filter=${opt_filter[${#opt_filter}]}
    local greedy=${opt_greedy[${#opt_greedy}]}
    local refine=${#opt_refine}

    if [[ "${filter}" != "" ]]; then
      if ! [[ "${filter}" =~ "modified|staged" ]]; then
        echo "${fg[red]}You can only diff files that are either\ntracked or in the staging area!${reset_color}"
        return 1
      fi

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

  if (( ${#gitopts} > 0 )); then
    typeset -U gitopts
  fi

  files="$(zomgit find ${options[@]} ${fileopts} 2>&1)"
  local exitcode=$?

  if (( ${exitcode} > 0 )); then
    echo "${fg[red]}${files}${reset_color}"
    return ${exitcode}
  fi

  local params
  params=( diff ${gitopts[@]} $(echo ${files} | command tr '\n' ' ') )

  if type hub > /dev/null; then
    command hub ${params[@]}
  elif type gh > /dev/null; then
    command gh ${params[@]}
  else
    command git ${params[@]}
  fi
}

gdc() {
  gd --filter staged ${@} -- --cached
}
