#!/usr/bin/env bash
set -euo pipefail

readonly theme_name="Waffle Cat"
readonly palette=("#292025" "#fff4d8" "#c87d2a")

print_palette() {
  local color
  printf '%s\n' "$theme_name"
  for color in "${palette[@]}"; do
    printf '  • %s\n' "$color"
  done
}

[[ ${#palette[@]} -eq 3 ]] || { echo "invalid palette" >&2; exit 1; }
print_palette
