#!/usr/bin/env bash
# Home Assistant config deploy script — runs on the Unraid box.
# Usage: from the repo root on Unraid, run ./deploy.sh [--restart]
#
# What it does:
#   1. Refuses to deploy if the working tree is dirty
#   2. git pull --ff-only on the current branch
#   3. rsyncs allowed config dirs into the live HA appdata
#   4. Optional: restarts the Home Assistant container with --restart
#
# Mirrors the include/exclude rules from .github/workflows/deploy.yaml.
# That workflow's self-hosted runner is no longer registered with the repo,
# so this script is the manual replacement until the runner is restored.

set -euo pipefail

# ----- config — adjust if you renamed things -----
HA_DIR="/mnt/user/appdata/Home-Assistant-Container"
CONTAINER_NAME_FILTER="Home-Assistant"  # passed to: docker ps --filter name=...
# --------------------------------------------------

RESTART=false
for arg in "$@"; do
  case "$arg" in
    --restart) RESTART=true ;;
    -h|--help)
      echo "Usage: $0 [--restart]"
      echo "  --restart  Restart the HA container after deploying"
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; echo "Usage: $0 [--restart]"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Home Assistant config deploy ==="
echo "Repo:    $SCRIPT_DIR"
echo "Target:  $HA_DIR"
echo "Restart: $RESTART"
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

# ----- 3. Rsync allowed config dirs -----
# Same include/exclude pattern as .github/workflows/deploy.yaml.
# Excludes: secrets.yaml, custom_components/, zigbee.db*, .storage/, logs, .git, etc.
echo "→ rsync to $HA_DIR"
sudo rsync -rlptD \
  --no-owner --no-group \
  --include='*.yaml' \
  --include='*.yml' \
  --include='automations/' \
  --include='automations/**' \
  --include='scenes/' \
  --include='scenes/**' \
  --include='scripts/' \
  --include='scripts/**' \
  --include='integrations/' \
  --include='integrations/**' \
  --include='customizations/' \
  --include='customizations/**' \
  --include='entities/' \
  --include='entities/**' \
  --include='blueprints/' \
  --include='blueprints/**' \
  --include='dashboards/' \
  --include='dashboards/**' \
  --include='themes/' \
  --include='themes/**' \
  --include='assistants/' \
  --include='assistants/**' \
  --exclude='*' \
  ./ "$HA_DIR/"

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
