# Option

## Glob
shopt -s globstar

## Redirect
set -o noclobber

## History
HISTFILE="$HOME/.local/share/bash/history"
HISTSIZE=2000
HISTFILESIZE=10000
HISTTIMEFORMAT='%F %T '
HISTCONTROL='ignorespace'
shopt -s histappend
set +o histexpand

## Directory navigation
shopt -s autocd

## Prompt
PS1='\W > '

## Key binding
set -o emacs

# Command

## Environment
export EDITOR='nvim'
export VISUAL="$EDITOR"
export AUR_PAGER='nvim'

## Plugin
[[ -r '/usr/share/z/z.sh' ]] && . '/usr/share/z/z.sh'

## Function
### Make a directory and cd to it
function mkcd {
  mkdir -pv "$1" && cd "$1"
}

## Alias
alias l='ls -AlhF --color=auto'
alias g='git'
alias vim='nvim'
alias vi='nvim'
