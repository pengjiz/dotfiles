#!/bin/bash

set -euo pipefail

config='install.conf.yaml'
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotbot_dir='dotbot'
dotbot_bin="$base_dir/$dotbot_dir/bin/dotbot"

cd "$base_dir"
git submodule sync --quiet --recursive
git submodule update --init --recursive

"$dotbot_bin" -d "$base_dir" -c "$config" "$@"
