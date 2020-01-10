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
  echo -e "\033[${color}m$prefix:\033[0m $@" >&2
}

setup_all='false'
setup_printer='false'
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      setup_all='true'
      shift 1 ;;
    --printer)
      setup_printer='true'
      shift 1 ;;
    *)
      log --error "Unknown argument $1"
      exit 1 ;;
  esac
done

function do_all {
  [[ "$setup_all" == 'false' ]] && return 1 || return 0
}

function do_printer {
  [[ "$setup_printer" == 'false' ]] && return 1 || return 0
}

cd "$(dirname "${BASH_SOURCE[0]}")"

log 'Prepare local AUR repository'
repodir='/srv/pkgrepo'
aurdir="$repodir/aur"
aurdb="$aurdir/aur.db.tar.xz"
sudo install -d "$repodir"
# NOTE: Here we need to create a pkgr group and add the user to the group
# beforehand. Otherwise the group membership is not effective unless we login
# again.
if ! groups "$USER" | grep -q '\bpkgr\b'; then
  log --error "User $USER not in pkgr group"
  exit 1
fi
sudo install -m2775 -g pkgr -d "$aurdir"
sudo setfacl -d -m g:pkgr:rwx "$aurdir"
sudo setfacl -m g:pkgr:rwx "$aurdir"
if [[ ! -f "$aurdb" ]]; then
  log 'Initialize empty AUR package database'
  sudo repo-add "$aurdb"
fi

log 'Configure pacman'
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
  'xf86-video-fbdev'
  'xf86-video-vesa'
  'arandr'

  # Display manager
  'lightdm'
  'lightdm-gtk-greeter'

  # Terminal
  'rxvt-unicode'

  # Shell
  'zsh'
  'z'
  'zsh-autosuggestions'
  'openssh'

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
  'pavucontrol'

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
  'firefox-extension-https-everywhere'

  # Viewer
  'evince'
  'libreoffice-still'
  'mpv'
  'mupdf-tools'

  # Fcitx
  'fcitx-configtool'
  'fcitx-im'
  'fcitx-mozc'
  'fcitx-rime'

  # Image
  'graphviz'
  'gnuplot'
  'imagemagick'
  'scrot'

  # Filesystem
  'ntfs-3g'
  'exfat-utils'

  # Utility
  'ansible'
  'atool'
  'docker'
  'fd'
  'jq'
  'ledger'
  'man-db'
  'man-pages'
  'pacman-contrib'
  'pass'
  'protobuf'
  'reflector'
  'ripgrep'
  'rsync'
  'syncthing'
  'tldr'
  'tlp'
  'trash-cli'
  'udisks2'
  'unzip'
  'words'
  'x86_energy_perf_policy'
  'xclip'
  'youtube-dl'

  # Debugging
  'gdb'
  'ltrace'
  'valgrind'

  # C & C++
  'cmake'
  'ctags'
  'gsl'
  'eigen'

  # Clojure
  'clojure'

  # Haskell
  'ghc'
  'stack'
  'hindent'
  'hlint'

  # Idris
  'idris'

  # JavaScript
  'nodejs'
  'npm'

  # TypeScript
  'ts-node'

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
  'pygmentize'

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
  # lightdm
  'accountsservice'

  # clojure
  'rlwrap'

  # r
  'gcc-fortran'

  # pandoc
  'pandoc-citeproc'
  'pandoc-crossref'

  # qgis
  'python-gdal'
  'python-numpy'
  'python-psycopg2'
  'python-owslib'
)
sudo pacman --needed --noconfirm -S --asdeps "${optdeps[@]}"

log 'Install AUR packages'
aurpkgs=(
  'aurutils'
  'cask'
  'joker-bin'
  'miniconda3'
  'udunits'
)

if do_all; then
  config="$(cd '../pacman' && pwd)/makepkg.conf"
  if [[ ! -x "$(command -v aur)" ]]; then
    log --warn 'aurutils not installed'
    log 'Install aurutils'
    log 'Import PGP key for aurutils'
    gpg --recv-keys 'DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A'
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
fi

log 'Configure touchpad'
sudo install -m644 'etc/30-touchpad.conf' \
     '/etc/X11/xorg.conf.d/30-touchpad.conf'

log 'Configure LightDM'
sudo install -m644 'etc/lightdm-gtk-greeter.conf' \
     '/etc/lightdm/lightdm-gtk-greeter.conf'

log 'Install pacman hooks'
sudo install -d '/etc/pacman.d/hooks'
sudo install -m644 'etc/pacman-update-mirrorlist.hook' \
     '/etc/pacman.d/hooks/pacman-update-mirrorlist.hook'
sudo install -m644 'etc/systemd-update-boot.hook' \
     '/etc/pacman.d/hooks/systemd-update-boot.hook'

log 'Configure network'
sudo install -m644 'etc/20-wireless.network' \
     '/etc/systemd/network/20-wireless.network'

log 'Enable system services'
system_services=(
  'docker'
  'lightdm'
  'systemd-timesyncd'
  'tlp'
  'tlp-sleep'
  'fstrim.timer'
  'man-db.timer'
  'paccache.timer'
)
sudo systemctl enable "${system_services[@]}"
sudo gpasswd -a "$USER" docker

log 'Enable user services'
user_services=(
  'syncthing'
)
systemctl --user enable "${user_services[@]}"

if do_printer; then
  log 'Setup printer'
  sudo pacman -S --needed --noconfirm cups hplip
  sudo systemctl enable org.cups.cupsd.socket
fi

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
