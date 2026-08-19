# Waffle Cat Classic

Snapshot of **OldJobobo/omarchy-waffle-cat-theme** at `89f6443` (2026-06-21),
before the Waffle Cat 2.0 Quattro revamp replaced the palette and dropped
the wallpaper pack from 18 images to 6.

This is a backup only. It is not a fork for PRs.

## What is in here

- Full old theme tree (`colors.toml`, Hyprland, GTK, terminals, nvim, Waybar, Vencord, …)
- Original 18 wallpapers
- The 6 Waffle Cat 2.0 wallpapers, kept so nothing from the merge is lost

Old accent: `#ffbe55` (borders also used `#fece6e`). Background: `#292025`.

## Restore

```bash
rsync -a --exclude .git --exclude README.md ./ ~/.config/omarchy/themes/waffle-cat/
# or wallpapers only:
rsync -a backgrounds/ ~/.config/omarchy/themes/waffle-cat/backgrounds/
rsync -a backgrounds/ ~/.config/omarchy/backgrounds/waffle-cat/
```

Upstream 2.0 lives at https://github.com/OldJobobo/omarchy-waffle-cat-theme
