# Dotfiles

[Chezmoi](https://www.chezmoi.io/)-managed dotfiles for shell, git, editor, and package setup across two profiles (**personal** / **work**) and two platforms (**macOS** / **Arch Linux**). Secrets are GPG-encrypted.

## First-Time Setup

### Prerequisites

- **macOS**: Xcode CLI tools (`xcode-select --install`) and [Homebrew](https://brew.sh/)
- **Arch Linux**: Base install with `git` and `curl`
- **GPG key** (for encrypted secrets): import your key before applying

### Bootstrap

```bash
# Install chezmoi and apply in one step
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply AnshumanTripathi
```

Chezmoi will prompt for configuration choices:

| Prompt | Options | Effect |
|--------|---------|--------|
| Email address | any | Used in git config |
| Use Ghostty | yes/no | Installs Ghostty terminal + font config |
| Terminal font size | integer | Ghostty font size (if enabled) |
| Profile | `personal` / `work` | Controls which packages and config blocks are included |
| Use starship prompt | yes/no | Enables [Starship](https://starship.rs/) instead of Powerlevel10k |
| GPG signing key | yes/no + key ID | Configures git commit signing |
| AI coding agent | `windsurf` / `claude-code` | Deploys agent-specific settings |

Answers are stored in `~/.config/chezmoi/chezmoi.toml` and reused on subsequent `chezmoi apply` runs.

### What Happens on First Apply

1. `~/bin/` directory is created
2. Private dotfile stubs (`~/.zsh/private.zsh`, `~/.npm-global`) are set up
3. VS Code is installed (brew on macOS, pacman on Arch)
4. All packages from `packages.yaml` are installed
5. Python is set up via pyenv
6. Vim plugins are installed via vim-plug
7. **Linux only**: Backup infrastructure (btrbk + restic) is configured, GNOME touchpad settings are applied

## Architecture

### Profile & OS System

Two profiles (`personal` / `work`) chosen at init time, two platforms (`darwin` / `linux`) detected via `.chezmoi.os`. These drive conditional blocks in `.tmpl` files and determine which packages get installed.

Config template: [.chezmoi.toml.tmpl](.chezmoi.toml.tmpl) -- key variables: `.chezmoi.os`, `.profile`, `.email`, `.useGhostty`, `.useStarshipPrompt`, `.haveSigningKey`, `.signingKey`, `.useAIAgent`, `.aiAgent`.

### Package Management

Packages are declared in [.chezmoidata/packages.yaml](.chezmoidata/packages.yaml) keyed by package manager, each with three tiers:

- **`brew`** (macOS) -- `core`, `shared`, `profiles.personal`, `profiles.work` with formulae/taps/casks
- **`pacman`** (Arch Linux) -- `core`, `shared`, `profiles.personal`, `profiles.work` with packages/aur lists
- **`common`** (cross-platform) -- `core`, `shared`, `profiles` with asdf plugins, npm globals, and wget binaries (OS-keyed under `wgets.darwin` / `wgets.linux`)

Installation is handled by [run_onchange_install-packages.sh.tmpl](.chezmoiscripts/run_onchange_install-packages.sh.tmpl), which re-runs when `packages.yaml` changes (sha256 hash trigger). On Arch, `yay` is auto-bootstrapped if not present.

To add another distro (e.g., Ubuntu): add a new top-level key (e.g., `apt`) in `packages.yaml` and corresponding conditionals in the install script.

### Script Execution Order

Scripts in [.chezmoiscripts/](.chezmoiscripts/) follow chezmoi naming conventions:

| Prefix | Timing | Examples |
|--------|--------|----------|
| `run_before_*` | Before file changes | Create `~/bin/` directory |
| `run_once_*` | Once ever | VS Code install, private dotfile setup, restic password generation |
| `run_onchange_*` | When tracked content changes | Package install, vim plugins, Python setup, backup infra, GNOME settings |
| `run_onchange_after_*` | After other `run_onchange` scripts | Backup systemd timers |

### External Dependencies

[.chezmoiexternal.toml](.chezmoiexternal.toml) pulls from GitHub with a 168h refresh:
- vim-plug
- Powerlevel10k (zsh theme)
- zsh-autosuggestions
- zsh-syntax-highlighting

### Naming Conventions

Chezmoi file prefixes map to target paths: `dot_` = `.`, `private_dot_config/` = `.config/` (restricted permissions), `.tmpl` suffix = Go template. Files without `.tmpl` are copied verbatim.

### Backup Infrastructure (Linux)

Two-layer backup strategy for Arch Linux with Btrfs:

- **btrbk**: Hourly local Btrfs snapshots of root and home to `/.snapshots/` via systemd system timer
- **restic**: Daily encrypted, deduplicated backups to NAS (`/mnt/nas/backups/restic-<hostname>`) over Tailscale CIFS via systemd user timer

Restic password is auto-generated in gopass (`arch/backup/restic`) on first apply. Both timers use `Persistent=true` so missed runs fire on next wake.

See [docs/linux-backups.md](docs/linux-backups.md) for retention policies, restore procedures, disaster recovery, and troubleshooting.

### GNOME Touchpad Fix (Linux)

Tap-to-click is disabled via `gsettings` to prevent accidental input focus shifts while typing. The built-in disable-while-typing has gaps between keystrokes that still allow stray taps.

## Key Commands

```bash
chezmoi apply                    # Apply dotfiles to home directory
chezmoi apply --dry-run          # Preview what would change
chezmoi diff                     # Show diff between source and target
chezmoi edit <file>              # Edit a managed file (opens in VS Code)
chezmoi add <file>               # Add a new file to management
chezmoi data                     # Show template data values
chezmoi execute-template < file  # Test template rendering
```

## Modifying

- **Add a package**: edit [.chezmoidata/packages.yaml](.chezmoidata/packages.yaml) under the appropriate manager key and tier
- **Add shell config**: edit [dot_zshrc.tmpl](dot_zshrc.tmpl), wrap profile-specific blocks in `{{- if eq .profile "work" }}` and OS-specific blocks in `{{- if eq .chezmoi.os "darwin" }}`
- **Add a managed config file**: use `chezmoi add` or create with correct chezmoi naming prefixes
- **Template syntax**: Go text/template; test with `chezmoi execute-template`
