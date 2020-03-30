# Personal information
export NAME='Pengji Zhang'
export EMAIL='me@pengjiz.com'

# Default application
export EDITOR='nano'
export VISUAL="$EDITOR"
export BROWSER='xdg-open'
export TERMINAL='urxvt'

# Input method
export GTK_IM_MODULE='fcitx'
export QT_IM_MODULE='fcitx'
export XMODIFIERS='@im=fcitx'

# SSH agent
eval "$(ssh-agent)"

# QT theme
export QT_QPA_PLATFORMTHEME='qt5ct'

# z
export _Z_DATA="$HOME/.local/share/z"

# Ledger
export LEDGER_FILE="$HOME/Sync/ledger/finances.ledger"
export LEDGER_PRICE_DB="$HOME/Sync/ledger/pricedb.ledger"

# Webmark
export WEBMARK_FILE="$HOME/Sync/misc/webmark.json"

# Conda
conda_path='/opt/miniconda3'
conda_script="$conda_path/etc/profile.d/conda.sh"
if [ -f "$conda_script" ] && [ -r "$conda_script" ]; then
  . "$conda_script"
fi
unset conda_path
unset conda_script

# Rust cargo
cargo_bin="$HOME/.cargo/bin"
if [ -d "$cargo_bin" ]; then
  export PATH="$cargo_bin:$PATH"
fi
unset cargo_bin

# Rust source
if [ -x "$(command -v rustup)" ]; then
  rust_src="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
  if [ -d "$rust_src" ]; then
    export RUST_SRC_PATH="$rust_src"
  fi
  unset rust_src
fi

# Local binary
local_bin="$HOME/.local/bin"
if [ -d "$local_bin" ]; then
  export PATH="$local_bin:$PATH"
fi
unset local_bin
