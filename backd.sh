
backd () {
  local backdir _dirstack

  if [ $# -eq 0 ]; then
    _dirstack=($(_backd_enumerate_absolute))
    pushd ${_dirstack[@][1]} > /dev/null
    return 0
  else
    backdir=$(_backd_complete --absolute "$1")
    if [ -z "$backdir" ]; then
      echo "$0: no matchs for backward directory: $1" 1>&2
      return 1
    fi
    pushd $backdir > /dev/null
  fi
}

_backd_complete () {
  local ABSOLTUE
  if [ -z "$1" ]; then
    echo "$0: operand not given." 1>&2
    return 1
  fi

  while [ $# -ne 0 ]; do
    if [ "$1" = "--absolute" ]; then
      ABSOLUTE=t; shift
    else
      break
    fi
  done

  local a x
  a=${1##/}
  for x in $(_backd_enumerate_absolute); do
    case $x in
      */$a*)
	if [ -z "$ABSOLUTE" ]; then
	  echo `basename "$x"`
        else
          echo "$x"
	fi
        return 0;;
    esac
  done
}

_backd_complete_all () {
  local ABSOLUTE
  if [ -z "$1" ]; then
    echo "$0: operand not given." 1>&2
    return 1
  fi

  while [ $# -ne 0 ]; do
    if [ "$1" = "--absolute" ]; then
      ABSOLUTE=t; shift
    else
      break
    fi
  done

  local a x
  a=${1##/}
  for x in $(_backd_enumerate_absolute); do
    case $x in
      */$a*)
	if [ -z "$ABSOLUTE" ]; then
	  echo `basename "$x"`
        else
          echo "$x"
	fi
	;;
    esac
  done
}

_backd_enumerate_absolute () {
  local a _dirstack
  local i
  local j

  if test -n "${BASH_VERSION:-}"; then
    # In Bash, Array's first index is 0.
    # And `dirs` will contain working directory.
    _dirstack=($(dirs | while read a; do eval echo $a; done)) # For tilde expansion
    j=$#_dirstack
  else
    # In Zsh, Array's first index is 1.
    # And $dirstack will not contain working directory.
    _dirstack=(${dirstack[@]})
    j=$#_dirstack
    let j=j+1
  fi

  for (( i = 1; i <= j; i++)); do
    echo ${_dirstack[$i]}
  done

}

_backd_enumerate () {
  local x _dirstack

  for x in $(_backd_enumerate_absolute); do
    echo `basename $x`
  done
}
