# Changelog

All notable changes to Waffle Cat are documented here. The project follows
[Semantic Versioning](https://semver.org/).

## [2.0.0] - Unreleased

Waffle Cat 2.0 is a palette-breaking release from the alpha generation.

### Added

- Canonical house-style Base24 palette and deliberate Base16 reduction.
- Shared deterministic generator with stale-output checking.
- Generated themes for Alacritty, Foot, Ghostty, Kitty, and WezTerm.
- Portable editor themes for Neovim, Helix, VS Code, and Zed.
- Portable integrations for tmux, bat, delta, fzf, and Warp.
- Palette, editor, CLI, and generated-output validators.
- Reproducible terminal and editor QA fixtures and screenshots.
- Installation, development, source-of-truth, and versioning documentation.

### Changed

- Replaced the alpha palette with the authored Waffle Cat 2.0 palette from the
  completed Omarchy theme.
- Made honey amber the dominant accent and reduced competing neon colors.
- Replaced inferred Base16 terminal ordering with an explicit semantic ANSI
  mapping.
- Consolidated generated artifacts under `configs/`.
- Updated the standalone Neovim colorscheme to the 2.0 palette.

### Removed

- Ambiguous `palette/waffle-cat.yaml` alpha source.
- Duplicated inline terminal generators.
- Redundant `exports/` artifacts and root `ghostty.conf`.

### Migration notes

- Existing users should replace all alpha-era generated files rather than
  mixing old and new targets.
- Base24 is now the canonical portable palette.
- The final alpha state remains available from the `alpha-final` Git tag.

[2.0.0]: https://github.com/OldJobobo/waffle-cat/releases/tag/v2.0.0
