#!/bin/bash

set -e

function log {
  local color=''
  local prefix=''
  case "$1" in
    --error)
      color='31;1'
      prefix='error'
      shift 1 ;;
    --warn)
      color='33;1'
      prefix='warning'
      shift 1 ;;
    *)
      prefix='info'
      color='32' ;;
  esac
  echo -e "\033[${color}m$prefix:\033[0m $*" >&2
}

setup_all='no'
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      setup_all='yes'
      shift 1 ;;
    *)
      log --error "Unknown argument $1"
      exit 1 ;;
  esac
done

function do_all {
  if [[ "$setup_all" == 'no' ]]; then
    return 1
  else
    return 0
  fi
}

cd "$(dirname "${BASH_SOURCE[0]}")"

log 'Prepare local AUR repository'
if ! groups "$USER" | grep -q '\bpkgr\b'; then
  log --error "User $USER not in pkgr group"
  exit 1
fi
repodir='/srv/pkgrepo'
aurdir="$repodir/aur"
aurdb="$aurdir/aur.db.tar.gz"
sudo install -d "$repodir"
sudo install -m2775 -g pkgr -d "$aurdir"
sudo setfacl -d -m g:pkgr:rwx "$aurdir"
sudo setfacl -m g:pkgr:rwx "$aurdir"
if [[ ! -f "$aurdb" ]]; then
  log 'Initialize empty AUR package database'
  sudo repo-add "$aurdb"
fi

log 'Prepare pacman'
sudo install -m644 'etc/pacman.conf' '/etc/pacman.conf'
sudo pacman -Syu --noconfirm

log 'Install packages'
pkgs=(
  # Shell
  'zsh'
  'z'
  'zsh-autosuggestions'
  'openssh'
  'shellcheck'
  'shfmt'

  # Xorg
  'xorg-server'
  'xorg-xrandr'
  'xorg-xrdb'
  'xorg-xset'
  'xorg-xprop'
  'xorg-xwininfo'
  'xorg-xev'
  'xf86-video-fbdev'
  'xf86-video-vesa'
  'sx'
  'arandr'

  # Desktop
  'i3-wm'
  'i3lock'
  'xss-lock'
  'i3blocks'
  'python-psutil'
  'rofi'
  'dunst'
  'libnotify'
  'picom'
  'redshift'
  'feh'

  # Audio
  'pulseaudio'
  'pulseaudio-alsa'

  # Printing
  'cups'
  'cups-pdf'

  # Theme
  'arc-gtk-theme'
  'papirus-icon-theme'
  'archlinux-wallpaper'
  'qt5ct'
  'kvantum'

  # Font
  'adobe-source-code-pro-fonts'
  'noto-fonts'
  'noto-fonts-cjk'
  'noto-fonts-emoji'
  'ttf-dejavu'
  'otf-font-awesome'

  # Terminal
  'xterm'

  # Editor
  'emacs'
  'neovim'

  # Browser
  'firefox'
  'firefox-i18n-en-us'
  'firefox-ublock-origin'

  # Viewer
  'evince'
  'libreoffice-still'
  'mpv'
  'mupdf-tools'

  # Image
  'graphviz'
  'gnuplot'
  'imagemagick'
  'scrot'

  # File transfer
  'udisks2'
  'rsync'
  'syncthing'

  # Help
  'man-db'
  'man-pages'
  'tldr'

  # System
  'arch-install-scripts'
  'pacman-contrib'
  'reflector'
  'rebuild-detector'
  'setconf'
  'lsb-release'
  'tlp'

  # Password
  'pass'
  'pwgen'

  # Network
  'bind'
  'openbsd-netcat'
  'ufw'

  # Utility
  'atool'
  'unzip'
  'fd'
  'ripgrep'
  'ripgrep-all'
  'bc'
  'ledger'
  'xclip'
  'trash-cli'
  'words'

  # Debugging
  'gdb'
  'ltrace'
  'strace'
  'valgrind'
  'lsof'

  # Assembler
  'nasm'

  # C & C++
  'cmake'
  'ctags'
  'doxygen'
  'gsl'
  'eigen'

  # Clojure
  'clojure'

  # Haskell
  'ghc'
  'ghc-static'
  'stack'
  'hlint'
  'stylish-haskell'

  # Web
  'nodejs'
  'npm'
  'ts-node'
  'prettier'

  # LaTeX
  'texlive-core'
  'texlive-bibtexextra'
  'texlive-latexextra'
  'texlive-science'
  'texlive-publishers'
  'texlive-pictures'
  'texlive-fontsextra'
  'biber'
  'minted'
  'ghostscript'

  # R
  'r'

  # Python
  'flake8'
  'python-black'

  # Racket
  'racket'

  # Rust
  'rustup'
  'rust-racer'
  'diesel-cli'

  # Lua
  'lua'

  # Writing
  'aspell'
  'aspell-de'
  'aspell-en'
  'hunspell'
  'hunspell-de'
  'hunspell-en_us'
  'languagetool'
  'hugo'
  'pandoc'
  'pandoc-crossref'
  'python-pygments'

  # Ansible
  'ansible'
  'ansible-lint'

  # Data
  'protobuf'
  'jq'
  'yq'
  'yamllint'

  # GIS
  'gdal'
  'geos'
  'proj'
  'libspatialite'
  'qgis'
)
sudo pacman --needed --noconfirm -S "${pkgs[@]}"

