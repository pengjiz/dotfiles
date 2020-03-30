# Options

## Input
setopt INTERACTIVE_COMMENTS
setopt RC_QUOTES

## Redirect
setopt NO_CLOBBER
setopt APPEND_CREATE

## History
HISTFILE="$HOME/.local/share/zsh/history"
HISTSIZE=2000
SAVEHIST=10000
unsetopt BANG_HIST
unsetopt FLOW_CONTROL
setopt EXTENDED_HISTORY
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

## Directory navigation
setopt AUTO_PUSHD
setopt PUSHD_MINUS
setopt CHASE_LINKS
setopt AUTO_CD

## Prompt
### Expansion
setopt PROMPT_SUBST
### Load colors
autoload -Uz colors && colors

### Current working directory
prompt_pwd="%{${fg_bold[blue]}%}%c"
### Last command status
prompt_last_status="%(?:%{${fg[green]}%}>:%{${fg_bold[red]}%}>)%{$reset_color%}"
### Git
function _prompt_get_git_info {
  local branch=''
  branch="$(command git symbolic-ref --short HEAD 2>/dev/null)" || \
    branch="$(command git rev-parse --short HEAD 2>/dev/null)"

  if [[ "$branch" ]]; then
    branch="%{${fg_bold[magenta]}%}@$branch"
    if [[ "$(command git status --porcelain 2>/dev/null | tail -n1)" ]]; then
      echo "$branch%{${fg_bold[yellow]}%}*"
    else
      echo "$branch"
    fi
  fi
}
prompt_git_info='$(_prompt_get_git_info)'
### Set prompt
PROMPT="$prompt_pwd$prompt_git_info $prompt_last_status "
unset prompt_pwd
unset prompt_last_status
unset prompt_git_info

## Keys
bindkey -e

## Completion
autoload -Uz compinit && compinit -d "$HOME/.local/share/zsh/compdump"
setopt COMPLETE_IN_WORD
zstyle ':completion:*' menu select
bindkey '^[[Z' reverse-menu-complete

# Commands

## Environment
export EDITOR='nvim'
export VISUAL="$EDITOR"
export AUR_PAGER='nvim'

## Plugins
[[ -r '/usr/share/z/z.sh' ]] && . '/usr/share/z/z.sh'
[[ -r '/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' ]] \
  && . '/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'

## Functions
### Make a directory and cd to it
function mkcd {
  mkdir -pv "$1" && cd "$1"
}

## Aliases
alias l='ls -AlhF --color=auto'
alias g='git'
alias vi='nvim'
alias vim='nvim'
