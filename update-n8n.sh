#!/bin/bash

echo "========== $(date '+%Y-%m-%d %H:%M:%S') =========="

# Отримуємо поточну версію
OLD_VERSION=$(n8n --version 2>/dev/null)

# Оновлення
npm update -g n8n >/dev/null 2>&1

# Отримуємо нову версію
NEW_VERSION=$(n8n --version 2>/dev/null)

# Якщо версія змінилася — перезапускаємо
if [[ "$OLD_VERSION" != "$NEW_VERSION" ]]; then
  echo "🔄 Версія змінилась: $OLD_VERSION → $NEW_VERSION"
  echo "🔑 Перезапускаємо службу n8n..."
  systemctl restart n8n 2>&1
  echo "✅ n8n оновлено до версії $NEW_VERSION"
else
  echo "ℹ️ n8n вже останньої версії: $NEW_VERSION"
fi

echo "============================================="