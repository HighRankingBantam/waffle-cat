#!/usr/bin/env python3
"""Generate portable terminal and CLI themes from the canonical Base24 palette."""

from __future__ import annotations

import argparse
import difflib
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "palette" / "waffle-cat-base24.yaml"
OUTPUT_DIR = ROOT / "configs"
HEADER = "Generated from palette/waffle-cat-base24.yaml. Do not edit by hand."

# Explicit semantic ANSI mapping. Do not derive this from Base16 slot order.
ANSI_SLOTS = [
    "base00",  # black / background
    "base08",  # red
    "base0B",  # green
    "base0A",  # yellow
    "base0D",  # blue / honey amber
    "base0E",  # magenta
    "base0C",  # cyan
    "base05",  # white / foreground
    "base03",  # bright black / muted
    "base12",  # bright red
    "base14",  # bright green
    "base13",  # bright yellow
    "base16",  # bright blue
    "base17",  # bright magenta
    "base15",  # bright cyan
    "base07",  # bright white / bright foreground
]
COLOR_NAMES = ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white")


def load_palette() -> dict[str, str]:
    data = yaml.safe_load(SOURCE.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("system") != "base24":
        raise ValueError(f"{SOURCE}: expected a Base24 mapping")
    palette = data.get("palette")
    if not isinstance(palette, dict):
        raise ValueError(f"{SOURCE}: missing palette mapping")
    missing = [slot for slot in ANSI_SLOTS if slot not in palette]
    if missing:
        raise ValueError(f"{SOURCE}: missing slots: {', '.join(missing)}")
    return palette


def color(palette: dict[str, str], slot: str, *, hash_prefix: bool = True) -> str:
    value = palette[slot].removeprefix("#").lower()
    return f"#{value}" if hash_prefix else value


def ansi_colors(palette: dict[str, str], *, hash_prefix: bool = True) -> list[str]:
    return [color(palette, slot, hash_prefix=hash_prefix) for slot in ANSI_SLOTS]


def render_alacritty(palette: dict[str, str]) -> str:
    ansi = ansi_colors(palette)
    lines = [
        f"# {HEADER}",
        "[colors.primary]",
        f'background = "{color(palette, "base00")}"',
        f'foreground = "{color(palette, "base05")}"',
        "",
        "[colors.selection]",
        f'text = "{color(palette, "base05")}"',
        f'background = "{color(palette, "base02")}"',
        "",
        "[colors.cursor]",
        f'text = "{color(palette, "base00")}"',
        f'cursor = "{color(palette, "base07")}"',
        "",
        "[colors.normal]",
    ]
    lines.extend(f'{name} = "{value}"' for name, value in zip(COLOR_NAMES, ansi[:8]))
    lines.extend(("", "[colors.bright]"))
    lines.extend(f'{name} = "{value}"' for name, value in zip(COLOR_NAMES, ansi[8:]))
    return "\n".join(lines) + "\n"


def render_kitty(palette: dict[str, str]) -> str:
    lines = [
        f"# {HEADER}",
        f"background {color(palette, 'base00')}",
        f"foreground {color(palette, 'base05')}",
        f"selection_background {color(palette, 'base02')}",
        f"selection_foreground {color(palette, 'base05')}",
        f"cursor {color(palette, 'base07')}",
        f"cursor_text_color {color(palette, 'base00')}",
    ]
    lines.extend(f"color{index} {value}" for index, value in enumerate(ansi_colors(palette)))
    return "\n".join(lines) + "\n"


def render_ghostty(palette: dict[str, str]) -> str:
    lines = [
        f"# {HEADER}",
        f"background = {color(palette, 'base00')}",
        f"foreground = {color(palette, 'base05')}",
        f"selection-background = {color(palette, 'base02')}",
        f"selection-foreground = {color(palette, 'base05')}",
        f"cursor-color = {color(palette, 'base07')}",
        f"cursor-text = {color(palette, 'base00')}",
    ]
    lines.extend(
        f"palette = {index}={value}" for index, value in enumerate(ansi_colors(palette))
    )
    return "\n".join(lines) + "\n"


def render_foot(palette: dict[str, str]) -> str:
    ansi = ansi_colors(palette, hash_prefix=False)
    lines = [
        f"# {HEADER}",
        "[colors-dark]",
        f"background={color(palette, 'base00', hash_prefix=False)}",
        f"foreground={color(palette, 'base05', hash_prefix=False)}",
        (
            f"selection-background={color(palette, 'base02', hash_prefix=False)}"
        ),
        f"selection-foreground={color(palette, 'base05', hash_prefix=False)}",
        (
            f"cursor={color(palette, 'base00', hash_prefix=False)} "
            f"{color(palette, 'base07', hash_prefix=False)}"
        ),
    ]
    lines.extend(f"regular{index}={value}" for index, value in enumerate(ansi[:8]))
    lines.extend(f"bright{index}={value}" for index, value in enumerate(ansi[8:]))
    return "\n".join(lines) + "\n"


def render_wezterm(palette: dict[str, str]) -> str:
    ansi = ansi_colors(palette)

    def lua_array(values: list[str]) -> str:
        return "{ " + ", ".join(f'"{value}"' for value in values) + " }"

    lines = [
        f"-- {HEADER}",
        'local wezterm = require("wezterm")',
        "local config = wezterm.config_builder()",
        "",
        "config.colors = {",
        f'  foreground = "{color(palette, "base05")}",',
        f'  background = "{color(palette, "base00")}",',
        f'  cursor_bg = "{color(palette, "base07")}",',
        f'  cursor_fg = "{color(palette, "base00")}",',
        f'  cursor_border = "{color(palette, "base07")}",',
        f'  selection_fg = "{color(palette, "base05")}",',
        f'  selection_bg = "{color(palette, "base02")}",',
        f"  ansi = {lua_array(ansi[:8])},",
        f"  brights = {lua_array(ansi[8:])},",
        "}",
        "",
        "return config",
    ]
    return "\n".join(lines) + "\n"


def render_tmux(palette: dict[str, str]) -> str:
    return "\n".join(
        [
            f"# {HEADER}",
            f'set -g status-style "fg={color(palette, "base05")},bg={color(palette, "base01")}"',
            f'set -g status-left-style "fg={color(palette, "base00")},bg={color(palette, "base0D")},bold"',
            f'set -g status-right-style "fg={color(palette, "base05")},bg={color(palette, "base01")}"',
            f'set -g window-status-style "fg={color(palette, "base03")},bg={color(palette, "base01")}"',
            f'set -g window-status-current-style "fg={color(palette, "base00")},bg={color(palette, "base05")},bold"',
            f'set -g pane-border-style "fg={color(palette, "base02")}"',
            f'set -g pane-active-border-style "fg={color(palette, "base0D")}"',
            f'set -g message-style "fg={color(palette, "base00")},bg={color(palette, "base0A")}"',
            f'set -g message-command-style "fg={color(palette, "base00")},bg={color(palette, "base0D")}"',
            f'set -g mode-style "fg={color(palette, "base00")},bg={color(palette, "base0A")},bold"',
            f'set -g clock-mode-colour "{color(palette, "base0D")}"',
        ]
    ) + "\n"


def render_fzf(palette: dict[str, str]) -> str:
    theme = ",".join(
        [
            f"fg:{color(palette, 'base05')}",
            f"bg:{color(palette, 'base00')}",
            f"hl:{color(palette, 'base17')}",
            f"fg+:{color(palette, 'base05')}",
            f"bg+:{color(palette, 'base01')}",
            f"hl+:{color(palette, 'base17')}",
            f"info:{color(palette, 'base14')}",
            f"prompt:{color(palette, 'base0D')}",
            f"pointer:{color(palette, 'base15')}",
            f"marker:{color(palette, 'base14')}",
            f"spinner:{color(palette, 'base15')}",
            f"header:{color(palette, 'base0E')}",
            f"border:{color(palette, 'base02')}",
            f"label:{color(palette, 'base0D')}",
            f"query:{color(palette, 'base05')}",
        ]
    )
    return "\n".join(
        [
            f"# {HEADER}",
            "# Source this POSIX shell fragment before launching fzf.",
            f"WAFFLE_CAT_FZF_COLORS='--color={theme}'",
            'export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }$WAFFLE_CAT_FZF_COLORS"',
            "unset WAFFLE_CAT_FZF_COLORS",
        ]
    ) + "\n"


def render_delta(palette: dict[str, str]) -> str:
    return "\n".join(
        [
            f"# {HEADER}",
            '[delta "waffle-cat"]',
            "    dark = true",
            '    syntax-theme = "waffle-cat"',
            "    line-numbers = true",
            f'    line-numbers-left-style = "{color(palette, "base03")}"',
            f'    line-numbers-right-style = "{color(palette, "base03")}"',
            f'    file-style = "{color(palette, "base0D")}" bold',
            f'    file-decoration-style = "{color(palette, "base02")}" ul',
            f'    hunk-header-style = "{color(palette, "base0E")}"',
            f'    hunk-header-decoration-style = "{color(palette, "base02")}" box',
            f'    minus-style = "{color(palette, "base08")}" "{color(palette, "base01")}"',
            f'    minus-emph-style = "{color(palette, "base07")}" "{color(palette, "base02")}"',
            f'    plus-style = "{color(palette, "base0B")}" "{color(palette, "base01")}"',
            f'    plus-emph-style = "{color(palette, "base11")}" "{color(palette, "base14")}"',
            '    zero-style = syntax',
        ]
    ) + "\n"


def render_warp(palette: dict[str, str]) -> str:
    ansi = ansi_colors(palette)
    lines = [
        f"# {HEADER}",
        "name: Waffle Cat",
        f'accent: "{color(palette, "base0D")}"',
        f'cursor: "{color(palette, "base07")}"',
        f'background: "{color(palette, "base00")}"',
        f'foreground: "{color(palette, "base05")}"',
        "details: darker",
        "",
        "terminal_colors:",
        "  normal:",
    ]
    lines.extend(
        f'    {name}: "{value}"' for name, value in zip(COLOR_NAMES, ansi[:8])
    )
    lines.append("  bright:")
    lines.extend(
        f'    {name}: "{value}"' for name, value in zip(COLOR_NAMES, ansi[8:])
    )
    return "\n".join(lines) + "\n"


def render_bat(palette: dict[str, str]) -> str:
    scopes = [
        ("Comment", "comment, punctuation.definition.comment", "base03", "italic"),
        ("String", "string", "base0B", None),
        ("Number and constant", "constant", "base09", None),
        ("Built-in constant", "constant.language", "base13", None),
        ("Keyword", "keyword, storage", "base0E", None),
        ("Function", "entity.name.function, support.function", "base0D", None),
        ("Type", "entity.name.type, entity.name.class, support.type", "base0A", None),
        ("Attribute", "entity.other.attribute-name", "base0C", None),
        ("Variable", "variable", "base05", None),
        ("Invalid", "invalid", "base07", "bold"),
        ("Markup heading", "markup.heading", "base0D", "bold"),
        ("Markup inserted", "markup.inserted", "base0B", None),
        ("Markup deleted", "markup.deleted", "base08", None),
        ("Markup changed", "markup.changed", "base09", None),
        ("Markup raw", "markup.raw", "base0B", None),
    ]
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f"<!-- {HEADER} -->",
        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
        '<plist version="1.0">',
        "<dict>",
        "  <key>name</key><string>Waffle Cat</string>",
        "  <key>settings</key>",
        "  <array>",
        "    <dict>",
        "      <key>settings</key>",
        "      <dict>",
        f'        <key>background</key><string>{color(palette, "base00")}</string>',
        f'        <key>foreground</key><string>{color(palette, "base05")}</string>',
        f'        <key>caret</key><string>{color(palette, "base07")}</string>',
        f'        <key>selection</key><string>{color(palette, "base02")}</string>',
        f'        <key>lineHighlight</key><string>{color(palette, "base01")}</string>',
        f'        <key>invisibles</key><string>{color(palette, "base03")}</string>',
        "      </dict>",
        "    </dict>",
    ]
    for name, scope, slot, font_style in scopes:
        lines.extend(
            [
                "    <dict>",
                f"      <key>name</key><string>{name}</string>",
                f"      <key>scope</key><string>{scope}</string>",
                "      <key>settings</key>",
                "      <dict>",
                f'        <key>foreground</key><string>{color(palette, slot)}</string>',
            ]
        )
        if name == "Invalid":
            lines.append(f'        <key>background</key><string>{color(palette, "base08")}</string>')
        if font_style:
            lines.append(f"        <key>fontStyle</key><string>{font_style}</string>")
        lines.extend(["      </dict>", "    </dict>"])
    lines.extend(["  </array>", "</dict>", "</plist>"])
    return "\n".join(lines) + "\n"


