#!/usr/bin/env python3
"""Validate generated portable CLI integrations and their palette usage."""

from __future__ import annotations

import plistlib
import re
import sys
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parent.parent
CONFIG_DIR = ROOT / "configs"
PALETTE_PATH = ROOT / "palette" / "waffle-cat-base24.yaml"
HEX_COLOR = re.compile(r"#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?")
ANSI_SLOTS = [
    "base00", "base08", "base0B", "base0A", "base0D", "base0E", "base0C", "base05",
    "base03", "base12", "base14", "base13", "base16", "base17", "base15", "base07",
]
COLOR_NAMES = ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white")


def canonical_palette() -> dict[str, str]:
    data = yaml.safe_load(PALETTE_PATH.read_text(encoding="utf-8"))
    palette = data.get("palette") if isinstance(data, dict) else None
    if not isinstance(palette, dict):
        raise ValueError(f"{PALETTE_PATH}: missing palette mapping")
    return {slot: color.lower() for slot, color in palette.items()}


def assert_color(actual: Any, expected: str, label: str) -> None:
    if not isinstance(actual, str) or actual.lower() != expected.lower():
        raise ValueError(f"{label}: expected {expected}, got {actual!r}")


def validate_known_colors(path: Path, palette: dict[str, str]) -> None:
    allowed = set(palette.values())
    colors = set(HEX_COLOR.findall(path.read_text(encoding="utf-8")))
    unknown = sorted(color for color in colors if color[:7].lower() not in allowed)
    if unknown:
        raise ValueError(f"{path}: colors outside canonical palette: {', '.join(unknown)}")


def validate_bat(path: Path, palette: dict[str, str]) -> None:
    with path.open("rb") as stream:
        data = plistlib.load(stream)
    if not isinstance(data, dict) or data.get("name") != "Waffle Cat":
        raise ValueError(f"{path}: invalid theme metadata")
    settings = data.get("settings")
    if not isinstance(settings, list) or not settings:
        raise ValueError(f"{path}: missing settings array")
    general = settings[0].get("settings")
    if not isinstance(general, dict):
        raise ValueError(f"{path}: missing general settings")
    expected = {
        "background": palette["base00"],
        "foreground": palette["base05"],
        "caret": palette["base07"],
        "selection": palette["base02"],
        "lineHighlight": palette["base01"],
        "invisibles": palette["base03"],
    }
    for key, color in expected.items():
        assert_color(general.get(key), color, f"{path}:{key}")


def validate_warp(path: Path, palette: dict[str, str], ansi: list[str]) -> None:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("name") != "Waffle Cat":
        raise ValueError(f"{path}: invalid theme metadata")
    assert_color(data.get("background"), palette["base00"], f"{path}:background")
    assert_color(data.get("foreground"), palette["base05"], f"{path}:foreground")
    terminal = data.get("terminal_colors")
    if not isinstance(terminal, dict):
        raise ValueError(f"{path}: missing terminal_colors")
    for section, expected_colors in (("normal", ansi[:8]), ("bright", ansi[8:])):
        values = terminal.get(section)
        if not isinstance(values, dict):
            raise ValueError(f"{path}: missing {section} colors")
        for name, expected in zip(COLOR_NAMES, expected_colors):
            assert_color(values.get(name), expected, f"{path}:{section}.{name}")


def validate_fragments(paths: dict[str, Path]) -> None:
    tmux = paths["tmux"].read_text(encoding="utf-8")
    for option in ("status-style", "window-status-current-style", "pane-active-border-style", "mode-style"):
        if f"set -g {option}" not in tmux:
            raise ValueError(f"{paths['tmux']}: missing {option}")

    fzf = paths["fzf"].read_text(encoding="utf-8")
    for role in ("fg:", "bg:", "hl:", "fg+:", "bg+:", "pointer:", "marker:", "border:"):
        if role not in fzf:
            raise ValueError(f"{paths['fzf']}: missing color role {role}")

    delta = paths["delta"].read_text(encoding="utf-8")
    for option in ("[delta \"waffle-cat\"]", "syntax-theme", "minus-style", "plus-style"):
        if option not in delta:
            raise ValueError(f"{paths['delta']}: missing {option}")


def main() -> int:
    try:
        palette = canonical_palette()
        ansi = [palette[slot] for slot in ANSI_SLOTS]
        paths = {
            "tmux": CONFIG_DIR / "tmux.conf",
            "bat": CONFIG_DIR / "waffle-cat.tmTheme",
            "delta": CONFIG_DIR / "delta.gitconfig",
            "fzf": CONFIG_DIR / "fzf.sh",
            "warp": CONFIG_DIR / "warp.yaml",
        }
        for path in paths.values():
            validate_known_colors(path, palette)
        validate_bat(paths["bat"], palette)
        validate_warp(paths["warp"], palette, ansi)
        validate_fragments(paths)
    except (OSError, ValueError, plistlib.InvalidFileException, yaml.YAMLError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print("validated tmux, bat, delta, fzf, and Warp integrations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
