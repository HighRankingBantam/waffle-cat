#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_file="$root_dir/colors.toml"
out_file="$root_dir/exports/alacritty.toml"

SOURCE_FILE="$source_file" OUT_FILE="$out_file" python - <<'PY'
from __future__ import annotations

from pathlib import Path
import os
import tomllib

source_file = Path(os.environ["SOURCE_FILE"])
out_file = Path(os.environ["OUT_FILE"])

data = tomllib.loads(source_file.read_text(encoding="utf-8"))
colors = data.get("colors", {})
primary = colors.get("primary", {})
normal = colors.get("normal", {})
bright = colors.get("bright", {})
cursor = colors.get("cursor", {})

lines = []
lines.append("# Generated from colors.toml. Do not edit by hand.")
lines.append("[colors.primary]")
lines.append(f"background = \"{primary.get('background')}\"")
lines.append(f"foreground = \"{primary.get('foreground')}\"")
lines.append("")
lines.append("[colors.normal]")
for key in ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"):
    lines.append(f"{key} = \"{normal.get(key)}\"")
lines.append("")
lines.append("[colors.bright]")
for key in ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"):
    lines.append(f"{key} = \"{bright.get(key)}\"")
if cursor:
    lines.append("")
    lines.append("[colors.cursor]")
    if cursor.get("text"):
        lines.append(f"text = \"{cursor.get('text')}\"")
    if cursor.get("cursor"):
        lines.append(f"cursor = \"{cursor.get('cursor')}\"")

out_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Wrote $out_file"
