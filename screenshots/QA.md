# Waffle Cat 2.0 Terminal Visual QA

## Coverage

The shared fixture in `scripts/terminal-qa.sh` was rendered with the generated
configs for Alacritty, Foot, Ghostty, Kitty, and WezTerm. Each terminal loaded
the same explicit ANSI mapping from the canonical Base24 palette.

| Target | Capture | Result |
|---|---|---|
| Alacritty | `alacritty-ansi.png` | Pass |
| Foot | `foot-ansi.png` | Pass |
| Ghostty | `ghostty-ansi.png` | Pass; the live compositor applies additional window translucency |
| Kitty | `kitty-ansi.png` | Pass |
| WezTerm | `wezterm-ansi.png` | Pass |
| 85% opacity, dark wallpaper | `opacity-85-dark-wallpaper.png` | Pass |
| 85% opacity, light backdrop | `opacity-85-light-wallpaper.png` | Pass |

## Findings

- All six authored bright chromatic colors are perceptually brighter than
  their corresponding normal colors.
- Honey amber remains the dominant accent while green, cyan, and magenta read
  as supporting colors.
- Normal and bright ANSI rows remain distinguishable in all five terminals.
- The cream foreground is highly legible against the cocoa background.
- Muted text remains readable without competing with body text.
- Error red is readable as terminal text and remains distinct from amber
  warnings.
- The bright cream cursor is immediately visible against the background.
- Terminal-native mouse selection and search UI pass manual interaction QA.
- Diff additions, deletions, and changes are visually separable.
- At 85% opacity, text and ANSI colors remain readable over both the active
  dark wallpaper and a synthetic light `#f3e7d3` backdrop.

## Contrast and luminance checks

Measured against `base00` (`#292025`):

- foreground (`base05`): **14.45:1**
- muted (`base03`): **5.03:1**
- error red (`base08`): **4.70:1**
- honey amber (`base0D`): **4.84:1**

Every authored bright pair increased in relative luminance: red, green,
yellow, honey amber/blue, magenta, and cyan.

## Editor QA

The standalone Neovim colorscheme and portable editor exports were validated
against the canonical Base24 palette.

| Target | Evidence | Result |
|---|---|---|
| Neovim | `neovim-editor.png` | Pass |
| VS Code | `vscode-editor.png` | Pass |
| Helix | TOML parse and palette synchronization | Pass; executable unavailable for visual capture |
| Zed | JSON parse and palette synchronization | Pass; executable unavailable for visual capture |

Neovim successfully loaded Lua, Rust, Bash, Markdown, JSON, and diff fixtures
from `qa/`. VS Code loaded the Rust fixture through a temporary pure-theme
extension and displayed the expected Waffle Cat workbench and syntax colors.

## CLI integration QA

| Target | Check | Result |
|---|---|---|
| tmux | Loaded generated config in an isolated server | Pass |
| bat | Built an isolated cache and rendered the Rust fixture | Pass |
| fzf | Sourced shell fragment and parsed color options | Pass |
| delta | Parsed generated Git configuration | Pass; executable unavailable |
| Warp | Parsed YAML and verified full ANSI synchronization | Pass; executable unavailable |

## Manual interaction checks

Terminal-native mouse selection and search UI were manually confirmed as
passing. These interactive states are recorded here because they cannot be
fully represented by the static ANSI screenshots.
