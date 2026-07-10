#!/usr/bin/env bash
# Home Assistant config deploy script — runs on the Unraid box.
# Usage: from the repo root on Unraid, run ./deploy.sh [--restart] [--dry-run]
#
# What it does:
#   1. Refuses to deploy if the working tree is dirty
#   2. git pull --ff-only on the current branch
#   3. rsyncs allowed config into the live HA appdata. Fully repo-managed
#      dirs are synced with --delete so renames/deletions PROPAGATE (a
#      file removed from the repo is removed from the live instance).
#   4. Optional: restarts the Home Assistant container with --restart
#
# Safety model:
#   PRUNE_DIRS  - pure repo-managed; HA never writes runtime files here, so
#                 --delete is safe and desirable (fixes stale/ghost files).
#   KEEP_DIRS   - synced WITHOUT --delete because HACS/UI may add content
#                 HA manages (imported blueprints, HACS themes).
#   ROOT_FILES  - repo-managed root config, copied individually and NEVER
#                 pruned, so target-only runtime files (secrets.yaml,
#                 known_devices.yaml, ip_bans.yaml, .storage, custom_components,
#                 databases, logs) are never touched.
#
# Tip: run once with --dry-run after a rename/delete to see exactly what
# --delete would remove before doing it for real.

set -euo pipefail

# ----- config — adjust if you renamed things -----
HA_DIR="/mnt/user/appdata/Home-Assistant-Container"
CONTAINER_NAME_FILTER="Home-Assistant"  # passed to: docker ps --filter name=...
# --------------------------------------------------

# Fully repo-managed dirs — safe to prune stale files with --delete.
PRUNE_DIRS=(automations scripts scenes integrations entities customizations dashboards assistants)
# Dirs synced WITHOUT --delete (HACS/UI may add content HA manages).
KEEP_DIRS=(blueprints themes)
# Root config files that are repo-managed (deployed individually, never pruned).
ROOT_FILES=(configuration.yaml customize.yaml scenes.yaml scripts.yaml ui-lovelace.yaml)

RESTART=false
DRYRUN=false
for arg in "$@"; do
  case "$arg" in
    --restart) RESTART=true ;;
    --dry-run) DRYRUN=true ;;
    -h|--help)
      echo "Usage: $0 [--restart] [--dry-run]"
      echo "  --restart  Restart the HA container after deploying"
      echo "  --dry-run  Show what would change (incl. --delete) without writing"
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; echo "Usage: $0 [--restart] [--dry-run]"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Home Assistant config deploy ==="
echo "Repo:    $SCRIPT_DIR"
echo "Target:  $HA_DIR"
echo "Restart: $RESTART"
echo "Dry-run: $DRYRUN"
echo

# ----- 1. Refuse if dirty -----
if [[ -n "$(git status --porcelain)" ]]; then
  echo "✗ Working tree is dirty. Commit or stash first."
  git status --short
  exit 1
fi

# ----- 2. Pull latest -----
echo "→ git pull --ff-only"
git pull --ff-only

# ----- 3. Rsync allowed config -----
RSYNC_OPTS=(-rlptD --no-owner --no-group --exclude='*.pyc' --exclude='__pycache__')
$DRYRUN && RSYNC_OPTS+=(--dry-run --itemize-changes)

echo "→ root config files (no --delete)"
for f in "${ROOT_FILES[@]}"; do
  [[ -f "$f" ]] && sudo rsync "${RSYNC_OPTS[@]}" "./$f" "$HA_DIR/$f"
done

echo "→ repo-managed dirs (WITH --delete — renames/deletions propagate)"
for d in "${PRUNE_DIRS[@]}"; do
  [[ -d "$d" ]] && sudo rsync "${RSYNC_OPTS[@]}" --delete "./$d/" "$HA_DIR/$d/"
done

echo "→ HACS/UI-shared dirs (no --delete)"
for d in "${KEEP_DIRS[@]}"; do
  [[ -d "$d" ]] && sudo rsync "${RSYNC_OPTS[@]}" "./$d/" "$HA_DIR/$d/"
done

if $DRYRUN; then
  echo
  echo "✓ Dry-run complete. No files were changed."
  exit 0
fi
echo "✓ Files deployed."

# ----- 4. Optional container restart -----
if [[ "$RESTART" == "true" ]]; then
  CONTAINER=$(docker ps --filter "name=$CONTAINER_NAME_FILTER" --format "{{.Names}}" | head -1)
  if [[ -z "$CONTAINER" ]]; then
    echo "✗ No running container matched name=$CONTAINER_NAME_FILTER"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    exit 1
  fi
  echo "→ docker restart $CONTAINER"
  docker restart "$CONTAINER" >/dev/null
  echo "→ waiting 30s for HA to come up..."
  sleep 30
  echo "✓ Restart complete."
fi

echo
echo "✓ Deploy complete."
if [[ "$RESTART" != "true" ]]; then
  echo "  To pick up changes without a full restart:"
  echo "    HA UI → Developer Tools → YAML → Reload Automations (or Scripts, etc.)"
  echo "  For a full restart:  $0 --restart"
fi
