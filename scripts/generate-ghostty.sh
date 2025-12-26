#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_file="$root_dir/colors.toml"
out_file="$root_dir/exports/ghostty.conf"

SOURCE_FILE="$source_file" OUT_FILE="$out_file" python - <<'PY'
from __future__ import annotations

from pathlib import Path
import tomllib
import os

source_file = Path(os.environ["SOURCE_FILE"])
out_file = Path(os.environ["OUT_FILE"])

data = tomllib.loads(source_file.read_text(encoding="utf-8"))
colors = data.get("colors", {})
primary = colors.get("primary", {})
normal = colors.get("normal", {})
bright = colors.get("bright", {})
cursor = colors.get("cursor", {})

palette_order = [
    normal.get("black"),
    normal.get("red"),
    normal.get("green"),
    normal.get("yellow"),
    normal.get("blue"),
    normal.get("magenta"),
    normal.get("cyan"),
    normal.get("white"),
    bright.get("black"),
    bright.get("red"),
    bright.get("green"),
    bright.get("yellow"),
    bright.get("blue"),
    bright.get("magenta"),
    bright.get("cyan"),
    bright.get("white"),
]

missing = [i for i, value in enumerate(palette_order) if not value]
if missing:
    raise SystemExit(f"Missing palette entries at indexes: {missing}")

lines = []
lines.append("# Generated from colors.toml. Do not edit by hand.")
lines.append(f"background = {primary.get('background')}")
lines.append(f"foreground = {primary.get('foreground')}")
if cursor.get("cursor"):
    lines.append(f"cursor-color = {cursor.get('cursor')}")
if cursor.get("text"):
    lines.append(f"cursor-text = {cursor.get('text')}")
for index, value in enumerate(palette_order):
    lines.append(f"palette = {index}={value}")

out_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "Wrote $out_file"
