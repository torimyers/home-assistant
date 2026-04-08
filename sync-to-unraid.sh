#!/bin/bash
# Quick sync script to deploy changes to Unraid Home Assistant

UNRAID_PATH="/mnt/unraid/appdata/Home-Assistant-Container"
LOCAL_PATH="/home/tori/Home-Assistant/home-assistant"

echo "🔄 Syncing Home Assistant config to Unraid..."

rsync -av --progress \
  --exclude='.git' \
  --exclude='*.pyc' \
  --exclude='__pycache__' \
  --exclude='.storage' \
  --exclude='home-assistant.log*' \
  --exclude='custom_components' \
  --exclude='zigbee.db' \
  --exclude='zigbee.db-shm' \
  --exclude='zigbee.db-wal' \
  "$LOCAL_PATH/" "$UNRAID_PATH/"

echo "✅ Sync complete!"
echo "💡 Restart Home Assistant to apply changes"
