gco() {
  local output
  output="$(command git checkout ${@} 2>&1)"
  local exitcode=$?

  if (( $exitcode > 0 )); then
    echo "${fg[red]}Error running git checkout!${reset_color}"
    return $exitcode
  fi

  echo "${fg[green]}$(echo -n $output | command head -1)${reset_color}"

  zomgit status
}

gcob() {
  gco -b ${@}
}
