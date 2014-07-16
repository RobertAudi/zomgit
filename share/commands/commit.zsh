gc() {
  command git commit ${@}
}

gcv() {
  gc --verbose ${@}
}
