#!/bin/bash
# Quick sync script to deploy changes to Unraid Home Assistant.
#
# Syncs only the repo-managed config into the live HA appdata. Fully
# repo-managed dirs are synced with --delete so renames/deletions
# PROPAGATE (a file removed from the repo is removed from the live box);
# blueprints/themes are synced without --delete (HACS/UI may add content),
# and root runtime files (secrets.yaml, .storage, custom_components, DBs,
# logs) are never touched.
#
# Pass --dry-run to preview (including what --delete would remove).

set -euo pipefail

UNRAID_PATH="/mnt/unraid/appdata/Home-Assistant-Container"
LOCAL_PATH="/home/tori/Home-Assistant/home-assistant"

# Fully repo-managed dirs — safe to prune stale files with --delete.
PRUNE_DIRS=(automations scripts scenes integrations entities customizations dashboards assistants)
# Dirs synced WITHOUT --delete (HACS/UI may add content HA manages).
KEEP_DIRS=(blueprints themes)
# Root config files that are repo-managed (copied individually, never pruned).
ROOT_FILES=(configuration.yaml customize.yaml scenes.yaml scripts.yaml ui-lovelace.yaml)

RSYNC_OPTS=(-av --exclude='*.pyc' --exclude='__pycache__')
for arg in "$@"; do
  case "$arg" in
    --dry-run) RSYNC_OPTS+=(--dry-run --itemize-changes) ;;
    -h|--help) echo "Usage: $0 [--dry-run]"; exit 0 ;;
    *) echo "Unknown arg: $arg"; echo "Usage: $0 [--dry-run]"; exit 1 ;;
  esac
done

echo "🔄 Syncing Home Assistant config to Unraid..."

# Root config files (no --delete; protects secrets.yaml, known_devices.yaml, etc.)
for f in "${ROOT_FILES[@]}"; do
  [[ -f "$LOCAL_PATH/$f" ]] && rsync "${RSYNC_OPTS[@]}" "$LOCAL_PATH/$f" "$UNRAID_PATH/$f"
done

# Repo-managed dirs WITH --delete (renames/deletions propagate).
for d in "${PRUNE_DIRS[@]}"; do
  [[ -d "$LOCAL_PATH/$d" ]] && rsync "${RSYNC_OPTS[@]}" --delete "$LOCAL_PATH/$d/" "$UNRAID_PATH/$d/"
done

# HACS/UI-shared dirs WITHOUT --delete.
for d in "${KEEP_DIRS[@]}"; do
  [[ -d "$LOCAL_PATH/$d" ]] && rsync "${RSYNC_OPTS[@]}" "$LOCAL_PATH/$d/" "$UNRAID_PATH/$d/"
done

echo "✅ Sync complete!"
echo "💡 Restart Home Assistant (or Reload from Developer Tools → YAML) to apply changes"
