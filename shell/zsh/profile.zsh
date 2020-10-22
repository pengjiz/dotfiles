# Personal information
export NAME='Pengji Zhang'
export EMAIL='me@pengjiz.com'

# Default application
export EDITOR='nano'
export VISUAL="$EDITOR"
export BROWSER='xdg-open'
export TERMINAL='urxvt'

# SSH agent
eval "$(ssh-agent)"

# z
export _Z_DATA="$HOME/.local/share/z"

# Ledger
export LEDGER_FILE="$HOME/Sync/ledger/finances.ledger"
export LEDGER_PRICE_DB="$HOME/Sync/ledger/pricedb.ledger"

# Webmark
export WEBMARK_FILE="$HOME/Sync/misc/webmark.json"

# Rust cargo
function {
  local cargo_bin="$HOME/.cargo/bin"
  if [[ -d "$cargo_bin" ]]; then
    export PATH="$cargo_bin:$PATH"
  fi
}

# Rust source
function {
  if [[ -x "$(command -v rustup)" ]]; then
    local rust_src="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
    if [[ -d "$rust_src" ]]; then
      export RUST_SRC_PATH="$rust_src"
    fi
  fi
}

# Local binary
function {
  local local_bin="$HOME/.local/bin"
  if [[ -d "$local_bin" ]]; then
    export PATH="$local_bin:$PATH"
  fi
}

# Start X session
[[ -z "$DISPLAY" && $XDG_VTNR -eq 1 ]] && exec sx
