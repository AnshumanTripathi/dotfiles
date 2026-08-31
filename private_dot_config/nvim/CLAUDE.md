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

This is Omarchy's own LazyVim-based nvim config (seeded by the `omarchy-nvim` pacman
package) used as the base, with the user's plugins/keymaps/options layered on top the way
LazyVim expects extensions to be layered — **not** a from-scratch config. `lua/config/*`
are LazyVim's designated override points; `lua/plugins/*.lua` are plain lazy.nvim specs,
merged with LazyVim's own plugins of the same name/url.

```
private_dot_config/nvim/
├── init.lua                  # Entry point: require("config.lazy")
├── lazyvim.json               # LazyVim's extras-enabled tracking file (auto-updated by :LazyExtras)
├── lazy-lock.json             # Plugin version lockfile (auto-managed by lazy.nvim)
├── lua/
│   ├── config/
│   │   ├── lazy.lua           # Bootstraps lazy.nvim + LazyVim, imports lua/plugins/
│   │   ├── options.lua        # User option overrides (LazyVim already defaults most editor settings)
│   │   ├── keymaps.lua        # User keybindings, loaded after LazyVim's own defaults (so these win)
│   │   ├── autocmds.lua       # User autocmds (autosave, neo-tree on startup, etc.)
│   │   └── remote_clipboard.lua # Omarchy: OSC52 clipboard over SSH/tmux
│   └── plugins/                # One file per plugin spec; lazy.nvim loads all of them
│       ├── coloscheme.lua      # Static onedark/catppuccin theme -- NON-OMARCHY MACHINES ONLY,
│       │                       # see "Theming" below. Excluded via .chezmoiignore on Omarchy.
│       ├── theme.lua           # Omarchy-owned, NOT chezmoi-tracked -- see "Theming" below
│       ├── all-themes.lua      # Omarchy: preloads all theme plugins for hot-reload
│       ├── omarchy-theme-hotreload.lua # Omarchy: reapplies colorscheme on OS theme change
│       ├── disable-news-alert.lua      # Omarchy: silences the LazyVim/Neovim news popup
│       ├── snacks-animated-scrolling-off.lua # Omarchy: disables snacks.nvim scroll animation
│       ├── lualine.lua        # Status bar at the bottom
│       ├── bufferline.lua     # Tab-like buffer tabs at the top
│       ├── neo-tree.lua       # File explorer sidebar
│       ├── telescope.lua      # Fuzzy finder (files, grep, buffers)
│       ├── treesitter.lua     # Syntax highlighting
│       ├── lsp.lua            # Language intelligence (go-to-def, hover docs, errors)
│       ├── completion.lua     # Autocomplete popup (nvim-cmp + LuaSnip)
│       ├── gitsigns.lua       # Git change indicators in the gutter
│       ├── gitlinker.lua.tmpl # Open current line in GitLab/GitHub in browser (work profile adds internal GitLab host)
│       ├── git-conflict.lua   # Merge conflict highlighting/navigation
│       ├── lazygit.lua        # LazyGit TUI inside Neovim
│       ├── visual-multi.lua   # Multi-cursor editing
│       └── terminal.lua       # toggleterm.nvim
└── plugin/after/transparency.lua # Omarchy: transparent highlight groups, re-sourced on theme reload
```

---

## Plugin manager: lazy.nvim + LazyVim

`lazy.nvim` is bootstrapped in `lua/config/lazy.lua`, which also imports LazyVim itself
(`lazyvim.plugins`) before importing this repo's own `lua/plugins/`. That import order
matters — LazyVim's own sanity check warns if LazyVim's imports don't come before user
plugins. Every file under `lua/plugins/` is loaded automatically as an additional plugin
spec; a spec with the same plugin name/url as one of LazyVim's own merges into it (options
and keys combine) rather than installing twice.

Each plugin file returns a Lua table describing: which plugin to install (GitHub slug), when to load it (`lazy = false` = always, `event = ...` = on demand), its options, and its keymaps.

To manage plugins inside Neovim: run `:Lazy` to open the plugin manager UI. Run `:LazyExtras` to browse/enable LazyVim's bundled language/tool extras (tracked in `lazyvim.json`).

---

## Theming

Two theming mechanisms exist, gated so only one is ever active on a given machine:

- **On Omarchy** (detected via `.chezmoi.osRelease.id == "omarchy"` in `.chezmoiignore`):
  Omarchy's own `omarchy-theme-set` script rewrites `lua/plugins/theme.lua` live, every
  time the OS theme is changed, setting LazyVim's `opts.colorscheme` to match. This file is
  **intentionally not chezmoi-tracked** — tracking it would fight the live rewrite on every
  `chezmoi apply`. `all-themes.lua` and `omarchy-theme-hotreload.lua` support this
  mechanism (preloading theme plugins, reapplying the colorscheme + transparency on
  change). `coloscheme.lua` is excluded from deployment here via `.chezmoiignore` so it
  can't compete with `theme.lua` for the same LazyVim option.
- **Everywhere else** (macOS, plain Arch, etc.): `coloscheme.lua` is the only colorscheme
  source, toggled via `vim.g.active_theme` in `lua/config/options.lua` (`"onedark"` or
  `"catppuccin"`).

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

### Editing
| Key | Action |
|---|---|
| `Space /` | Toggle comment on line / selection (normal + visual) |

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
