# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Agent Config Sync

This repo is used with both Claude Code and Windsurf. Their project instruction files and skills must stay in sync:
- **CLAUDE.md** <-> **.windsurfrules**: When modifying project instructions in either file, replicate the change to the other.
- **.claude/skills/** <-> **.windsurf/skills/**: When adding, modifying, or removing a skill in either directory, replicate the change to the other. Adapt frontmatter fields to match each tool's format.

## What This Is

See [README.md](README.md) for full architecture, first-time setup, and backup documentation.

A chezmoi dotfiles repo managing two profiles (**personal** / **work**) on two platforms (**macOS** / **Arch Linux**) with GPG-encrypted secrets.

## Key Commands

```bash
chezmoi apply                    # Apply dotfiles to home directory
chezmoi apply --dry-run          # Preview what would change
chezmoi diff                     # Show diff between source and target
chezmoi data                     # Show template data values (profile, email, flags)
chezmoi execute-template < file  # Test template rendering
```

## When Modifying

- To add a package: edit [.chezmoidata/packages.yaml](.chezmoidata/packages.yaml) under the appropriate package manager key (`brew`/`pacman`) and tier. For cross-platform tools (asdf, npm, wget), add under `common`
- To add shell config: edit [dot_zshrc.tmpl](dot_zshrc.tmpl), wrapping profile-specific blocks in `{{- if eq .profile "work" }}` / `{{- end }}` and OS-specific blocks in `{{- if eq .chezmoi.os "darwin" }}` / `{{- end }}`
- To add a new managed config file: use `chezmoi add` or manually create with correct chezmoi naming prefixes
- Template syntax is Go text/template; use `chezmoi execute-template` to test before applying
- Backup infrastructure (btrbk + restic) and GNOME settings scripts are Linux-only (guarded by `{{ if eq .chezmoi.os "linux" }}`)
- Backup docs are in [docs/linux-backups.md](docs/linux-backups.md)

## Key Files

| File | Purpose |
|------|---------|
| [.chezmoi.toml.tmpl](.chezmoi.toml.tmpl) | Interactive config prompts, template variables |
| [.chezmoidata/packages.yaml](.chezmoidata/packages.yaml) | All packages by manager/tier |
| [.chezmoiexternal.toml](.chezmoiexternal.toml) | External deps (vim-plug, p10k, zsh plugins) |
| [.chezmoiscripts/](.chezmoiscripts/) | Install/setup scripts (`run_before_*`, `run_once_*`, `run_onchange_*`) |
| [bin/](.chezmoiscripts/) | User scripts deployed to `~/bin/` |
| [docs/linux-backups.md](docs/linux-backups.md) | Backup architecture, restore, troubleshooting |

## Naming Conventions

Chezmoi file prefixes: `dot_` = `.`, `private_dot_config/` = `.config/` (restricted permissions), `.tmpl` = Go template.
