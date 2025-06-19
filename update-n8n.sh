#!/bin/bash

echo "========== $(date '+%Y-%m-%d %H:%M:%S') =========="

# Get current version
OLD_VERSION=$(n8n --version 2>/dev/null)

# Update
npm update -g n8n >/dev/null 2>&1

# Get new version
NEW_VERSION=$(n8n --version 2>/dev/null)

# If version changed - restart
if [[ "$OLD_VERSION" != "$NEW_VERSION" ]]; then
  echo "🔄 Version changed: $OLD_VERSION → $NEW_VERSION"
  echo "🔑 Restarting n8n service..."
  systemctl restart n8n 2>&1
  echo "✅ n8n updated to version $NEW_VERSION"
else
  echo "ℹ️ n8n is already at latest version: $NEW_VERSION"
fi

echo "============================================="