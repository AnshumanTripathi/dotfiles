# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A [chezmoi](https://www.chezmoi.io/) dotfiles repository managing shell config, git config, editor setup, and package installations across two profiles: **personal** and **work**. Uses GPG encryption for secrets.

## Key Commands

```bash
chezmoi apply                    # Apply dotfiles to home directory
chezmoi apply --dry-run          # Preview what would change
chezmoi diff                     # Show diff between source and target
chezmoi edit <file>              # Edit a managed file (opens in VS Code)
chezmoi add <file>               # Add a new file to management
chezmoi data                     # Show template data values (profile, email, flags)
chezmoi execute-template < file  # Test template rendering
```

## Architecture

### Profile System
The repo supports two profiles (`personal` / `work`) chosen during `chezmoi init`. Profile selection drives conditional blocks throughout templates (`.tmpl` files) and determines which packages get installed. Template data is configured in [.chezmoi.toml.tmpl](.chezmoi.toml.tmpl) via interactive prompts and stored in `~/.config/chezmoi/chezmoi.toml`.

Key template variables: `.profile`, `.email`, `.useGhostty`, `.useStarshipPrompt`, `.haveSigningKey`, `.signingKey`.

### Package Management
Packages are declared in [.chezmoidata/packages.yaml](.chezmoidata/packages.yaml) with three tiers:
- **core** - Installed on all machines (asdf, nodejs)
- **shared** - Common tools across profiles (kubectl, helm, fzf, bat, starship, etc.)
- **profiles.personal / profiles.work** - Profile-specific packages

Installation is handled by [.chezmoiscripts/run_onchange_install-packages.sh.tmpl](.chezmoiscripts/run_onchange_install-packages.sh.tmpl), which re-runs when packages.yaml changes (sha256 hash in comment). Package sources: Homebrew (formulae/casks/taps), wget (binaries to `~/bin/`), npm globals, and asdf plugins.

### Script Execution Order
Chezmoi scripts in [.chezmoiscripts/](.chezmoiscripts/) follow naming conventions that control timing:
- `run_before_*` - Runs before file changes (e.g., create `~/bin/` directory)
- `run_once_*` - Runs once ever (e.g., VS Code install, private dotfile setup)
- `run_onchange_*` - Runs when tracked content changes (e.g., packages, vim plugins, python setup)

### External Dependencies
[.chezmoiexternal.toml](.chezmoiexternal.toml) pulls vim-plug, powerlevel10k, zsh-autosuggestions, and zsh-syntax-highlighting from GitHub with a 168h refresh period.

### Naming Conventions
Chezmoi file prefixes map to target paths: `dot_` = `.`, `private_dot_config/` = `.config/` (with restricted permissions), `.tmpl` suffix = Go template. Files without `.tmpl` are copied verbatim.

## When Modifying

- To add a package: edit [.chezmoidata/packages.yaml](.chezmoidata/packages.yaml) under the appropriate tier/profile
- To add shell config: edit [dot_zshrc.tmpl](dot_zshrc.tmpl), wrapping profile-specific blocks in `{{- if eq .profile "work" }}` / `{{- end }}`
- To add a new managed config file: use `chezmoi add` or manually create with correct chezmoi naming prefixes
- Template syntax is Go text/template; use `chezmoi execute-template` to test before applying
