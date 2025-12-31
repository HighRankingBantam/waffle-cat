#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f "${BASH_SOURCE[0]}")"
root_dir="$(cd "$(dirname "$script_path")/.." && pwd)"
palette_dir="$root_dir/palette"

PALETTE_DIR="$palette_dir" python - <<'PY'
from __future__ import annotations

from pathlib import Path
import os
import shutil

palette_dir = Path(os.environ["PALETTE_DIR"])
if not palette_dir.exists():
    raise SystemExit(f"Palette directory not found: {palette_dir}")

def load_palette(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        raw_value = value.strip()
        if raw_value.startswith(("\"", "'")):
            quote = raw_value[0]
            end_index = raw_value.find(quote, 1)
            if end_index != -1:
                cleaned = raw_value[1:end_index]
            else:
                cleaned = raw_value.strip(quote)
        else:
            cleaned = raw_value.split("#", 1)[0].strip()
        data[key] = cleaned
    return data

def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    if len(value) != 6:
        raise ValueError(f"Invalid hex color: {value}")
    return int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16)

def fg_for_bg(r: int, g: int, b: int) -> str:
    # Relative luminance check for readable text.
    luminance = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
    return "0;0;0" if luminance > 0.6 else "255;255;255"

def color_cell(text: str, hex_value: str, width: int = 12) -> str:
    r, g, b = hex_to_rgb(hex_value)
    fg = fg_for_bg(r, g, b)
    bg = f"\x1b[48;2;{r};{g};{b}m"
    fg_code = f"\x1b[38;2;{fg}m"
    reset = "\x1b[0m"
    padded = text.ljust(width)
    return f"{bg}{fg_code}{padded}{reset}"

def max_columns(cell_width: int, max_cols: int = 8, min_cols: int = 4) -> int:
    term_width = shutil.get_terminal_size((96, 20)).columns
    cols = max(1, (term_width + 1) // (cell_width + 1))
    return max(min_cols, min(max_cols, cols))

def render_grid(keys: list[str], palette: dict[str, str], title: str, columns: int | None = None) -> None:
    if columns is None:
        columns = max_columns(12)
    print(title)
    row_labels: list[str] = []
    row_values: list[str] = []
    row_names: list[str] = []
    for index, key in enumerate(keys, start=1):
        value = palette[key]
        row_labels.append(color_cell(key, value))
        row_values.append(color_cell(value, value))
        if key in BASE16_ROLE_NAMES:
            row_names.append(color_cell(BASE16_ROLE_NAMES[key], value))
        if index % columns == 0:
            print(" ".join(row_labels))
            print(" ".join(row_values))
            if row_names:
                print(" ".join(row_names))
            print("")
            row_labels = []
            row_values = []
            row_names = []
    if row_labels:
        print(" ".join(row_labels))
        print(" ".join(row_values))
        if row_names:
            print(" ".join(row_names))
        print("")

palette_files = sorted(palette_dir.glob("*.yaml"))
if not palette_files:
    raise SystemExit(f"No palette YAML files found in {palette_dir}")

BASE16_ROLE_NAMES = {
    "base00": "background",
    "base01": "bg-alt",
    "base02": "selection",
    "base03": "comments",
    "base04": "fg-alt",
    "base05": "foreground",
    "base06": "fg-light",
    "base07": "bg-light",
    "base08": "red",
    "base09": "orange",
    "base0A": "yellow",
    "base0B": "green",
    "base0C": "cyan",
    "base0D": "blue",
    "base0E": "magenta",
    "base0F": "brown",
}

base16_keys = [f"base{index:02X}" for index in range(16)]
base24_keys = [f"base{index:02X}" for index in range(16, 24)]

for palette_file in palette_files:
    palette = load_palette(palette_file)
    print(f"palette: {palette_file}")
    print("")
    missing = [key for key in base16_keys if key not in palette]
    if missing:
        print(f"base16: (missing keys: {', '.join(missing)})")
        print("")
        continue

    render_grid(base16_keys, palette, "base16:")

    if all(key in palette for key in base24_keys):
        render_grid(base24_keys, palette, "base24 (extras):")
    else:
        print("base24 (extras): (not present)")
        print("")

PY
