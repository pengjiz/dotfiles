#!/bin/bash

set -e

function log {
  local color
  local prefix
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

setup_all='false'
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      setup_all='true'
      shift 1 ;;
    *)
      log --error "Unknown argument $1"
      exit 1 ;;
  esac
done

function do_all {
  [[ "$setup_all" == 'false' ]] && return 1 || return 0
}

cd "$(dirname "${BASH_SOURCE[0]}")"

log 'Prepare local AUR repository'
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

# NOTE: Here we need to create a pkgr group and add the user to the group
# beforehand. Otherwise the group membership is not effective unless we login
# again, so we cannot manipulate the AUR repository immediately.
if ! groups "$USER" | grep -q '\bpkgr\b'; then
  log --error "User $USER not in pkgr group"
  exit 1
fi

log 'Prepare pacman'
sudo install -m644 'etc/pacman.conf' '/etc/pacman.conf'
sudo pacman -Syu --noconfirm

log 'Install packages'
pkgs=(
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

  # Terminal
  'rxvt-unicode'

  # Shell
  'zsh'
  'z'
  'zsh-autosuggestions'
  'openssh'
  'shellcheck'
  'shfmt'

  # Desktop
  'i3-wm'
  'i3blocks'
  'i3lock'
  'xss-lock'
  'rofi'
  'dunst'
  'feh'
  'libnotify'
  'redshift'
  'python-psutil'

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
  'kvantum-qt5'

  # Font
  'adobe-source-code-pro-fonts'
  'noto-fonts'
  'noto-fonts-cjk'
  'noto-fonts-emoji'
  'ttf-dejavu'
  'otf-font-awesome'

  # Editor
  'editorconfig-core-c'
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

  # Input method
  'fcitx-configtool'
  'fcitx-im'
  'fcitx-mozc'
  'fcitx-rime'

  # Image
  'graphviz'
  'gnuplot'
  'imagemagick'
  'scrot'

  # File transfer
  'ntfs-3g'
  'exfat-utils'
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
  'bc'
  'ledger'
  'xclip'
  'trash-cli'
  'youtube-dl'
  'words'

  # Debugging
  'gdb'
  'ltrace'
  'valgrind'

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

  # Idris
  'idris'

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
  'hunspell-en_US'
  'proselint'
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

if do_all; then
  config="$(cd '../pacman' && pwd)/makepkg.conf"
  if [[ ! -x "$(command -v aur)" ]]; then
    log --warn 'aurutils not installed'
    log 'Install aurutils'
    pkgdir='/tmp/aurutils'
    git clone 'https://aur.archlinux.org/aurutils.git' "$pkgdir"
    (cd "$pkgdir" && makepkg -si --clean --config "$config" --noconfirm)
    unset pkgdir
  fi
  aur sync --noview --makepkg-conf "$config" "${aurpkgs[@]}"
  unset config
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
sudo install -m644 'etc/19-wireless-cmu.network' \
     '/etc/systemd/network/19-wireless-cmu.network'
sudo install -m644 'etc/20-wireless.network' \
     '/etc/systemd/network/20-wireless.network'
sudo install -m644 'etc/resolved.conf' '/etc/systemd/resolved.conf'
sudo ufw default deny
sudo ufw allow syncthing
if do_all; then
  sudo ufw enable
fi

log 'Enable system services'
system_services=(
  'systemd-timesyncd'
  'tlp'
  'ufw'
  'fstrim.timer'
  'man-db.timer'
  'paccache.timer'
  'reflector.timer'
  'cups.socket'
)
sudo systemctl enable "${system_services[@]}"

log 'Enable user services'
user_services=(
  'syncthing'
  'dunst'
)
systemctl --user enable "${user_services[@]}"

if do_all; then
  log 'Install user configurations'
  (cd '..' && ./install.bash)

  log 'Setup Rust'
  rustup update
  rustup toolchain install stable
  rustup component add rust-src

  log 'Setup R'
  ./install-r.R
fi
