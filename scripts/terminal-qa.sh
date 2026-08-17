#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
palette="$root_dir/palette/waffle-cat-base24.yaml"

PALETTE_PATH="$palette" python - <<'PY'
from __future__ import annotations

import os
import shutil
from pathlib import Path

import yaml

palette = yaml.safe_load(Path(os.environ["PALETTE_PATH"]).read_text(encoding="utf-8"))["palette"]
ansi_slots = [
    "base00", "base08", "base0B", "base0A", "base0D", "base0E", "base0C", "base05",
    "base03", "base12", "base14", "base13", "base16", "base17", "base15", "base07",
]
ansi_names = [
    "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
    "bright black", "bright red", "bright green", "bright yellow", "bright blue",
    "bright magenta", "bright cyan", "bright white",
]
roles = [
    ("base00", "background"), ("base01", "lighter bg"), ("base02", "selection"),
    ("base03", "muted"), ("base04", "dark fg"), ("base05", "foreground"),
    ("base06", "light fg"), ("base07", "bright fg"), ("base08", "error red"),
    ("base09", "orange"), ("base0A", "yellow"), ("base0B", "green"),
    ("base0C", "cyan"), ("base0D", "honey amber"), ("base0E", "magenta"),
    ("base0F", "brown"), ("base10", "dark bg"), ("base11", "darker bg"),
    ("base12", "bright red"), ("base13", "bright yellow"),
    ("base14", "bright green"), ("base15", "bright cyan"),
    ("base16", "bright blue"), ("base17", "bright magenta"),
]
reset = "\033[0m"


def rgb(value: str) -> tuple[int, int, int]:
    value = value.removeprefix("#")
    return tuple(int(value[index:index + 2], 16) for index in (0, 2, 4))


def contrast_index(value: str) -> int:
    red, green, blue = rgb(value)
    luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
    return 0 if luminance > 0.58 else 15


def indexed_cell(index: int, label: str, value: str) -> str:
    foreground = contrast_index(value)
    return f"\033[48;5;{index}m\033[38;5;{foreground}m {label:^15} {reset}"


def truecolor_cell(slot: str, label: str) -> str:
    value = palette[slot]
    red, green, blue = rgb(value)
    foreground = "0;0;0" if contrast_index(value) == 0 else "255;255;255"
    text = f"{slot} {label}"[:19]
    return f"\033[48;2;{red};{green};{blue}m\033[38;2;{foreground}m {text:<19} {reset}"


columns, rows = shutil.get_terminal_size((120, 40))
print("\033[2J\033[H", end="")
print("WAFFLE CAT 2.0 — TERMINAL VISUAL QA")
print(f"Viewport: {columns}×{rows}  |  canonical source: palette/waffle-cat-base24.yaml")
print("=" * min(columns, 110))
print("\nANSI BACKGROUNDS — normal")
print(" ".join(indexed_cell(i, ansi_names[i], palette[ansi_slots[i]]) for i in range(8)))
print("ANSI BACKGROUNDS — bright")
print(" ".join(indexed_cell(i, ansi_names[i], palette[ansi_slots[i]]) for i in range(8, 16)))

print("\nANSI FOREGROUNDS — normal")
print("  ".join(f"\033[38;5;{i}m{i}:{ansi_names[i]}{reset}" for i in range(8)))
print("ANSI FOREGROUNDS — bright")
print("  ".join(f"\033[38;5;{i}m{i}:{ansi_names[i]}{reset}" for i in range(8, 16)))

print("\nBASE24 SEMANTIC SURFACES")
for start in range(0, len(roles), 6):
    print(" ".join(truecolor_cell(slot, label) for slot, label in roles[start:start + 6]))

print("\nTEXT AND INTERFACE STATES")
print(f"{reset}Default body text — cream foreground on cocoa background.")
print(f"\033[2mMuted / inactive text — readable without competing for attention.{reset}")
print(f"\033[1mBold emphasis{reset}  \033[3mItalic emphasis{reset}  \033[4mUnderlined link text{reset}  normal text")
print(f"\033[38;5;1mERROR   Failed to parse configuration at line 42.{reset}")
print(f"\033[38;5;3mWARNING Selection contrast should remain obvious at 85% opacity.{reset}")
print(f"\033[38;5;2mSUCCESS Palette and generated output are synchronized.{reset}")
print(f"\033[38;5;6mINFO    Cyan remains supportive rather than dominant.{reset}")
print(f"\033[38;5;4mLINK    https://github.com/OldJobobo/waffle-cat{reset}")
print(f"\033[48;5;2m\033[38;5;0m+ added: explicit semantic ANSI mapping{reset}")
print(f"\033[48;5;1m\033[38;5;15m- removed: duplicated alpha-era assignments{reset}")
print(f"\033[48;5;3m\033[38;5;0m~ changed: honey amber is the dominant accent{reset}")

print("\nSELECTION TARGET — drag across this sentence to inspect selected foreground and background.")
print("SEARCH TARGET — honey amber / syrup brown / toasted waffle / vanilla cream")
print("\nCursor visibility target: ", end="", flush=True)
PY
