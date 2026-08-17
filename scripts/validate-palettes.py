#!/usr/bin/env python3
"""Validate Waffle Cat Base16/Base24 palette structure and source sync."""

from __future__ import annotations

import argparse
import re
import sys
import tomllib
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parent.parent
PALETTE_DIR = ROOT / "palette"
BASE16_PATH = PALETTE_DIR / "waffle-cat-base16.yaml"
BASE24_PATH = PALETTE_DIR / "waffle-cat-base24.yaml"

EXPECTED_METADATA = {
    "name": "Waffle Cat",
    "slug": "waffle-cat",
    "author": "OldJobobo",
    "variant": "dark",
}
BASE24_SOURCE_ROLES = [
    "bg",
    "lighter_bg",
    "selection",
    "muted",
    "dark_fg",
    "fg",
    "light_fg",
    "bright_fg",
    "red",
    "orange",
    "yellow",
    "green",
    "cyan",
    "blue",
    "magenta",
    "brown",
    "dark_bg",
    "darker_bg",
    "bright_red",
    "bright_yellow",
    "bright_green",
    "bright_cyan",
    "bright_blue",
    "bright_magenta",
]
HEX_COLOR = re.compile(r"^#[0-9A-F]{6}$")


def load_yaml(path: Path) -> dict[str, Any]:
    try:
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
    except (OSError, yaml.YAMLError) as error:
        raise ValueError(f"{path}: cannot load YAML: {error}") from error
    if not isinstance(data, dict):
        raise ValueError(f"{path}: document root must be a mapping")
    return data


def validate_palette(path: Path, system: str, slot_count: int) -> dict[str, str]:
    data = load_yaml(path)
    expected_top_level = ["system", "name", "slug", "author", "variant", "palette"]
    if list(data) != expected_top_level:
        raise ValueError(
            f"{path}: top-level keys must be ordered as {expected_top_level}"
        )
    if data["system"] != system:
        raise ValueError(f"{path}: system must be {system!r}")
    for key, expected in EXPECTED_METADATA.items():
        if data[key] != expected:
            raise ValueError(f"{path}: {key} must be {expected!r}")

    palette = data["palette"]
    if not isinstance(palette, dict):
        raise ValueError(f"{path}: palette must be a mapping")
    expected_slots = [f"base{index:02X}" for index in range(slot_count)]
    if list(palette) != expected_slots:
        raise ValueError(f"{path}: slots must be ordered as {expected_slots}")
    for slot, color in palette.items():
        if not isinstance(color, str) or not HEX_COLOR.fullmatch(color):
            raise ValueError(
                f"{path}: {slot} must be a quoted uppercase six-digit hex color"
            )
    return palette


def validate_source(base24: dict[str, str], source_path: Path) -> None:
    try:
        source = tomllib.loads(source_path.read_text(encoding="utf-8"))
    except (OSError, tomllib.TOMLDecodeError) as error:
        raise ValueError(f"{source_path}: cannot load TOML: {error}") from error

    for index, role in enumerate(BASE24_SOURCE_ROLES):
        slot = f"base{index:02X}"
        source_color = source.get(role)
        if not isinstance(source_color, str):
            raise ValueError(f"{source_path}: missing string role {role!r}")
        if base24[slot] != source_color.upper():
            raise ValueError(
                f"{slot} differs from {role}: {base24[slot]} != {source_color.upper()}"
            )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        type=Path,
        help="optional Omarchy colors.toml to compare against the Base24 palette",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        base16 = validate_palette(BASE16_PATH, "base16", 16)
        base24 = validate_palette(BASE24_PATH, "base24", 24)
        for slot, color in base16.items():
            if base24[slot] != color:
                raise ValueError(
                    f"Base16 reduction differs from Base24 at {slot}: "
                    f"{color} != {base24[slot]}"
                )
        if args.source:
            validate_source(base24, args.source.expanduser().resolve())
    except ValueError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    source_note = f" and {args.source}" if args.source else ""
    print(f"validated {BASE16_PATH}, {BASE24_PATH}{source_note}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
