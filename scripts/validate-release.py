#!/usr/bin/env python3
"""Validate Waffle Cat 2.0 release invariants and evidence."""

from __future__ import annotations

import argparse
import re
import struct
import subprocess
import sys
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parent.parent
PALETTE_PATH = ROOT / "palette" / "waffle-cat-base24.yaml"
HEX_COLOR = re.compile(r"#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?")
ACTIVE_THEME_PATHS = [ROOT / "palette", ROOT / "configs", ROOT / "colors"]
LEGACY_ALPHA_COLORS = {
    "#3a2d32", "#4a3a40", "#b6a78f", "#efb159", "#f3c77a", "#f7dd9b",
    "#fff3cf", "#834f36", "#ff8c68", "#f0e65a", "#a4a900", "#c7f3ff",
    "#ffbe55", "#c5a0b6", "#e88f37",
}
EXPECTED_CONFIGS = {
    "alacritty.toml", "delta.gitconfig", "foot.ini", "fzf.sh", "ghostty.conf",
    "helix.toml", "kitty.conf", "tmux.conf", "vscode-theme.json",
    "waffle-cat.tmTheme", "warp.yaml", "wezterm.lua", "zed.json",
}
EXPECTED_SCREENSHOTS = {
    "alacritty-ansi.png", "foot-ansi.png", "ghostty-ansi.png", "kitty-ansi.png",
    "wezterm-ansi.png", "neovim-editor.png", "vscode-editor.png",
    "opacity-85-dark-wallpaper.png", "opacity-85-light-wallpaper.png",
}


def load_palette() -> dict[str, str]:
    data = yaml.safe_load(PALETTE_PATH.read_text(encoding="utf-8"))
    palette = data.get("palette") if isinstance(data, dict) else None
    if not isinstance(palette, dict):
        raise ValueError(f"{PALETTE_PATH}: missing palette mapping")
    return {slot: color.lower() for slot, color in palette.items()}


def relative_luminance(color: str) -> float:
    value = color.removeprefix("#")[:6]
    channels = [int(value[index:index + 2], 16) / 255 for index in (0, 2, 4)]
    linear = [channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4 for channel in channels]
    return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]


def contrast_ratio(first: str, second: str) -> float:
    lighter, darker = sorted((relative_luminance(first), relative_luminance(second)), reverse=True)
    return (lighter + 0.05) / (darker + 0.05)


def validate_contrast(palette: dict[str, str]) -> None:
    checks = {
        "foreground/background": ("base05", "base00", 7.0),
        "muted/background": ("base03", "base00", 4.5),
        "error/background": ("base08", "base00", 4.5),
        "selection text/background": ("base05", "base02", 4.5),
    }
    for label, (foreground, background, minimum) in checks.items():
        ratio = contrast_ratio(palette[foreground], palette[background])
        if ratio < minimum:
            raise ValueError(f"{label} contrast {ratio:.2f}:1 is below {minimum:.1f}:1")

    pairs = [
        ("black", "base00", "base03"),
        ("red", "base08", "base12"),
        ("green", "base0B", "base14"),
        ("yellow", "base0A", "base13"),
        ("blue", "base0D", "base16"),
        ("magenta", "base0E", "base17"),
        ("cyan", "base0C", "base15"),
        ("white", "base05", "base07"),
    ]
    for label, normal, bright in pairs:
        if relative_luminance(palette[bright]) <= relative_luminance(palette[normal]):
            raise ValueError(f"bright {label} is not brighter than normal {label}")


def iter_theme_files() -> list[Path]:
    return sorted(
        path
        for directory in ACTIVE_THEME_PATHS
        for path in directory.rglob("*")
        if path.is_file()
    )


def validate_active_colors(palette: dict[str, str]) -> None:
    allowed = set(palette.values()) | {"#000000"}
    for path in iter_theme_files():
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        colors = {color.lower() for color in HEX_COLOR.findall(text)}
        legacy = sorted(color for color in colors if color[:7] in LEGACY_ALPHA_COLORS)
        if legacy:
            raise ValueError(f"{path}: alpha-era colors remain: {', '.join(legacy)}")
        unknown = sorted(color for color in colors if color[:7] not in allowed)
        if unknown:
            raise ValueError(f"{path}: colors outside canonical palette: {', '.join(unknown)}")


def png_dimensions(path: Path) -> tuple[int, int]:
    with path.open("rb") as stream:
        header = stream.read(24)
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path}: invalid PNG header")
    return struct.unpack(">II", header[16:24])


def validate_release_files() -> None:
    actual_configs = {path.name for path in (ROOT / "configs").iterdir() if path.is_file()}
    missing_configs = sorted(EXPECTED_CONFIGS - actual_configs)
    if missing_configs:
        raise ValueError(f"missing release configs: {', '.join(missing_configs)}")

    screenshot_dir = ROOT / "screenshots"
    missing_screenshots = sorted(name for name in EXPECTED_SCREENSHOTS if not (screenshot_dir / name).is_file())
    if missing_screenshots:
        raise ValueError(f"missing QA screenshots: {', '.join(missing_screenshots)}")
    for name in EXPECTED_SCREENSHOTS:
        width, height = png_dimensions(screenshot_dir / name)
        if width < 1200 or height < 700:
            raise ValueError(f"{name}: screenshot is too small ({width}x{height})")

    for name in ("README.md", "CHANGELOG.md", "LICENSE", "TODO.md", "RELEASE-CHECKLIST.md", "screenshots/QA.md"):
        if not (ROOT / name).is_file():
            raise ValueError(f"missing release document: {name}")


def validate_readme() -> None:
    text = (ROOT / "README.md").read_text(encoding="utf-8")
    targets = (
        "Alacritty", "Foot", "Ghostty", "Kitty", "WezTerm", "Warp", "Neovim",
        "Helix", "VS Code", "Zed", "tmux", "bat", "delta", "fzf",
    )
    missing = [target for target in targets if target not in text]
    if missing:
        raise ValueError(f"README omits targets: {', '.join(missing)}")
    if "alpha-final" not in text or "omarchy-waffle-cat-theme" not in text:
        raise ValueError("README must document alpha recovery and Omarchy source relationship")


def validate_clean_git() -> None:
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    if result.stdout:
        raise ValueError("Git worktree is not clean")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--require-clean",
        action="store_true",
        help="also require a clean Git worktree (use after committing release files)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        palette = load_palette()
        validate_contrast(palette)
        validate_active_colors(palette)
        validate_release_files()
        validate_readme()
        if args.require_clean:
            validate_clean_git()
    except (OSError, ValueError, yaml.YAMLError, subprocess.SubprocessError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    clean_note = " with a clean Git worktree" if args.require_clean else ""
    print(f"validated Waffle Cat 2.0 release invariants{clean_note}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
