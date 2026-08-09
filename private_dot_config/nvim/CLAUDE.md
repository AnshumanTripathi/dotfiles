# Neovim Configuration

## Context for the AI

The user is a **novice vim user** who built this config through internet searches and AI assistance. When something goes wrong or the user asks a question, **explain from the ground up** — assume no vim muscle memory or deep understanding of how Neovim works internally — unless the user explicitly says they already understand a concept.

---

## How Neovim is managed (chezmoi)

This config lives at `~/.config/nvim/` on the machine, but the **source of truth is the chezmoi dotfiles repo** at `~/.local/share/chezmoi/private_dot_config/nvim/`.

- `private_dot_config/` in chezmoi maps to `~/.config/` on disk
- The `private_` prefix means chezmoi sets restricted permissions (700) on the directory
- To edit config: edit files in the chezmoi repo, then run `chezmoi apply` to deploy them

Key chezmoi commands:
```bash
chezmoi apply              # Deploy changes from repo → ~/.config/nvim
chezmoi diff               # Preview what would change before applying
chezmoi edit ~/.config/nvim/init.lua   # Edit source and apply in one step
```

**Never edit `~/.config/nvim/` directly** — changes will be overwritten by the next `chezmoi apply`.

---

## Config structure

```
private_dot_config/nvim/
├── init.lua                  # Entry point: bootstraps lazy.nvim, loads core + plugins
├── lazy-lock.json            # Plugin version lockfile (auto-managed by lazy.nvim)
├── lua/
│   ├── core/
│   │   ├── options.lua       # Basic editor settings (line numbers, indentation, etc.)
│   │   ├── keymaps.lua       # Global keybindings + terminal toggle logic
│   │   └── autocmds.lua      # Automatic behaviors (autosave, neo-tree on startup, etc.)
│   └── plugins/              # One file per plugin; lazy.nvim loads all of them
│       ├── coloscheme.lua    # Catppuccin Mocha theme
│       ├── lualine.lua       # Status bar at the bottom
│       ├── bufferline.lua    # Tab-like buffer tabs at the top
│       ├── neo-tree.lua      # File explorer sidebar
│       ├── telescope.lua     # Fuzzy finder (files, grep, buffers)
│       ├── treesitter.lua    # Syntax highlighting
│       ├── lsp.lua           # Language intelligence (go-to-def, hover docs, errors)
│       ├── completion.lua    # Autocomplete popup (nvim-cmp + LuaSnip)
│       ├── gitsigns.lua      # Git change indicators in the gutter
│       ├── gitlinker.lua     # Open current line in GitLab/GitHub in browser
│       ├── lazygit.lua       # LazyGit TUI inside Neovim
│       └── terminal.lua      # (if present) terminal configuration
```

---

## Plugin manager: lazy.nvim

`lazy.nvim` is bootstrapped automatically in `init.lua` — it clones itself from GitHub on first run if missing. It then loads every file under `lua/plugins/` as a plugin spec.

Each plugin file returns a Lua table describing: which plugin to install (GitHub slug), when to load it (`lazy = false` = always, `event = ...` = on demand), its options, and its keymaps.

To manage plugins inside Neovim: run `:Lazy` to open the plugin manager UI.

---

## Core settings (`lua/core/options.lua`)

| Setting | Value | What it means |
|---|---|---|
| Leader key | `Space` | Prefix key for most custom shortcuts |
| Line numbers | absolute + relative | Shows current line number; others show distance for quick jumps |
| Indentation | 2 spaces | Tabs expand to spaces |
| Clipboard | system | Yank/paste shares with the OS clipboard |
| Splits | below / right | New panes open in a natural reading direction |
| Wrap | off | Long lines don't wrap visually |

---

## Keybindings quick reference

**Leader key = Space**

### Navigation
| Key | Action |
|---|---|
| `Ctrl+h/l/j/k` | Move between panes (left/right/down/up) |
| `Ctrl+j` | Toggle terminal panel (25% height at bottom) |
| `Tab` / `Shift+Tab` | Cycle between open buffers |

### File explorer (Neo-tree)
| Key | Action |
|---|---|
| `Space e` | Toggle file explorer sidebar |
| `Space r` | Focus file explorer |

### Fuzzy finder (Telescope)
| Key | Action |
|---|---|
| `Space ff` | Find files |
| `Space fg` | Live grep (search text in files) |
| `Space fb` | List open buffers |
| `Space fh` | Search help docs |
| `Space fr` | Recent files |

### LSP (language intelligence, active when a language server is attached)
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover docs / type info |
| `Space rn` | Rename symbol |
| `Space ca` | Code actions |
| `Space d` | Show diagnostics (errors/warnings) for current line |
| `[d` / `]d` | Jump to previous / next diagnostic |

### Git
| Key | Action |
|---|---|
| `Space lg` | Open LazyGit |
| `Space gy` | Open current line in browser (GitLab/GitHub) |
| `Space gb` | Toggle inline git blame |
| `Space gp` | Preview git hunk (change) |
| `Space gr` | Reset hunk |
| `Space gs` | Stage hunk |
| `]h` / `[h` | Next / previous git hunk |

### Buffers
| Key | Action |
|---|---|
| `Space bd` | Close current buffer |

### Completion popup
| Key | Action |
|---|---|
| `Tab` / `Shift+Tab` | Next / previous suggestion |
| `Enter` | Confirm selection |
| `Ctrl+Space` | Manually trigger completion |
| `Ctrl+e` | Dismiss popup |

---

## Automatic behaviors (`lua/core/autocmds.lua`)

- **Autosave**: file is saved automatically when leaving insert mode or after a text change. No need to `:w`.
- **Auto-reload**: if a file changes on disk (e.g., git checkout), Neovim reloads it.
- **Neo-tree on startup**: when opening Neovim with no file or with a directory, the file explorer opens automatically.
- **Terminal starts in insert mode**: opening a terminal buffer drops you straight into it.

---

## Language servers (LSP + Mason)

`mason.nvim` is an in-editor package manager for language servers. It auto-installs:
- `lua_ls` — Lua (for editing this config itself)
- `ts_ls` — TypeScript / JavaScript
- `gopls` — Go

To add more: open Neovim, run `:Mason`, find the server, press `i` to install. To also auto-install it on every machine, add its name to the `ensure_installed` list in `lua/plugins/lsp.lua`.

---

## Theme

Catppuccin **Mocha** (dark). Integrated with Treesitter, Telescope, Mason, and nvim-cmp so colors are consistent across the UI.

To change flavour: edit `flavour` in `lua/plugins/coloscheme.lua`. Options: `latte` (light), `frappe`, `macchiato`, `mocha`.

---

## Known quirks / intentional decisions

- `markdown` Treesitter injections are disabled (`lua/plugins/treesitter.lua`) — workaround for a Neovim 0.12.4 crash with embedded code fences.
- `netrw` (Neovim's built-in file browser) is disabled in `init.lua` — Neo-tree replaces it entirely.
- Neo-tree shows dotfiles and gitignored files (just dimmed), not hidden — intentional for dotfiles editing.
- `gitlinker` is configured for `gitlab.corp.zscaler.com` in addition to standard GitHub — work-specific.
