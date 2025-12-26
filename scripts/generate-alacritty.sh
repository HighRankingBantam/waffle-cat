#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_file="$root_dir/palette/waffle-cat.yaml"
out_file="$root_dir/exports/alacritty.toml"

SOURCE_FILE="$source_file" OUT_FILE="$out_file" python - <<'PY'
from __future__ import annotations

from pathlib import Path
import os

source_file = Path(os.environ["SOURCE_FILE"])
out_file = Path(os.environ["OUT_FILE"])

def load_base16(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip().strip("\"").strip("'")
        data[key] = value
    return data

lines = []
base = load_base16(source_file)
required = [f"base{index:02X}" for index in range(16)]
missing = [key for key in required if key not in base]
if missing:
    raise SystemExit(f"Missing Base16 keys: {', '.join(missing)}")

def hex_color(value: str) -> str:
    return value if value.startswith("#") else f"#{value}"

bg = hex_color(base["base00"])
fg = hex_color(base["base05"])
cursor = hex_color(base["base0D"])
cursor_text = hex_color(base["base01"])

ansi_keys = [f"ansi{index:02X}" for index in range(16)]
ansi_present = all(key in base for key in ansi_keys)
if ansi_present:
    ansi = [hex_color(base[key]) for key in ansi_keys]
    normal = ansi[:8]
    bright = ansi[8:]
else:
    normal = [
        hex_color(base["base00"]),
        hex_color(base["base08"]),
        hex_color(base["base0B"]),
        hex_color(base["base0A"]),
        hex_color(base["base0D"]),
        hex_color(base["base0E"]),
        hex_color(base["base0C"]),
        hex_color(base["base05"]),
    ]
    bright = [
        hex_color(base["base03"]),
        hex_color(base["base08"]),
        hex_color(base["base0B"]),
        hex_color(base["base0A"]),
        hex_color(base["base0D"]),
        hex_color(base["base0E"]),
        hex_color(base["base0C"]),
        hex_color(base["base07"]),
    ]

lines.append("# Generated from palette/waffle-cat.yaml. Do not edit by hand.")
lines.append("[colors.primary]")
lines.append(f"background = \"{bg}\"")
lines.append(f"foreground = \"{fg}\"")
lines.append("")
lines.append("[colors.normal]")
for key, value in zip(
    ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"),
    normal,
):
    lines.append(f"{key} = \"{value}\"")
lines.append("")
lines.append("[colors.bright]")
for key, value in zip(
    ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"),
    bright,
):
    lines.append(f"{key} = \"{value}\"")
lines.append("")
lines.append("[colors.cursor]")
lines.append(f"text = \"{cursor_text}\"")
lines.append(f"cursor = \"{cursor}\"")

out_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Wrote $out_file"
