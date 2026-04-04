# Screenshots on GNOME Wayland

## Why common tools don't work

GNOME 46+ enforces that only an app with a **focused, visible window** can request a screenshot. Tools like flameshot and ksnip run as background processes with no window, so GNOME blocks them.

There are two screenshot systems on GNOME:

| System | What it is | Status |
|--------|-----------|--------|
| `org.gnome.Shell.Screenshot` | Old direct D-Bus API | Locked down in GNOME 46+ — only GNOME's own tools allowed |
| `org.freedesktop.portal.Screenshot` | XDG portal (middleman service) | Works — GNOME does the capture and returns the file |

The portal approach works because the app doesn't capture the screen itself — it asks GNOME to do it via `xdg-desktop-portal`, then receives the saved file path back.

## Setup

### Script

`~/bin/screenshot` (managed by chezmoi at `bin/executable_screenshot`) calls the XDG portal, waits for GNOME's screenshot UI to complete, then opens the result in ksnip for annotation.

Dependencies: `python-dbus`, `python-gobject`, `ksnip` (all in pacman).

### Keyboard shortcut

Managed automatically by chezmoi via `.chezmoiscripts/run_onchange_setup-gnome-settings.sh.tmpl` (personal profile + Linux + GNOME only). Applies on `chezmoi apply`.

| Field | Value |
|-------|-------|
| Name | Screenshot |
| Command | `/home/anshuman/bin/screenshot` |
| Shortcut | `Shift+Ctrl+4` |

To set manually: Settings → Keyboard → Keyboard Shortcuts → View and Customize Shortcuts → Custom Shortcuts → **+**

### Workflow

1. Press the shortcut → GNOME's native screenshot UI appears
2. Select capture mode (area / window / full screen) and confirm
3. ksnip opens the saved image for annotation
4. Annotate, then save or copy to clipboard from ksnip

## Packages

- `ksnip` — annotation tool (pacman, personal profile)
- `python-dbus` and `python-gobject` — system packages, already present
