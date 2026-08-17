# Waffle Cat 2.0 Release Checklist

Validated on 2026-08-16.

## Palette

- [x] Canonical house-style Base24 palette exists.
- [x] Base16 is an exact reduction of `base00` through `base0F`.
- [x] All 24 slots match the Omarchy `colors.toml` source.
- [x] Slot order, metadata, and uppercase six-digit values validate.
- [x] No alpha-era colors remain in active palette, config, or colorscheme files.

## Generated targets

- [x] Alacritty
- [x] Foot
- [x] Ghostty
- [x] Kitty
- [x] WezTerm
- [x] tmux
- [x] bat
- [x] delta
- [x] fzf
- [x] Warp
- [x] Generated output is deterministic.
- [x] Regeneration changes no artifact hash or worktree status.

## Editor targets

- [x] Standalone Neovim colorscheme updated to Waffle Cat 2.0.
- [x] Helix export validates.
- [x] VS Code export validates and was visually captured.
- [x] Zed export validates.
- [x] Lua, Rust, Bash, Markdown, JSON, and diff fixtures load in Neovim.

## Contrast and visual QA

- [x] Foreground contrast: 14.45:1.
- [x] Muted contrast: 5.03:1.
- [x] Error red contrast: 4.70:1.
- [x] Every ANSI bright color is brighter than its normal counterpart.
- [x] Five terminal captures are current.
- [x] Neovim and VS Code captures are current.
- [x] Dark- and light-backdrop 85% opacity captures are current.
- [x] Cursor, selection, search, diagnostics, and diff states pass review.

## Documentation

- [x] README documents all shipped targets.
- [x] Installation examples are included.
- [x] Source-of-truth and Omarchy relationship are documented.
- [x] Semantic versioning policy is documented.
- [x] Breaking 2.0 migration notes are present.
- [x] MIT license is present.
- [x] Changelog entry is prepared.
- [x] Final alpha state is preserved by the `alpha-final` tag.

## Reproducibility

- [x] A clean exported source snapshot was initialized as a temporary Git
  repository.
- [x] All validators passed inside that snapshot.
- [x] Regeneration left the snapshot worktree clean.
- [x] Neovim loaded the standalone colorscheme from the snapshot.

## Final publication steps

These remain intentionally unperformed until the release changes are reviewed:

1. Review the complete repository diff.
2. Commit the Waffle Cat 2.0 migration.
3. Run `./scripts/validate-release.py --require-clean` in the committed tree.
4. Create the `v2.0.0` tag.
5. Push the migration commit, `alpha-final`, and `v2.0.0` tags.
6. Publish the prepared changelog entry as the GitHub release notes.
