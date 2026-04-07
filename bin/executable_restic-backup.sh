#!/bin/bash
set -euo pipefail

# ── Configuration ──
RESTIC_REPOSITORY="/mnt/nas/backups/restic-$(cat /etc/hostname)"
NAS_IP="100.91.252.25"
NAS_MOUNT="/mnt/nas"
LOG_FILE="$HOME/.local/log/restic-backup.log"
LOCK_FILE="/tmp/restic-backup.lock"

export RESTIC_REPOSITORY
export RESTIC_PASSWORD_COMMAND="gopass show -o arch/backup/restic"

# ── Logging ──
log() {
    local msg="$(date -Is) $*"
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$msg" | tee -a "$LOG_FILE"
}

# ── Prevent concurrent runs ──
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    log "ERROR: Another restic backup is already running"
    exit 1
fi

# ── Pre-flight checks ──

# Verify gopass can retrieve the password
if ! gopass show -o arch/backup/restic &>/dev/null; then
    log "ERROR: Cannot retrieve restic password from gopass (arch/backup/restic)"
    exit 1
fi

# Check Tailscale
if ! tailscale status &>/dev/null; then
    log "SKIP: Tailscale is not running"
    exit 0
fi

# Check NAS reachability
if ! ping -c 1 -W 5 "$NAS_IP" &>/dev/null; then
    log "SKIP: NAS unreachable at $NAS_IP"
    exit 0
fi

# Trigger automount if needed
if ! mountpoint -q "$NAS_MOUNT"; then
    ls "$NAS_MOUNT/" &>/dev/null 2>&1 || true
    sleep 2
    if ! mountpoint -q "$NAS_MOUNT"; then
        log "SKIP: $NAS_MOUNT not mounted and automount failed"
        exit 0
    fi
fi

# ── Initialize repo if needed ──
if ! restic snapshots &>/dev/null 2>&1; then
    log "Initializing restic repository at $RESTIC_REPOSITORY"
    restic init
fi

# ── Backup ──
log "Starting restic backup"

restic backup \
    /home \
    --exclude-caches \
    --exclude '/home/*/.cache' \
    --exclude '/home/*/.local/share/Trash' \
    --exclude '/home/*/.local/share/containers' \
    --exclude '/home/*/.local/share/Steam' \
    --exclude '/home/*/.local/share/bazel' \
    --exclude '/home/*/.local/share/chezmoi/.git' \
    --exclude '/home/*/node_modules' \
    --exclude '/home/*/.npm' \
    --exclude '/home/*/.cargo/registry' \
    --exclude '/home/*/.cargo/git' \
    --exclude '/home/*/.rustup/toolchains' \
    --exclude '/home/*/.gradle/caches' \
    --exclude '/home/*/.m2/repository' \
    --exclude '/home/*/.vagrant.d/boxes' \
    --exclude '/home/*/.docker' \
    --exclude '/home/*/go/pkg' \
    --exclude '/home/*/.asdf/installs' \
    --exclude '/home/*/.asdf/downloads' \
    --exclude '/home/*/.oh-my-zsh' \
    --exclude '/home/*/.vim/plugged' \
    --exclude '/home/*/.vscode/extensions' \
    --exclude '/home/*/Downloads' \
    --exclude '/home/*/.pyenv/versions' \
    --exclude '/home/**/__pycache__' \
    --exclude '/home/**/.venv' \
    --exclude '/home/**/venv' \
    --exclude '/home/**/.tox' \
    --exclude '/home/**/.mypy_cache' \
    --exclude '/home/**/.pytest_cache' \
    --exclude '/home/**/target' \
    --exclude '/home/**/build' \
    --exclude '/home/**/dist' \
    --one-file-system \
    2>&1 | while IFS= read -r line; do log "$line"; done

# ── Retention ──
log "Pruning old snapshots"

restic forget \
    --keep-hourly 24 \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    --keep-yearly 2 \
    --prune \
    2>&1 | while IFS= read -r line; do log "$line"; done

log "Backup completed successfully"
