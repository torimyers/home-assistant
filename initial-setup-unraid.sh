#!/usr/bin/env bash
# One-time setup on the Unraid box.
# Run this once; afterwards, deploys are: cd $TARGET_DIR && ./deploy.sh
#
# Usage: ./initial-setup-unraid.sh [git-clone-url]
# Default URL: git@github.com:torimyers/home-assistant.git
#
# After running, the repo lives at /mnt/user/appdata/home-assistant-src/
# (kept separate from /mnt/user/appdata/Home-Assistant-Container/ which holds
# HA's runtime state — .storage, zigbee.db, logs, etc.)

set -euo pipefail

REPO_URL="${1:-git@github.com:torimyers/home-assistant.git}"
TARGET_DIR="/mnt/user/appdata/home-assistant-src"

echo "=== Home Assistant config: first-time Unraid setup ==="
echo "Repo URL:   $REPO_URL"
echo "Source dir: $TARGET_DIR"
echo

if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "→ Repo already cloned at $TARGET_DIR — pulling latest"
  cd "$TARGET_DIR"
  git pull --ff-only
else
  echo "→ Cloning into $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"
chmod +x deploy.sh initial-setup-unraid.sh 2>/dev/null || true

echo
echo "✓ Setup complete."
echo
echo "Next steps:"
echo "  cd $TARGET_DIR"
echo "  ./deploy.sh           # syncs files only — reload via HA UI to pick up"
echo "  ./deploy.sh --restart # syncs + restarts the HA container"
