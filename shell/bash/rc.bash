# Glob
shopt -s globstar

# Redirect
set -o noclobber

# History
HISTFILE="$HOME/.local/share/bash/history"
HISTSIZE=2000
HISTFILESIZE=10000
HISTTIMEFORMAT='%F %T '
HISTCONTROL='ignorespace'
shopt -s histappend

# Directory navigation
shopt -s autocd

# Prompt
PS1='\W > '

# Key binding
set -o emacs

# Plugin
[[ -f '/usr/share/z/z.sh' ]] && . '/usr/share/z/z.sh'

# Function
function mkcd {
  mkdir -pv "$1" && cd "$1"
}

# Alias
alias l='ls -AlhF --color=auto'
alias g='git'
alias vi='nvim'
alias vim='nvim'
