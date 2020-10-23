# Input
setopt INTERACTIVE_COMMENTS
setopt RC_QUOTES

# Redirect
setopt APPEND_CREATE
unsetopt CLOBBER

# History
HISTFILE="$HOME/.local/share/zsh/history"
HISTSIZE=2000
SAVEHIST=10000
setopt BANG_HIST
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
unsetopt FLOW_CONTROL

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_MINUS
setopt CHASE_LINKS

# Prompt
setopt PROMPT_SUBST
autoload -Uz colors && colors
function _prompt_get_gitinfo {
  local branch=''
  branch="$(git symbolic-ref --short HEAD 2>/dev/null)" || \
    branch="$(git rev-parse --short HEAD 2>/dev/null)"

  if [[ "$branch" ]]; then
    branch="%{${fg_bold[magenta]}%}@$branch"
    if [[ "$(git status --porcelain 2>/dev/null | tail -n1)" ]]; then
      echo "$branch%{${fg_bold[yellow]}%}*"
    else
      echo "$branch"
    fi
  fi
}

function {
  local directory="%{${fg_bold[blue]}%}%c"
  local gitinfo='$(_prompt_get_gitinfo)'
  local cmdexit="%(?:%{${fg[green]}%}>:%{${fg_bold[red]}%}>)%{$reset_color%}"
  PROMPT="$directory$gitinfo $cmdexit "
}

# Key binding
bindkey -e

# Completion
autoload -Uz compinit && compinit -d "$HOME/.local/share/zsh/compdump"
setopt COMPLETE_IN_WORD
zstyle ':completion:*' menu select
bindkey '^[[Z' reverse-menu-complete

# Environment
export EDITOR='nvim'
export VISUAL="$EDITOR"
export AUR_PAGER='nvim'

# Plugin
function {
  local plugins=(
    '/usr/share/z/z.sh'
    '/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'
  )

  local plugin=''
  for plugin in "$plugins[@]"; do
    [[ -f "$plugin" ]] && . "$plugin"
  done
}

# Function
function mkcd {
  mkdir -pv "$1" && cd "$1"
}

# Alias
alias l='ls -AlhF --color=auto'
alias g='git'
alias vi='nvim'
alias vim='nvim'
