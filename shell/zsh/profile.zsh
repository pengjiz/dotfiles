# Personal information
export NAME='Pengji Zhang'
export EMAIL='me@pengjiz.com'

# Default application
export EDITOR='nvim'
export VISUAL="$EDITOR"
export AUR_PAGER='nvim'

# SSH agent
[[ -z "$SSH_AUTH_SOCK" ]] && eval "$(ssh-agent)"

# z
export _Z_DATA="$HOME/.local/share/z"

# Ledger
export LEDGER_FILE="$HOME/Sync/ledger/finances.ledger"
export LEDGER_PRICE_DB="$HOME/Sync/ledger/pricedb.ledger"

# Webmark
export WEBMARK_FILE="$HOME/Sync/misc/webmark.json"

# Rust
function {
  local directory="$HOME/.cargo/bin"
  [[ -d "$directory" ]] && path=("$directory" "$path[@]")

  if [[ -x "$(command -v rustc)" ]]; then
    directory="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
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
