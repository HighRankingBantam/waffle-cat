#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
terminal="${1:-}"
opacity="${2:-1.0}"

if [[ -z "$terminal" ]]; then
  echo "usage: $0 {alacritty|foot|ghostty|kitty|wezterm} [opacity]" >&2
  exit 2
fi
if [[ ! "$opacity" =~ ^(0(\.[0-9]+)?|1(\.0+)?)$ ]]; then
  echo "opacity must be between 0 and 1" >&2
  exit 2
fi

fixture="$root_dir/scripts/terminal-qa.sh"
title="Waffle Cat QA — ${terminal^} — ${opacity}"
app_id="waffle-cat-qa-$terminal"
qa_shell=(bash --noprofile --norc -c '"$1"; sleep 300' bash "$fixture")

case "$terminal" in
  alacritty)
    exec alacritty \
      --config-file "$root_dir/configs/alacritty.toml" \
      --class "$app_id" \
      --title "$title" \
      --option "window.opacity=$opacity" \
      --option 'cursor.style.blinking="Never"' \
      --command "${qa_shell[@]}"
    ;;
  foot)
    exec foot \
      --config="$root_dir/configs/foot.ini" \
      --app-id="$app_id" \
      --title="$title" \
      --override="colors-dark.alpha=$opacity" \
      --override=colors-dark.alpha-mode=matching \
      --override=cursor.blink=no \
      "${qa_shell[@]}"
    ;;
  ghostty)
    # Ghostty's GTK application ID must use reverse-domain notation.
    app_id="com.oldjobobo.WaffleCatQA.Capture"
    exec ghostty \
      --config-file="$root_dir/configs/ghostty.conf" \
      --class="$app_id" \
      --title="$title" \
      --background-opacity="$opacity" \
      --cursor-style-blink=false \
      -e "${qa_shell[@]}"
    ;;
  kitty)
    exec kitty \
      --config="$root_dir/configs/kitty.conf" \
      --class="$app_id" \
      --title="$title" \
      --override="background_opacity=$opacity" \
      --override=cursor_blink_interval=0 \
      "${qa_shell[@]}"
    ;;
  wezterm)
    exec wezterm \
      --config-file "$root_dir/configs/wezterm.lua" \
      --config "window_background_opacity=$opacity" \
      --config cursor_blink_rate=0 \
      start \
      --always-new-process \
      --class "$app_id" \
      "${qa_shell[@]}"
    ;;
  *)
    echo "unsupported terminal: $terminal" >&2
    exit 2
    ;;
esac
