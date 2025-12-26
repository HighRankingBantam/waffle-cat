# Repository Guidelines

## Project Structure & Module Organization
- `palette/waffle-cat.yaml` is the canonical Base16 palette definition.
- `colors.toml` is a reference palette (Alacritty-style TOML) used for comparison during early work.
- `exports/` will hold generated theme files; do not edit generated files directly.
- `scripts/` is reserved for generation or validation tooling.
- `screenshots/` stores visual QA captures.
- `DEVPLAN.md` documents the roadmap, target exports, and QA checklist.

## Build, Test, and Development Commands
- `./scripts/generate-alacritty.sh` writes `exports/alacritty.toml` from `colors.toml`.
- `./scripts/generate-kitty.sh` writes `exports/kitty.conf` from `colors.toml`.
- `./scripts/generate-ghostty.sh` writes `exports/ghostty.conf` from `colors.toml`.
- Use manual validation: open `colors.toml` in a TOML-aware editor and visually review the palette in a terminal/editor you control.

## Coding Style & Naming Conventions
- Use 2-space indentation in TOML files and keep keys lowercase (example: `colors.primary`).
- Hex colors must be lowercase and quoted (example: `"#fece6e"`).
- When adding new files, prefer descriptive, kebab-case names (example: `waffle-cat.yaml`).

## Testing Guidelines
- There are no automated tests.
- Follow the visual QA checklist in `DEVPLAN.md` and capture screenshots if you change contrast, cursor, or accent roles.
- If you introduce tests or validation scripts, name them with a clear prefix (example: `test_palette.sh`) and document how to run them.

## Commit & Pull Request Guidelines
- There is no Git history yet, so no established commit convention exists.
- Recommended: use Conventional Commits (example: `feat: adjust cursor contrast`).
- PRs should describe palette changes, include before/after screenshots when visuals change, and reference any updated QA checklist items.

## Release & Versioning Notes
- `DEVPLAN.md` specifies semantic versioning expectations; align version bumps with palette or export changes when releases are introduced.
