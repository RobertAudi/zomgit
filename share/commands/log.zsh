gl() {
  command git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit ${@}
}

gla() {
  gl --branches --remotes ${@}
}

gls() {
  gl --stat ${@}
}
