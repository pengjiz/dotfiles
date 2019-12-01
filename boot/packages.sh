#!/bin/bash

# Exit when error occurs
set -e

# Preparation

aur_url='https://aur.archlinux.org'
aur_dir="$HOME/.local/aurpkg"

if [[ ! -d "$aur_dir" ]]; then
  mkdir -p "$aur_dir"
fi

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
  'accountsservice'

  # Terminal
  'rxvt-unicode'
  'rxvt-unicode-terminfo'

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

  # Network
  'networkmanager'
  'nm-connection-editor'

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

  # Utility
  'ansible'
  'atool'
  'docker'
  'fd'
  'jq'
  'ledger'
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

  # C & C++
  'gdb'
  'cmake'
  'ctags'
  'gsl'
  'eigen'

  # Clojure
  'clojure'
  'rlwrap'

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
  'texlive-pictures'
  'texlive-fontsextra'
  'biber'
  'ghostscript'

  # R
  'gdal'
  'geos'
  'proj'
  'gcc-fortran'
  'r'

  # Python
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
  'aspell-en'
  'aspell-de'
  'hunspell'
  'hunspell-en_US'
  'hunspell-de'
  'languagetool'
  'proselint'
  'pandoc'
  'pandoc-citeproc'
  'pandoc-crossref'
  'pygmentize'
  'hugo'

  # GIS
  'qgis'
  'python-gdal'
  'python-numpy'
  'python-psycopg2'
  'python-owslib'
)

aur_pkgs=(
  'cask'
  'joker-bin'
  'miniconda3'
  'udunits'
)

# Install normal packages
sudo pacman --needed --noconfirm -S "${pkgs[@]}"

# Install AUR packages
for pkg in "${aur_pkgs[@]}"; do
  pkg_dir="$aur_dir/$pkg"
  if [[ ! -d "$pkg_dir" ]]; then
    git clone "$aur_url/$pkg.git" "$pkg_dir"
    (cd "$pkg_dir" && makepkg -si --noconfirm)
    git -C "$pkg_dir" clean -fdx
  fi
done
