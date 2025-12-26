# Waffle Cat Color Scheme — Development Plan

## Overview
**Waffle Cat** is a warm, cozy, high-contrast color scheme inspired by golden waffles, soft browns, honeyed yellows, and the gentle warmth of a sleepy cat in morning sunlight. The goal of this project is to provide a *portable, canonical color definition* that can be reliably exported to modern terminals, editors, and UI environments.

This repository will treat a **single palette definition** as the source of truth, with generated artifacts for downstream applications.

---

## Design Goals
- Warm, cozy, food-inspired palette (waffles, honey, toasted sugar)
- Excellent readability for long coding sessions
- Works well in low-light and daylight environments
- Avoids harsh blues; golds and ambers replace traditional “blue” roles
- Consistent contrast ratios across terminals and editors
- Minimal gimmicks; practical daily-driver theme

---

## Canonical Format (Source of Truth)

### Base16 YAML
The canonical palette definition will be stored as a **Base16 YAML** file.

**Rationale**
- Widely adopted interchange format
- Supported by generators for dozens of applications
- Forces intentional semantic color mapping
- Future-proof and easy to extend (Base24)

**File**
```
palette/waffle-cat.yaml
```

This file will be hand-curated and reviewed visually in multiple editors before releases.

---

## Initial Palette (Reference)

### Primary
- Background: `#292025`
- Foreground: `#f7dd9b`

### Normal
- Black:   `#292025`
- Red:     `#d66556`
- Green:   `#a4a900`
- Yellow:  `#caaf00`
- Blue:    `#fece6e`
- Magenta: `#c5a0b6`
- Cyan:    `#e88f37`
- White:   `#efb159`

### Bright
- Black:   `#834f36`
- Red:     `#ff8c68`
- Green:   `#f6ff40`
- Yellow:  `#ffe36e`
- Blue:    `#ffbe55`
- Magenta: `#e5d0dc`
- Cyan:    `#c69752`
- White:   `#f7dd9b`

### Cursor
- Text:   `#834f36`
- Cursor: `#fece6e`

---

## Repository Structure
```
waffle-cat/
├── palette/
│   └── waffle-cat.yaml        # Base16 source of truth
├── exports/
│   ├── alacritty.toml
│   ├── kitty.conf
│   ├── wezterm.lua
│   ├── foot.ini
│   └── ghostty.conf
├── scripts/
│   └── generate.sh            # Optional automation
├── screenshots/
│   ├── terminal.png
│   └── editor.png
├── DEVPLAN.md
├── README.md
└── LICENSE
```

---

## Export Targets (Phase Order)

### Phase 1 — Core Terminals
- Alacritty (TOML)
- Kitty
- WezTerm
- Foot
- Ghostty

### Phase 2 — Editors
- Neovim (Lua colorscheme)
- Vim
- Helix
- VS Code

### Phase 3 — UI / Misc
- tmux
- bat
- delta
- fzf
- GTK / Waybar accents (non-invasive)

---

## Generation Strategy
- Manual Base16 YAML editing
- Visual verification in:
  - Neovim (Lua tree-sitter)
  - Rust, Lua, Bash, Markdown
- Export generation via:
  - base16-builder
  - or custom scripts if needed

Generated files **must not** be edited directly.

---

## Visual QA Checklist
- Comments readable but subdued
- Keywords pop without glare
- Strings feel “warm,” not neon
- No color clashes at 80–90% opacity
- Cursor highly visible on all backgrounds
- Diff views readable

---

## Versioning
- Semantic versioning
- Palette changes = minor bump
- Contrast or mapping changes = major bump
- Export-only fixes = patch bump

---

## License
MIT License — free to use, modify, and redistribute.

---

## Future Ideas
- Base24 extension
- “Waffle Cat Darker” variant
- “Waffle Cat Latte” (light theme)
- Matching wallpaper pack
- Waybar / Hyprland accent presets

---

## Release Criteria (v1.0)
- Base16 palette finalized
- At least 3 terminal exports verified
- README with install instructions
- Screenshots included
