# Waffle Cat Colorscheme — 2.0 Migration Plan

## Objective

Bring this portable colorscheme repository up to date with Waffle Cat 2.0.

The completed Omarchy theme is now the visual authority:

- Theme repository: `~/Projects/themes/omarchy-waffle-cat-theme`
- Canonical source palette: `colors.toml`
- Portable references:
  - `palette/waffle-cat-base16.yaml`
  - `palette/waffle-cat-base24.yaml`

This repository should package that palette for terminals, editors, and other portable consumers. It should not independently redesign the colors.

## Current State

The repository still represents the alpha-era palette and is not internally consistent.

- `palette/waffle-cat.yaml` identifies itself as `Waffle Cat (alpha)`.
- Only the background color is unchanged from the 2.0 palette.
- `configs/`, `exports/`, and the root `ghostty.conf` contain different color sets.
- The generators are reproducible, but their Base16-to-ANSI mapping is semantically incorrect.
- Normal and bright ANSI roles are duplicated or assigned from the wrong Base16 slots.
- The palette has one partial extension, `base10`, rather than a complete Base24 definition.
- README, license, release metadata, and useful screenshots are missing.
- Several planned targets have never been implemented.

The 2.0 palette improves the system materially:

- honey amber is the dominant accent;
- cream, coffee, syrup, and toasted-waffle neutrals form a clearer material language;
- visible cyan, olive, and neon-yellow competition is reduced;
- error red reaches readable text contrast;
- selection surfaces are more distinct;
- all ANSI bright colors are perceptually brighter than their normal counterparts.

## Migration Principles

1. Treat the Omarchy theme's `colors.toml` as the source of truth during migration.
2. Preserve authored 2.0 values; do not tweak them independently in this repository.
3. Make Base24 the complete portable palette and provide Base16 as a deliberate reduction.
4. Map terminal ANSI colors explicitly by semantic role, not by sequential Base16 slot order.
5. Generate installable files from one canonical local palette.
6. Keep generated and hand-authored files clearly separated.
7. Validate exact palette synchronization before visual QA.
8. Preserve the current alpha palette in Git history or a tag rather than maintaining two undocumented generations in the working tree.

## Target Palette Model

### Base24 source

Create `palette/waffle-cat-base24.yaml` in the colorschemes house style:

- `system: "base24"`
- `name: "Waffle Cat"`
- `slug: "waffle-cat"`
- `author: "OldJobobo"`
- `variant: "dark"`
- exact `base00` through `base17` ordering
- uppercase six-digit hex values
- themed neutral and accent headings
- evocative color names
- concise semantic-role comments

Map the Omarchy semantic roles as follows:

| Base24 slot | `colors.toml` role |
|---|---|
| `base00` | `bg` |
| `base01` | `lighter_bg` |
| `base02` | `selection` |
| `base03` | `muted` |
| `base04` | `dark_fg` |
| `base05` | `fg` |
| `base06` | `light_fg` |
| `base07` | `bright_fg` |
| `base08` | `red` |
| `base09` | `orange` |
| `base0A` | `yellow` |
| `base0B` | `green` |
| `base0C` | `cyan` |
| `base0D` | `blue` |
| `base0E` | `magenta` |
| `base0F` | `brown` |
| `base10` | `dark_bg` |
| `base11` | `darker_bg` |
| `base12` | `bright_red` |
| `base13` | `bright_yellow` |
| `base14` | `bright_green` |
| `base15` | `bright_cyan` |
| `base16` | `bright_blue` |
| `base17` | `bright_magenta` |

### Base16 reduction

Create `palette/waffle-cat-base16.yaml` from the corresponding `base00` through `base0F` values. Document that Base24 remains the richer source for terminal bright colors and darker background extensions.

### Explicit ANSI mapping

Terminal generators must use the authored 2.0 ANSI roles:

| ANSI index | Role |
|---|---|
| `0` | background / black |
| `1` | red |
| `2` | green |
| `3` | yellow |
| `4` | blue / honey amber |
| `5` | magenta |
| `6` | cyan |
| `7` | foreground / white |
| `8` | muted / bright black |
| `9` | bright red |
| `10` | bright green |
| `11` | bright yellow |
| `12` | bright blue |
| `13` | bright magenta |
| `14` | bright cyan |
| `15` | bright foreground / bright white |

Do not infer this sequence by iterating through Base16 accent slots.

## Implementation Phases

### Phase 0 — Preserve the alpha state

- Tag or otherwise record the final alpha commit before replacing the palette.
- Note in the migration commit that 2.0 is a palette-breaking release.
- Keep historical palette values in Git history rather than in duplicate active files.

**Done when:** the alpha generation can be recovered unambiguously from version control.

### Phase 1 — Establish the 2.0 canonical files

