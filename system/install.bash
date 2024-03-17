#!/bin/bash

set -euo pipefail

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
  # System
  'pacman-contrib'
  'reflector'
  'rebuild-detector'
  'devtools'
  'lsb-release'
  'tlp'
  'ufw'
  'pulseaudio'
  'pulseaudio-alsa'
  'cups'
  'cups-pdf'

  # Shell
  'zsh'
  'z'
  'zsh-autosuggestions'
  'openssh'
  'shellcheck'
  'shfmt'

  # Display
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
  'scrot'
  'redshift'
  'xclip'

  # Theme
  'feh'
  'archlinux-wallpaper'
  'qt5ct'
  'kvantum'
  'arc-gtk-theme'
  'papirus-icon-theme'

  # Font
  'adobe-source-code-pro-fonts'
  'noto-fonts'
  'noto-fonts-cjk'
  'noto-fonts-emoji'
  'ttf-dejavu'
  'otf-font-awesome'

  # Basic
  'xterm'
  'emacs'
  'neovim'
  'firefox'
  'firefox-i18n-en-us'
  'firefox-ublock-origin'

  # Media
  'mpv'
  'evince'
  'libreoffice-still'
  'mupdf-tools'
  'imagemagick'

  # Utility
  'pass'
  'pwgen'
  'ledger'
  'bc'
  'ripgrep'
  'ripgrep-all'
  'fd'
  'atool'
  'unzip'
  'udisks2'
  'rsync'
  'syncthing'
  'trash-cli'

  # Development
  'gdb'
  'ltrace'
  'strace'
  'valgrind'
  'lsof'
  'bind'
  'openbsd-netcat'
  'libfaketime'
  'qemu-desktop'
  'ansible'
  'ansible-lint'
  'ctags'
  'man-db'
  'man-pages'
  'tldr'

  # Programming
  'nasm'
  'rustup'
  'gcc-fortran'
  'clojure'
  'racket'
  'r'
  'lua'
  'graphviz'
  'gnuplot'

  # C & C++
  'cmake'
  'doxygen'
  'gsl'
  'eigen'

  # Haskell
  'ghc'
  'ghc-static'
  'stack'
  'hlint'
  'stylish-haskell'

  # Python
  'python-pip'
  'flake8'
  'python-black'

  # Web
  'nodejs'
  'ts-node'
  'npm'
  'prettier'

  # Writing
  'aspell'
  'aspell-de'
  'aspell-en'
  'hunspell'
  'hunspell-de'
  'hunspell-en_us'
  'languagetool'
  'words'
  'hugo'
  'pandoc-cli'
  'pandoc-crossref'
  'python-pygments'

  # LaTeX
  'texlive-meta'
  'texlive-langenglish'
  'texlive-langgerman'
  'texlive-doc'
  'biber'
  'minted'
  'ghostscript'

  # Data
  'jq'
  'fq'
  'htmlq'
  'protobuf'
  'yamllint'
)
sudo pacman --needed --noconfirm -S "${pkgs[@]}"

log 'Install optional dependencies'
optdeps=(
  # poppler
  'poppler-data'
  # pinentry
  'gtk2'
  # clojure
  'rlwrap'
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