log 'Install optional dependencies'
optdeps=(
  # poppler
  'poppler-data'

  # tlp
  'x86_energy_perf_policy'

  # pinentry
  'gtk2'

  # clojure
  'rlwrap'

  # r
  'gcc-fortran'
)
sudo pacman --needed --noconfirm -S --asdeps "${optdeps[@]}"

log 'Install AUR packages'
aurpkgs=(
  'aurutils'
  'clj-kondo-bin'
  'miniconda3'
  'udunits'
)

export PACKAGER='Pengji Zhang <me@pengjiz.com>'
if do_all; then
  if [[ ! -x "$(command -v aur)" ]]; then
    log --warn 'aurutils not installed'
    log 'Install aurutils'
    pkgdir="$(mktemp -d)/aurutils"
    git clone --depth 1 'https://aur.archlinux.org/aurutils.git' "$pkgdir"
    (cd "$pkgdir" && makepkg -si --clean --noconfirm)
    unset pkgdir
  fi
  aur sync --noview "${aurpkgs[@]}"
  sudo pacman --needed --noconfirm -S "${aurpkgs[@]}"
else
  if [[ ! -x "$(command -v aur)" ]]; then
    log --error 'aurutils not installed'
    exit 1
  fi
  for pkg in "${aurpkgs[@]}"; do
    if aur repo --list | grep -q "^$pkg\>"; then
      sudo pacman --needed --noconfirm -S "$pkg"
    else
      log --warn "AUR package $pkg not in the repository"
    fi
  done
  unset pkg
fi

log 'Configure Xorg'
sudo install -m644 'etc/10-server.conf' '/etc/X11/xorg.conf.d/10-server.conf'
sudo install -m644 'etc/30-touchpad.conf' \
     '/etc/X11/xorg.conf.d/30-touchpad.conf'

log 'Configure pacman'
sudo install -m644 'etc/reflector.conf' '/etc/xdg/reflector/reflector.conf'
sudo install -d '/etc/pacman.d/hooks'
sudo install -m644 'etc/pacman-update-mirrorlist.hook' \
     '/etc/pacman.d/hooks/pacman-update-mirrorlist.hook'
sudo install -m644 'etc/systemd-update-boot.hook' \
     '/etc/pacman.d/hooks/systemd-update-boot.hook'

log 'Configure network'
sudo install -m644 'etc/20-wireless.network' \
     '/etc/systemd/network/20-wireless.network'
sudo install -d '/etc/systemd/resolved.conf.d'
sudo install -m644 'etc/20-dns.conf' '/etc/systemd/resolved.conf.d/20-dns.conf'
sudo ufw default deny
sudo ufw allow syncthing
if do_all; then
  sudo ufw enable
fi

log 'Enable system units'
system_units=(
  'systemd-timesyncd'
  'tlp'
  'ufw'
  'fstrim.timer'
  'paccache.timer'
  'reflector.timer'
  'cups.socket'
)
sudo systemctl enable "${system_units[@]}"

log 'Enable user units'
user_units=(
  'syncthing'
  'dunst'
)
systemctl --user enable "${user_units[@]}"

if do_all; then
  log 'Install dotfiles'
  (cd '..' && ./install.bash)

  log 'Setup Rust'
  rustup update
  rustup toolchain install stable
  rustup component add rust-src

  log 'Setup R'
  ./install-r.R
fi
