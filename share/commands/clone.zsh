gcl() {
  local params
  params=( clone --recursive )

  if (( $# == 0 )); then
    params=( $params $(pbpaste) )
  else
    params=( $params ${@} )
  fi

  if type hub > /dev/null; then
    command hub ${params[@]}
  elif type gh > /dev/null; then
    command gh ${params[@]}
  else
    command git ${params[@]}
  fi
}
