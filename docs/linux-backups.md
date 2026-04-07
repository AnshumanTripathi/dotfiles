# Linux Backup Configuration

This document describes the automated backup infrastructure for Arch Linux machines managed by this chezmoi repository.

## Overview

| Layer | Tool | What | Where | Frequency |
|-------|------|------|-------|-----------|
| Local snapshots | btrbk | Btrfs snapshots of `@` (root) and `@home` | `/.snapshots/` | Hourly |
| NAS backups | restic | Encrypted, deduplicated backups of `/home` | `/mnt/nas/backups/restic-<hostname>` | Daily |

Both are scheduled via systemd timers with `Persistent=true`, so missed backups (laptop was off/asleep) run on the next wake.

## Architecture

```
┌─────────────────────────────────────┐
│           Arch Linux Laptop         │
│                                     │
│  Btrfs volume (/dev/sda2)           │
│  ├── @ (root)  ──┐                  │
│  ├── @home       ├─ btrbk hourly ──→ /.snapshots/
│  └── @snapshots ─┘                  │
│                                     │
│  /home ────── restic daily ─────────┼──→ /mnt/nas/backups/restic-<hostname>
│                                     │      (CIFS over Tailscale)
└─────────────────────────────────────┘
```

### Why two tools?

- **btrbk** creates instant, space-efficient Btrfs snapshots locally. These are the fastest way to recover from accidental deletions or bad changes (seconds to restore).
- **restic** provides off-site encrypted backups to the NAS. Btrfs send/receive cannot work over CIFS, so restic handles the NAS transport with deduplication and encryption.

## Retention Policies

### btrbk (local snapshots)
| Period | Kept |
|--------|------|
| Hourly | 24 |
| Daily | 7 |
| Weekly | 4 |
| Monthly | 6 |

### restic (NAS backups)
| Period | Kept |
|--------|------|
| Hourly | 24 |
| Daily | 7 |
| Weekly | 4 |
| Monthly | 12 |
| Yearly | 2 |

## Password Management

The restic repository password is stored in **gopass** at `arch/backup/restic`.

```bash
# View the password
gopass show arch/backup/restic

# The backup script retrieves it automatically via:
export RESTIC_PASSWORD_COMMAND="gopass show -o arch/backup/restic"
```

The password is generated automatically on first `chezmoi apply` by `run_once_setup-restic.sh.tmpl`. Ensure your gopass store is synced or backed up independently (it is GPG-encrypted).

## Systemd Timers

### btrbk (system-level, runs as root)
```bash
# Status
systemctl status btrbk.timer
systemctl status btrbk.service

# Logs
journalctl -u btrbk.service -e

# Manual run
sudo btrbk run
```

### restic (user-level, runs as your user)
```bash
# Status
systemctl --user status restic-backup.timer
systemctl --user status restic-backup.service

# Logs
journalctl --user -u restic-backup.service -e
# Also: ~/.local/log/restic-backup.log

# Manual run
~/bin/restic-backup.sh
```

## Manual Operations

### Create a snapshot manually
```bash
sudo btrbk run
```

### Trigger a NAS backup manually
```bash
~/bin/restic-backup.sh
```

### List local snapshots
```bash
sudo btrbk list snapshots
ls -la /.snapshots/
```

### List restic snapshots on NAS
```bash
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) snapshots
```

### Browse files in a restic snapshot
```bash
# List files in the latest snapshot
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) ls latest

# Mount snapshots as a FUSE filesystem for browsing
mkdir -p /tmp/restic-mount
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) mount /tmp/restic-mount
# Browse at /tmp/restic-mount/snapshots/<id>/
# Ctrl+C to unmount
```

## Restoring from Backups

### Restore a file from a local Btrfs snapshot

Snapshots are read-only subvolumes at `/.snapshots/`. Browse them directly:

```bash
# List available snapshots
ls /.snapshots/

# Copy a file from a snapshot
cp /.snapshots/home.20260403T1200/anshuman/path/to/file ~/path/to/file
```

### Restore a file from restic (NAS)

```bash
# Restore a specific file from the latest snapshot
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) \
    restore latest --target /tmp/restic-restore \
    --include /home/anshuman/path/to/file

# Restore from a specific snapshot ID
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) \
    restore abc123 --target /tmp/restic-restore
```

### Restore entire home directory from restic

```bash
# Restore to a temporary location first, then copy
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) \
    restore latest --target /tmp/restic-restore \
    --include /home/anshuman
```

## Disaster Recovery

Full system recovery from scratch:

1. **Install Arch Linux** with Btrfs and the same subvolume layout (`@`, `@home`, `@snapshots`)
2. **Bootstrap chezmoi**: `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply AnshumanTripathi`
3. This installs packages (including restic and gopass), sets up configs
4. **Import your GPG key** (needed for gopass): `gpg --import <your-key>`
5. **Clone your gopass store** or restore it from your backup
6. **Restore home data**:
   ```bash
   restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
       -p <(gopass show -o arch/backup/restic) \
       restore latest --target /
   ```
7. **Restore /etc customizations** selectively from the restic backup

## Troubleshooting

### Checking if recent backups succeeded

