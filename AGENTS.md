# Repository Guidelines

## Project Structure & Module Organization
- `palette/waffle-cat-base24.yaml` is the canonical portable palette definition.
- `palette/waffle-cat-base16.yaml` is the deliberate Base16 reduction.
- `configs/` holds generated app configs and intentionally maintained editor exports.
- `scripts/` contains shared generation and validation tooling.
- `screenshots/` stores visual QA captures.
- `DEVPLAN.md` documents the roadmap, target exports, and QA checklist.

## Build, Test, and Development Commands
- `./scripts/generate-all.sh` regenerates every generated terminal and CLI config in `configs/` from the Base24 palette.
- `./scripts/check-generated.sh` validates the palettes and fails if generated configs are stale.
- `./scripts/validate-palettes.py --source /path/to/colors.toml` also verifies synchronization with the Omarchy source palette.
- `./scripts/launch-terminal-qa.sh <terminal> [opacity]` opens the shared visual QA fixture with a generated terminal config.
- Use `screenshots/QA.md` and the current captures when reviewing palette or terminal-output changes.

## Coding Style & Naming Conventions
- Use 2-space indentation in TOML files and keep keys lowercase (example: `colors.primary`).
- Hex colors must be lowercase and quoted (example: `"#fece6e"`).
- When adding new files, prefer descriptive, kebab-case names (example: `waffle-cat.yaml`).

## Testing Guidelines
- Run `./scripts/check-generated.sh` after palette, generator, editor, or integration changes.
- Follow the visual QA checklist in `DEVPLAN.md` and capture screenshots if you change contrast, cursor, or accent roles.
- Keep validation scripts focused by target area and document new checks in `README.md`.

## Commit & Pull Request Guidelines
- There is no Git history yet, so no established commit convention exists.
- Recommended: use Conventional Commits (example: `feat: adjust cursor contrast`).
- PRs should describe palette changes, include before/after screenshots when visuals change, and reference any updated QA checklist items.

## Release & Versioning Notes
- `DEVPLAN.md` specifies semantic versioning expectations; align version bumps with palette or export changes when releases are introduced.
