gb() {
  command git branch ${@}
}

gba() {
  gb -a ${@}
}

gbd() {
  gb -D ${@}
}
