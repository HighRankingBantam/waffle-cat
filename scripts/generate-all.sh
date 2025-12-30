#!/usr/bin/env bash
set -euo pipefail

source_path="${BASH_SOURCE[0]}"
while [ -L "$source_path" ]; do
  source_dir="$(cd "$(dirname "$source_path")" && pwd -P)"
  source_path="$(readlink "$source_path")"
  if [[ "$source_path" != /* ]]; then
    source_path="$source_dir/$source_path"
  fi
done
script_dir="$(cd "$(dirname "$source_path")" && pwd -P)"
root_dir="$(cd "$script_dir/.." && pwd -P)"

"$root_dir/scripts/generate-alacritty.sh"
"$root_dir/scripts/generate-kitty.sh"
"$root_dir/scripts/generate-ghostty.sh"
