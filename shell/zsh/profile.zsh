# Personal information
export NAME='Pengji Zhang'
export EMAIL='me@pengjiz.com'
export PACKAGER='Pengji Zhang <me@pengjiz.com>'

# Default application
export EDITOR='nvim'
export VISUAL="$EDITOR"
export DIFFPROG='nvim -d'
export AUR_PAGER='nvim'

# SSH agent
[[ -z "$SSH_AUTH_SOCK" ]] && eval "$(ssh-agent)"

# z
export _Z_DATA="$HOME/.local/share/z"

# Ledger
function {
  local data="$HOME/Sync/ledger/finances.ledger"
  [[ -f "$data" ]] && export LEDGER_FILE="$data"

  data="$HOME/Sync/ledger/pricedb.ledger"
  [[ -f "$data" ]] && export LEDGER_PRICE_DB="$data"
}

# Webmark
export WEBMARK_FILE="$HOME/Sync/misc/webmark.json"

# Rust
function {
  local directory="$HOME/.cargo/bin"
  [[ -d "$directory" ]] && path=("$directory" "$path[@]")

  if [[ -x "$(command -v rustc)" ]]; then
    directory="$(rustc --print sysroot)/lib/rustlib/src/rust/library"
    [[ -d "$directory" ]] && export RUST_SRC_PATH="$directory"
  fi
}

# Local binary
function {
  local directory="$HOME/.local/bin"
  [[ -d "$directory" ]] && path=("$directory" "$path[@]")
}

# Finish
export PATH
[[ -z "$DISPLAY" && $XDG_VTNR -eq 1 ]] && exec sx