- Add the house-style Base24 palette.
- Add the deliberate Base16 reduction.
- Remove or replace `palette/waffle-cat.yaml` so there is no ambiguous canonical source.
- Add a validation script for metadata, slot order, and six-digit hex values.
- Verify both files against the Omarchy theme's `colors.toml`.

**Done when:** every portable palette slot matches Waffle Cat 2.0 exactly and one file is clearly documented as canonical.

### Phase 2 — Repair generation architecture

- Replace the three duplicated inline Python generators with shared palette-loading and mapping logic.
- Generate terminal colors from explicit semantic/ANSI roles.
- Decide on one artifact model:
  - `configs/` contains committed generated installable files and `exports/` is removed; or
  - `exports/` is the generated output directory and `configs/` is removed.
- Remove the extra root `ghostty.conf`, or make it an intentional documented symlink.
- Add a check mode that fails when committed outputs differ from newly generated files.

**Done when:** one command regenerates every target and a clean checkout produces no diff afterward.

### Phase 3 — Regenerate core terminals

Regenerate and verify:

- Alacritty
- Kitty
- Ghostty
- Foot
- WezTerm

Include selection, cursor, foreground, background, and opacity only where the target format supports and requires them. Keep application behavior separate from portable color definitions when practical.

**Done when:** all five terminals use the same 2.0 ANSI mapping and pass syntax/manual load checks.

### Phase 4 — Update editor targets

- Recolor the standalone Neovim colorscheme from the 2.0 palette.
- Preserve readable comments, diagnostics, diffs, search results, and cursor states.
- Add or port portable definitions for:
  - Helix
  - VS Code
  - Zed, if it can be packaged independently
- Treat the Omarchy theme's Aether configuration as a reference, not as a standalone Neovim colorscheme replacement.

**Done when:** representative Lua, Rust, Bash, Markdown, JSON, and diff views are visually checked in at least one terminal editor and one GUI editor.

### Phase 5 — Add portable CLI integrations

Evaluate and add high-value targets without turning this repository into an Omarchy theme duplicate:

- tmux
- bat
- delta
- fzf
- Warp

GTK, Waybar, Hyprland, shell, wallpaper, and Omarchy-specific integrations remain owned by `omarchy-waffle-cat-theme` and should be linked from documentation rather than copied here.

**Done when:** every included target is portable, documented, and generated or intentionally hand-maintained.

### Phase 6 — Documentation and release preparation

Add:

- `README.md`
- `LICENSE`
- installation examples for every shipped target
- palette swatch and editor/terminal screenshots
- source-of-truth and generation documentation
- versioning policy
- changelog or release notes for 2.0
- attribution and a link to the full Omarchy theme

The README should describe Waffle Cat as a warm, mature daily-driver palette built from syrup brown, coffee, toasted waffle, honey amber, cream, and restrained support colors.

**Done when:** a new user can identify the canonical palette, install a supported target, regenerate outputs, and understand the relationship to the Omarchy theme.

### Phase 7 — Release validation

Run automated checks for:

- valid YAML
- exact Base16/Base24 slot ordering
- valid six-digit hex values
- exact generated-output reproducibility
- no unknown colors in generated targets
- normal/bright ANSI luminance ordering
- foreground and muted-text contrast
- clean Git worktree after generation

Perform manual QA for:

- comments and inactive text
- cursor visibility
- selections and search matches
- diagnostics and semantic states
- diff additions, changes, and deletions
- bright ANSI colors
- behavior at 80–90% terminal opacity

**Done when:** validation passes, screenshots are current, and a fresh clone can reproduce the release artifacts.

## Proposed Repository Shape

```text
waffle-cat/
├── palette/
│   ├── waffle-cat-base24.yaml
│   └── waffle-cat-base16.yaml
├── configs/
│   ├── alacritty.toml
│   ├── foot.ini
│   ├── ghostty.conf
│   ├── kitty.conf
│   ├── wezterm.lua
│   ├── helix.toml
│   └── vscode-theme.json
├── colors/
│   └── waffle-cat.lua
├── scripts/
│   ├── generate-all.sh
│   ├── validate-palettes.py
│   └── check-generated.sh
├── screenshots/
├── CHANGELOG.md
├── LICENSE
└── README.md
```

The final structure may differ, but it must retain one canonical palette, one generated-artifact location, and one shared mapping implementation.

## Release Criteria for Waffle Cat 2.0

- Complete house-style Base24 palette exists.
- Base16 reduction matches the 2.0 source.
- No alpha palette values remain in active generated targets.
- ANSI mappings are explicit and semantically correct.
- Alacritty, Kitty, Ghostty, Foot, and WezTerm are verified.
- The standalone Neovim colorscheme is updated.
- At least one GUI editor export is verified.
- Generation is deterministic and leaves the worktree clean.
- README, license, screenshots, and installation instructions are present.
- The relationship to `omarchy-waffle-cat-theme` is documented.
- The release is identified as a breaking palette update from the alpha generation.
