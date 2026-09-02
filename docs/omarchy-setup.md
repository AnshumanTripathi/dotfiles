# Omarchy Setup

Omarchy is an Arch Linux + Hyprland distribution. This machine is a MacBook running Omarchy. Its config lives at `~/.config/hypr/` and `~/.config/omarchy/` — those directories are **not tracked by this chezmoi repo**; this doc is both the reference for what's configured (and why) and the checklist for reproducing it on a new machine. The only Omarchy-aware pieces that actually live in this repo are the package-install detection and the nvim theming split, covered under Reference below.

## Bring-up checklist

### 1. Install the OS

- **Omarchy**: run the official installer from [omarchy.org](https://omarchy.org) — it installs Arch + Hyprland + Omarchy in one pass. Check the site for the current install command before running it; it wasn't captured in any prior session for this machine, so don't assume the exact invocation without confirming.
- **Plain Arch (no Omarchy)**: standard `archinstall`, then add Hyprland yourself. Without Omarchy installed, chezmoi's `pacman -Qi omarchy` detection in `run_onchange_install-packages.sh.tmpl` won't fire, so you won't get the Omarchy-specific package substitutions (see step 3) — you'll need `ttf-jetbrains-mono-nerd` and `libreoffice-fresh` as normal, no adjustment needed.

### 2. Prerequisites

- `git` and `curl` (already present on Omarchy/Arch base installs)
- Import your GPG signing/encryption key — dotfiles secrets are GPG-encrypted, and `chezmoi apply` will fail on template decryption without it:
  ```bash
  gpg --import /path/to/your-key.asc
  ```
- Have your gopass store reachable if you use it, since the restic backup password is auto-generated into gopass on first apply (`arch/backup/restic`)

### 3. Bootstrap chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply AnshumanTripathi
```

Answer the prompts (see [README.md](../README.md#first-time-setup) for the full table). For this machine's profile: `personal`, `useGhostty` = yes, AI agent = `claude-code`.

This one command handles, automatically and correctly for Omarchy:

- All packages from `packages.yaml`, with Omarchy-aware substitutions (skips `ttf-jetbrains-mono-nerd` since it conflicts with Omarchy's `ttf-jetbrains-mono-nerd-basic`; installs `libreoffice-still` instead of Omarchy's default `libreoffice-fresh`)
- **Ghostty config** — fully templated (`private_dot_config/ghostty/config.tmpl`): JetBrainsMono Nerd Font 14pt, Catppuccin Mocha, unlimited scrollback, and the Linux-specific `super+right`/`super+left`/`alt+delete` Emacs/macOS-style line-editing keybinds. No manual Ghostty setup needed.
- zsh / oh-my-zsh, Starship prompt, git config + signing key
- Neovim: `private_dot_config/nvim/` deploys on top of whatever `omarchy-nvim` (pulled in by the Omarchy package itself) has already seeded — the LazyVim bootstrap + theme-sync plugins just work once both are present. See [Neovim on Omarchy](#neovim-on-omarchy) below if something looks off.
- Python via pyenv, vim-plug
- **Linux only**: btrbk + restic backup infrastructure (see [docs/linux-backups.md](linux-backups.md))

**Not applicable on this machine**: the GNOME touchpad tap-to-click fix and the GNOME screenshot keybinding script (`run_onchange_setup-gnome-settings.sh.tmpl`) both no-op — they're guarded on `gnome-shell` being present, which it isn't under Hyprland. Touchpad natural-scroll and the screenshot binding are handled in step 4 instead.

### 4. Recreate the Hyprland personal overrides

These live at `~/.config/hypr/` and are **not tracked by chezmoi** (they live outside any `dot_`-prefixed directory in this repo). Omarchy 4 configures Hyprland through Lua instead of the traditional `hyprland.conf`: `hyprland.lua` loads Omarchy's own defaults first, then five personal-override files scaffolded empty on install. Fill them in as follows.

**`~/.config/hypr/monitors.lua`** — single auto-detected monitor, HiDPI scale:
```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
```
Why `1.6`/`GDK_SCALE=2` specifically (vs. other HiDPI factors) isn't recorded anywhere — not established from config or session history.

**`~/.config/hypr/input.lua`** — natural scroll, physical Caps Lock:
```lua
hl.config({
  input = {
    -- Restore the physical Caps Lock key (Omarchy's default remaps it to Compose).
    kb_options = "",
    touchpad = {
      natural_scroll = true,
    }
  },
})
```

**`~/.config/hypr/bindings.lua`** — screenshot rebind:
```lua
-- Rebind screenshot from PRINT (no Print key on MacBook keyboard) to CTRL+4
hl.unbind("PRINT")
o.bind("CTRL + 4", "Screenshot", "omarchy-capture-screenshot")
```
MacBook keyboards have no physical Print key, so Omarchy's stock screenshot bindings (`PRINT`, plus `SUPER+PRINT` for the color picker, `ALT+PRINT` for screen recording, `SUPER CTRL+PRINT` for OCR capture) are all unreachable out of the box. This rebind deliberately mimics macOS's `Cmd+Shift+4` muscle memory. **Known gap, carried over from the previous machine**: only the plain screenshot binding was remapped — the color-picker, screen-recording, and OCR-capture bindings were never given a replacement, so those three features are currently unreachable from the keyboard. Remap those too this time if you want them; whether leaving them unreachable was ever a deliberate choice isn't recorded either.

**`~/.config/hypr/looknfeel.lua`** and **`~/.config/hypr/autostart.lua`**: leave untouched (all defaults — gaps, borders, rounding, animations, layout — nothing was customized, nothing was added to autostart).

**`~/.config/hypr/hyprsunset.conf`**: keep the Omarchy-scaffolded default (`identity = true`, no tint) — the auto-nightlight schedule Omarchy supports was deliberately left disabled.

Reload Hyprland config after editing (`hyprctl reload` or re-login).

### 5. Set up the Aether theme

The active Omarchy theme is **Aether** — not a static color scheme but a running daemon/GUI app (`/usr/bin/aether`) that generates a wallpaper-driven theme and continuously syncs it into `~/.config/omarchy/themes/<slug>`. It produces per-app theme files for ~20 targets (Hyprland, Waybar, Alacritty, Ghostty, foot, kitty, Neovim, VS Code, Zed, btop, mako, walker, wofi, zellij, Vencord, Chromium, icon theme, SwayOSD). It is not chezmoi-managed.

1. Point Aether at your wallpaper folder (`~/Wallpapers` on the previous machine, configurable via `~/.config/aether/settings.json` — recreate or `rsync` it over, or pull from a backup). Wallhaven integration is available for sourcing new wallpapers.
2. Generate/select a theme in the Aether GUI so it's picked up under `~/.config/omarchy/themes/`
3. Activate it via `omarchy-theme-set` or the Omarchy theme menu
4. **Gotcha to remember**: if you ever delete a custom theme directory, switch Aether to its default wallpaper *first* — deleting while Aether's editor is still pointed at that wallpaper just regenerates the directory (sometimes under a slightly renamed slug) on the next apply. To keep a theme intentionally rather than as a throwaway live edit, save it as a blueprint (`aether --list-blueprints` / save-as-blueprint).

### 6. Omarchy bar / idle settings

`~/.config/omarchy/shell.json` (not chezmoi-tracked) — recreate manually or restore from backup:

- Top bar, transparent background
- Layout: left = `menu`, `workspaces` · center = `indicators`, `clock`, `keyboard-layout`, `weather`, `system-update` · right = `tray`, `agents`, `bluetooth`, `network`, `audio`, `monitor`, `power`
- Idle: screen locks after 300s, screensaver kicks in at 150s

Hand-edit as JSON, or check `omarchy-menu` first in case Omarchy exposes a settings UI for it.

### 7. Fix Flatpak app visibility

**Not chezmoi-managed — do this by hand on every fresh machine.** Omarchy is started via `uwsm`, which never sources `/etc/profile.d/flatpak.sh`, so `XDG_DATA_DIRS` never picks up the Flatpak exports path. Without this fix, **no Flatpak app — installed at user or system scope — will ever appear in the launcher**, regardless of which one you install. This bit a Logseq install on the previous machine and cost a full debugging session to trace back to uwsm rather than Flatpak or the specific app.

**Background — what `XDG_DATA_DIRS` is**: it's part of the freedesktop.org XDG Base Directory spec, which standardizes where Linux apps put their files instead of every app inventing its own convention (`XDG_CONFIG_HOME` for settings, `XDG_DATA_HOME` for app data, `XDG_CACHE_HOME` for disposable cache — chezmoi's `dot_config/` maps to `XDG_CONFIG_HOME`). `XDG_DATA_DIRS` is the one relevant here: a colon-separated *search path* (like `$PATH`) that launchers walk looking for `applications/*.desktop` files. Flatpak drops its `.desktop` files into `/var/lib/flatpak/exports/share/applications` (system scope) or `~/.local/share/flatpak/exports/share/applications` (user scope) — neither of which is in `XDG_DATA_DIRS` by default. `/etc/profile.d/flatpak.sh` normally adds them, but that only runs for login shells, and uwsm doesn't start one. uwsm has its own env-loading hook instead: it sources `~/.config/uwsm/env` (and desktop-specific variants like `env-hyprland`) as plain shell scripts before Hyprland starts, which is why that file is the right place for this fix rather than `.zshrc` or similar.

1. Add the user-scope Flathub remote (Omarchy's installer only registers it system-wide, so `flatpak install --user` fails without this):
   ```bash
   flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   ```
2. Create `~/.config/uwsm/env` (uwsm's own env-loading mechanism, sourced as a real shell script at session start):
   ```sh
   export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:${HOME}/.local/share/flatpak/exports/share"
   ```
3. Apply it live without a full re-login: `systemctl --user import-environment XDG_DATA_DIRS && omarchy restart shell`

**Known gap**: this was identified as belonging in chezmoi as a `run_once_*.sh` script — it's a structural Omarchy/uwsm bug, not app-specific — but that was never implemented. It's still a manual step on every fresh machine; see the `CLAUDE.md` TODO.

### 8. Expected first-run prompts (no action needed to set these up)

All hooks under `~/.config/omarchy/hooks/` are Omarchy's own stock `post-update` scripts, not user-authored — they show up as one-time notifications, not something to configure:

| Hook | Effect |
|---|---|
| `install-voxtype.hook` | One-time notification inviting voxtype (dictation) install, gated so it only fires once (`omarchy-done ensure ...-invitation`) |
| `setup-fingerprint.hook` | One-time notification inviting fingerprint-reader setup — only fires if `omarchy-hw-fingerprint` detects a reader and it isn't already configured |
| `setup-agent.hook` | One-time notification inviting default-agent setup — only fires if no agent is already set via `omarchy-default-agent`; since `chezmoi apply` already deploys Claude Code config, this may be redundant by the time you see it |

The rest (`battery-low`, `font-set`, `post-boot` weather, `theme-set` notification, `pre-refresh-pacman` custom repo) are still the stock `.sample` files — inactive, not custom.

### 9. Verification checklist

- [ ] Caps Lock behaves as physical Caps Lock (not Compose)
- [ ] Touchpad scrolling is natural/inverted
- [ ] `Ctrl+4` takes a screenshot
- [ ] Display scale looks correct (1.6, `GDK_SCALE=2` — GTK apps not oversized/undersized)
- [ ] Ghostty opens with Catppuccin Mocha, JetBrainsMono Nerd Font, 14pt
- [ ] Neovim opens with the Aether/Omarchy-synced colorscheme, not a fallback theme
- [ ] A Flatpak app (install one, e.g. `flatpak install --user flathub com.logseq.Logseq`) shows up in the launcher without a full re-login
- [ ] `chezmoi diff` is clean (no drift between repo and deployed state)
- [ ] Backup timers active: `systemctl status btrbk.timer` (system) and `systemctl --user status restic-backup.timer`

## Reference

Background that isn't part of bring-up (nothing to do here — it works automatically once steps 1–3 above are done) but useful for troubleshooting.

### Neovim on Omarchy

Full details live in `private_dot_config/nvim/CLAUDE.md`, but the short version: the nvim config predated Omarchy and was hand-rolled. Installing Omarchy's `omarchy-nvim` package dropped unmanaged files into `~/.config/nvim` (`theme.lua`, `all-themes.lua`, `omarchy-theme-hotreload.lua`, etc.) that nvim loaded but chezmoi didn't own. Rather than deleting them, the config was migrated to adopt Omarchy's LazyVim bootstrap (`lua/config/*`) as the base, with the existing plugin files layered on top as LazyVim overrides — the standard way LazyVim expects extensions. The result:

- On Omarchy, `omarchy-theme-set` live-rewrites `lua/plugins/theme.lua` on every OS theme change (intentionally not chezmoi-tracked, since tracking it would fight the live rewrite). `all-themes.lua` and `omarchy-theme-hotreload.lua` support this by preloading theme plugins and reapplying the colorscheme + transparency on change.
- `coloscheme.lua` (a static onedark/catppuccin picker) is used only on non-Omarchy machines, gated via `.chezmoiignore`'s `.chezmoi.osRelease.id == "omarchy"` check, so it never competes with the live `theme.lua`.

### chezmoi integration points

The only two places this repo actively branches on Omarchy:

1. **`.chezmoiscripts/run_onchange_install-packages.sh.tmpl`** — detects Omarchy via `pacman -Qi omarchy` and adjusts the package list: skips `ttf-jetbrains-mono-nerd` (conflicts with Omarchy's bundled `ttf-jetbrains-mono-nerd-basic`), and replaces Omarchy's default `libreoffice-fresh` with `libreoffice-still`.
2. **`.chezmoiignore`** — excludes `private_dot_config/nvim/lua/plugins/coloscheme.lua` from deployment when running on Omarchy (see Neovim on Omarchy above).
