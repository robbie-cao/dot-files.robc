. "$HOME/.zshenv"

[ ! -f "$HOME/.rvm/scripts/rvm" ] || . "$HOME/.rvm/scripts/rvm"
[ ! -f "$HOME/.rbenv/bin/rbenv" ] || eval "$(~/.rbenv/bin/rbenv init -)"

. "$HOME/.shrc"

shopt -s extglob cdable_vars 2>/dev/null
set -o noclobber

export HISTCONTROL=ignoredups
unset HISTFILE

if [ -x "$HOME/bin/tpope-host" ]; then
  hostcolor=`tpope-host ansi`
else
  hostcolor="01;37"
fi

[ "$UID" ] || UID=`id -u`
usercolor='01;33'
dircolor='01;34'
case "$TERM" in
  *-256color)
  usercolor='38;5;184'
  dircolor='38;5;27'
  ;;
  *-88color|rxvt-unicode)
  usercolor='38;5;56'
  dircolor='38;5;23'
  ;;
esac
[ $UID = '0' ] && usercolor="01;37"

if [ -x /usr/bin/tty -o -x /usr/local/bin/tty ]; then
  ttybracket=" [`tty|sed -e s,^/dev/,,`]"
  ttyat="`tty|sed -e s,^/dev/,,`@"
fi

PS1='\[\e['$usercolor'm\]\u\[\e[00m\]@\[\e['$hostcolor'm\]\h\[\e[00m\]:\[\e['$dircolor'm\]\w\[\e[00m\]\$ '

case "$TERM" in
  screen*|xterm*|rxvt*|Eterm*|kterm*|dtterm*|ansi*|cygwin*)
    PS1='\[\e]1;'$ttyat'\h\007\e]2;\u@\h:\w'$ttybracket'\007\]'"${PS1//01;3/00;9}"
  ;;
  linux*|vt220*) ;;
  *)
  PS1='\u@\h:\w\$ '
  ;;
esac

case $TERM in
  screen*)
    PS1="$PS1"'\[\ek'"$ttyat`[ "$STY" -o "$TMUX" ] || echo '\h'`"'\e\\\]'
    ;;
esac

[ ! -f /etc/bash_completion ] || . /etc/bash_completion

_tpope() {
  while [ -x "$HOME/bin/${COMP_WORDS[0]}-${COMP_WORDS[1]}" ]; do
    COMP_WORDS=("${COMP_WORDS[0]}-${COMP_WORDS[1]}" "${COMP_WORDS[@]:2}")
    COMP_CWORD=$((COMP_CWORD-1))
  done
  local cmd=${COMP_WORDS[0]} sub=${COMP_WORDS[1]} cur=${COMP_WORDS[COMP_CWORD]}
  if [[ $COMP_CWORD == 1 ]]; then
    COMPREPLY=($(compgen -W "$(grep '^  [a-z-]*[|)]' "$HOME/bin/$cmd" | sed -e 's/).*//' | tr '|' ' ')" "$cur"))
  else
    local selector=$(egrep "^  ([a-z-]*[|])*$sub([|][a-z-]*)*[)] *# *[_a-z-]*$" "$HOME/bin/$cmd" | sed -e 's/.*# *//')
    case "$selector" in
      hosts|ssh)
        COMPREPLY=($(compgen -W "localhost $(tpope-host list)" "$cur")) ;;
      services)
        _services ;;
      directories)
        COMPREPLY=($(compgen -d "$cur")) ;;
      precommand)
        COMPREPLY=($(compgen -c "$cur")) ;;
      nothing)
        COMPREPLY=() ;;
      *)
        COMPREPLY=($(compgen -f "$cur")) ;;
    esac
  fi
}

complete -F _tpope tpope
complete -F _services start stop restart reload force-reload

unset hostcolor usercolor dircolor ttybracket ttyat
