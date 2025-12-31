#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f "${BASH_SOURCE[0]}")"
root_dir="$(cd "$(dirname "$script_path")/.." && pwd)"
base16_file="$root_dir/palette/waffle-cat.yaml"
base24_file="$root_dir/palette/waffle-cat-base24.yaml"

BASE16_FILE="$base16_file" BASE24_FILE="$base24_file" python - <<'PY'
from __future__ import annotations

from pathlib import Path
import os
import shutil

base16_file = Path(os.environ["BASE16_FILE"])
base24_file = Path(os.environ["BASE24_FILE"])

if not base16_file.exists():
    raise SystemExit(f"Palette not found: {base16_file}")

def load_palette(path: Path) -> dict[str, str]:
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

def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    if len(value) != 6:
        raise ValueError(f"Invalid hex color: {value}")
    return int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16)

def fg_for_bg(r: int, g: int, b: int) -> str:
    # Relative luminance check for readable text.
    luminance = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
    return "0;0;0" if luminance > 0.6 else "255;255;255"

def color_cell(text: str, hex_value: str, width: int = 10) -> str:
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
        columns = max_columns(10)
    print(title)
    row_labels: list[str] = []
    row_values: list[str] = []
    for index, key in enumerate(keys, start=1):
        value = palette[key]
        row_labels.append(color_cell(key, value))
        row_values.append(color_cell(value, value))
        if index % columns == 0:
            print(" ".join(row_labels))
            print(" ".join(row_values))
            print("")
            row_labels = []
            row_values = []
    if row_labels:
        print(" ".join(row_labels))
        print(" ".join(row_values))
        print("")

base16 = load_palette(base16_file)
base16_keys = [f"base{index:02X}" for index in range(16)]
missing = [key for key in base16_keys if key not in base16]
if missing:
    raise SystemExit(f"Missing Base16 keys in {base16_file}: {', '.join(missing)}")

print(f"palette: {base16_file}")
print("")
render_grid(base16_keys, base16, "base16:")

if base24_file.exists():
    base24 = load_palette(base24_file)
    base24_keys = [f"base{index:02X}" for index in range(16, 24)]
    if all(key in base24 for key in base24_keys):
        render_grid(base24_keys, base24, "base24 (extras):")
    else:
        print(f"base24 extras: (missing in {base24_file})")
        print("")
else:
    print("base24 extras: (not present)")
    print("")

PY