RENDERERS = {
    "alacritty.toml": render_alacritty,
    "delta.gitconfig": render_delta,
    "foot.ini": render_foot,
    "fzf.sh": render_fzf,
    "ghostty.conf": render_ghostty,
    "kitty.conf": render_kitty,
    "tmux.conf": render_tmux,
    "waffle-cat.tmTheme": render_bat,
    "warp.yaml": render_warp,
    "wezterm.lua": render_wezterm,
}


def check_output(path: Path, expected: str) -> bool:
    try:
        actual = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        print(f"missing generated file: {path.relative_to(ROOT)}", file=sys.stderr)
        return False
    if actual == expected:
        return True
    diff = difflib.unified_diff(
        actual.splitlines(),
        expected.splitlines(),
        fromfile=str(path.relative_to(ROOT)),
        tofile=f"generated/{path.name}",
        lineterm="",
    )
    print("\n".join(diff), file=sys.stderr)
    return False


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail if committed configs differ from generated content",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        palette = load_palette()
    except (OSError, ValueError, yaml.YAMLError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    outputs = {
        OUTPUT_DIR / filename: renderer(palette)
        for filename, renderer in RENDERERS.items()
    }
    if args.check:
        clean = all(check_output(path, content) for path, content in outputs.items())
        if clean:
            print(f"validated {len(outputs)} generated portable configs")
        return 0 if clean else 1

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for path, content in outputs.items():
        path.write_text(content, encoding="utf-8")
        print(f"wrote {path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
