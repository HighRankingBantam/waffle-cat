# TODO

## Future goals

### Complete modern Neovim colorscheme

After the Waffle Cat 2.0 portable-target migration is complete, expand
`colors/waffle-cat.lua` from its current core colorscheme into a comprehensive
modern Neovim theme.

- Add Treesitter `@...` highlight groups.
- Add LSP semantic-token groups and modifiers.
- Export terminal ANSI colors from the canonical Base24 mapping.
- Cover common UI and plugin groups, including Telescope, completion menus,
  GitSigns, WhichKey, and Lazy.
- Preserve compatibility with plain Neovim; Aether and LazyVim must remain
  optional integrations rather than requirements.
- Add headless validation and representative syntax, diagnostic, diff, search,
  and plugin-view QA.
