#!/usr/bin/env python3
"""Validate portable editor themes against the canonical Base24 palette."""

from __future__ import annotations

import json
import re
import sys
import tomllib
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parent.parent
PALETTE_PATH = ROOT / "palette" / "waffle-cat-base24.yaml"
HEX_COLOR = re.compile(r"#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?")
ANSI_SLOTS = [
    "base00", "base08", "base0B", "base0A", "base0D", "base0E", "base0C", "base05",
    "base03", "base12", "base14", "base13", "base16", "base17", "base15", "base07",
]


def load_json(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{path}: document root must be an object")
    return data


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
    allowed = set(palette.values()) | {"#000000"}
    colors = set(HEX_COLOR.findall(path.read_text(encoding="utf-8")))
    unknown = sorted(color for color in colors if color[:7].lower() not in allowed)
    if unknown:
        raise ValueError(f"{path}: colors outside canonical palette: {', '.join(unknown)}")


def validate_neovim(path: Path, palette: dict[str, str]) -> None:
    text = path.read_text(encoding="utf-8")
    assignments = dict(re.findall(r'^\s*(base[0-9a-f]{2}) = "(#[0-9a-fA-F]{6})"', text, re.MULTILINE))
    expected = {f"base{index:02x}": palette[f"base{index:02X}"] for index in range(16)}
    if {key: value.lower() for key, value in assignments.items()} != expected:
        raise ValueError(f"{path}: Base16 assignments differ from canonical palette")
    if 'vim.g.colors_name = "waffle-cat"' not in text:
        raise ValueError(f"{path}: missing colors_name declaration")


def validate_helix(path: Path, palette: dict[str, str], ansi: list[str]) -> None:
    with path.open("rb") as stream:
        data = tomllib.load(stream)
    colors = data.get("palette")
    if not isinstance(colors, dict):
        raise ValueError(f"{path}: missing palette table")
    semantic = {
        "background": palette["base00"],
        "foreground": palette["base05"],
        "cursor": palette["base07"],
        "selection_background": palette["base02"],
        "selection_foreground": palette["base05"],
    }
    for key, expected in semantic.items():
        assert_color(colors.get(key), expected, f"{path}:{key}")
    for index, expected in enumerate(ansi[:9]):
        assert_color(colors.get(f"color{index}"), expected, f"{path}:color{index}")


def validate_vscode(path: Path, palette: dict[str, str], ansi: list[str]) -> None:
    data = load_json(path)
    if data.get("name") != "Waffle Cat" or data.get("type") != "dark":
        raise ValueError(f"{path}: invalid Waffle Cat theme metadata")
    if data.get("semanticHighlighting") is not True:
        raise ValueError(f"{path}: semanticHighlighting must be true")
    colors = data.get("colors")
    if not isinstance(colors, dict):
        raise ValueError(f"{path}: missing workbench colors")
    names = [
        "Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White",
        "BrightBlack", "BrightRed", "BrightGreen", "BrightYellow", "BrightBlue",
        "BrightMagenta", "BrightCyan", "BrightWhite",
    ]
    assert_color(colors.get("terminal.background"), palette["base00"], f"{path}:terminal.background")
    assert_color(colors.get("terminal.foreground"), palette["base05"], f"{path}:terminal.foreground")
    for name, expected in zip(names, ansi):
        assert_color(colors.get(f"terminal.ansi{name}"), expected, f"{path}:terminal.ansi{name}")


def validate_zed(path: Path, palette: dict[str, str], ansi: list[str]) -> None:
    data = load_json(path)
    if data.get("name") != "Waffle Cat":
        raise ValueError(f"{path}: invalid Waffle Cat theme metadata")
    themes = data.get("themes")
    if not isinstance(themes, list) or len(themes) != 1:
        raise ValueError(f"{path}: expected one theme")
    style = themes[0].get("style")
    if not isinstance(style, dict):
        raise ValueError(f"{path}: missing theme style")
    background = style.get("editor.background")
    if not isinstance(background, str) or not background.lower().startswith(palette["base00"]):
        raise ValueError(f"{path}: editor background must derive from {palette['base00']}")
    assert_color(style.get("editor.foreground"), palette["base05"], f"{path}:editor.foreground")
    names = [
        "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
        "bright_black", "bright_red", "bright_green", "bright_yellow", "bright_blue",
        "bright_magenta", "bright_cyan", "bright_white",
    ]
    for name, expected in zip(names, ansi):
        assert_color(style.get(f"terminal.ansi.{name}"), expected, f"{path}:terminal.ansi.{name}")


def main() -> int:
    try:
        palette = canonical_palette()
        ansi = [palette[slot] for slot in ANSI_SLOTS]
        paths = {
            "neovim": ROOT / "colors" / "waffle-cat.lua",
            "helix": ROOT / "configs" / "helix.toml",
            "vscode": ROOT / "configs" / "vscode-theme.json",
            "zed": ROOT / "configs" / "zed.json",
        }
        for path in paths.values():
            validate_known_colors(path, palette)
        validate_neovim(paths["neovim"], palette)
        validate_helix(paths["helix"], palette, ansi)
        validate_vscode(paths["vscode"], palette, ansi)
        validate_zed(paths["zed"], palette, ansi)
    except (OSError, ValueError, json.JSONDecodeError, tomllib.TOMLDecodeError, yaml.YAMLError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print("validated Neovim, Helix, VS Code, and Zed editor themes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
