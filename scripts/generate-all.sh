#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$root_dir/scripts/generate-alacritty.sh"
"$root_dir/scripts/generate-kitty.sh"
"$root_dir/scripts/generate-ghostty.sh"