#### Quick health check
```bash
# Are the timers active and scheduled?
systemctl status btrbk.timer                       # Should show "active (waiting)"
systemctl --user status restic-backup.timer         # Should show "active (waiting)"

# When did each timer last fire?
systemctl show btrbk.timer --property=LastTriggerUSec
systemctl --user show restic-backup.timer --property=LastTriggerUSec

# Did the last run succeed or fail?
systemctl show btrbk.service --property=ActiveState,Result
systemctl --user show restic-backup.service --property=ActiveState,Result
# Result=success means the last run completed OK
# Result=exit-code means the last run failed
```

#### Check recent btrbk history
```bash
# List snapshots — look for recent timestamps
sudo btrbk list snapshots

# If no recent snapshots, check the journal for errors
journalctl -u btrbk.service --since "7 days ago" --no-pager
```

#### Check recent restic history
```bash
# List recent restic snapshots on NAS — look for recent dates
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) snapshots --latest 5

# Check the backup log for errors or SKIP messages
tail -100 ~/.local/log/restic-backup.log

# Check systemd journal for the user service
journalctl --user -u restic-backup.service --since "7 days ago" --no-pager

# Look for SKIP entries (NAS was unreachable) vs ERROR entries (actual failures)
grep -E 'SKIP|ERROR' ~/.local/log/restic-backup.log | tail -20
```

#### Verify restic repo integrity
```bash
# Quick check (metadata only)
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) check

# Full check (reads all data — slow, use occasionally)
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) check --read-data
```

### NAS mount not triggering (automount dead)

The systemd automount unit (`mnt-nas.automount`) can go `inactive (dead)` after idle timeout. When this happens, accessing `/mnt/nas` shows an empty local directory instead of re-triggering the CIFS mount.

**Symptoms:**
- `ls /mnt/nas/` shows nothing (empty directory)
- `mountpoint /mnt/nas` says "is not a mountpoint"
- `systemctl status mnt-nas.automount` shows `inactive (dead)`
- But `ping 100.91.252.25` succeeds (NAS is reachable)

**Fix:**
```bash
# Restart the automount unit
sudo systemctl start mnt-nas.automount

# Verify it's active
systemctl status mnt-nas.automount   # Should show "active (waiting)"

# Trigger the mount
ls /mnt/nas/
```

**Why this happens:** Once systemd deactivates the automount unit after idle, it does not automatically restart on directory access. The unit must be explicitly restarted. This can happen after suspend/resume cycles or if the CIFS connection drops (e.g., Tailscale reconnecting).

**Permanent fix (if this happens frequently):** Add a systemd override to prevent the automount from going dead after idle:
```bash
sudo systemctl edit mnt-nas.automount
# Add:
# [Automount]
# TimeoutIdleSec=0
```

### NAS unreachable / Tailscale down
The backup script gracefully skips when the NAS is unreachable (exits 0 so systemd doesn't mark it failed). Check:
```bash
tailscale status          # Is Tailscale connected?
ping 100.91.252.25        # Can you reach the NAS?
mountpoint /mnt/nas       # Is the CIFS mount active?

# If Tailscale is up but NAS won't mount, restart automount (see above)
```

### Stale restic lock
If a backup was interrupted (e.g., laptop suspended mid-backup), restic may leave a stale lock:
```bash
restic -r /mnt/nas/backups/restic-$(cat /etc/hostname) \
    -p <(gopass show -o arch/backup/restic) unlock
```

### btrbk snapshot failures
```bash
# Check btrbk can parse its config
sudo btrbk list config

# Dry run to see what it would do
sudo btrbk dryrun

# Check if /.snapshots is mounted
mountpoint /.snapshots
```

### Disk space issues
```bash
# Check Btrfs usage
sudo btrfs filesystem usage /

# List snapshot sizes
sudo btrbk list snapshots

# Force cleanup of old snapshots
sudo btrbk prune

# Check restic repo size on NAS
du -sh /mnt/nas/backups/restic-$(cat /etc/hostname)
```

### Logs
```bash
# btrbk
journalctl -u btrbk.service --since today

# restic (systemd journal)
journalctl --user -u restic-backup.service --since today

# restic (script log)
tail -50 ~/.local/log/restic-backup.log
```

## Files Managed by Chezmoi

| Chezmoi Source | Target | Purpose |
|---------------|--------|---------|
| `.chezmoidata/packages.yaml` | (pacman install) | btrbk + restic packages |
| `bin/executable_restic-backup.sh` | `~/bin/restic-backup.sh` | Restic backup wrapper script |
| `.chezmoiscripts/run_once_setup-restic.sh.tmpl` | (runs once) | Generate restic password in gopass |
| `.chezmoiscripts/run_onchange_after_setup-backups.sh.tmpl` | (runs on change) | Install btrbk config + systemd units |

## What Is Excluded from Restic Backups

The backup script excludes reproducible and large ephemeral data:
- Package caches: `.npm`, `.cargo/registry`, `.gradle/caches`, `.m2/repository`
- Installed runtimes: `.asdf/installs`, `.pyenv/versions`, `.rustup/toolchains`
- Build artifacts: `build/`, `dist/`, `target/`, `__pycache__/`, `.venv/`
- IDE extensions: `.vscode/extensions`
- Containers/VMs: `.docker`, `.vagrant.d/boxes`, containers
- General caches: `.cache`, `Trash`, `Downloads`
- Chezmoi externals: `.oh-my-zsh`, `.vim/plugged` (pulled from `.chezmoiexternal.toml`)
