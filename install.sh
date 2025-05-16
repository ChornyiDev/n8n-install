#!/bin/bash

# ======================
# === Конфігурація ====
# ======================

# N8N системний користувач
N8N_USER="n8n"
N8N_HOME="/home/$N8N_USER"
INSTALL_DIR="$N8N_HOME/.n8n"

# 🌐 N8N сервер
N8N_HOST="127.0.0.1"
N8N_PORT=5678
N8N_PROTOCOL="http"

# ======================
# === Перевірки та кольори ===
# ======================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Перевірка root прав
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${YELLOW}This script must be run as root.${NC}"
    exit 1
fi

echo -e "${GREEN}Running as root. Proceeding...${NC}"

# ======================
# === Створення користувача ===
# ======================

if id "$N8N_USER" &>/dev/null; then
    echo -e "${GREEN}User '$N8N_USER' already exists.${NC}"
else
    echo -e "${GREEN}Creating system user '$N8N_USER'...${NC}"
    useradd --system --create-home --shell /usr/sbin/nologin "$N8N_USER"
fi

# Створення директорії для .env
mkdir -p "$INSTALL_DIR"
chown -R $N8N_USER:$N8N_USER "$INSTALL_DIR"

# ======================
# === Node.js 22 ===
# ======================

if ! command -v node &> /dev/null; then
    INSTALL_NODE=true
else
    NODE_VERSION=$(node -v | sed 's/v\([0-9]*\).*/\1/')
    if [[ "$NODE_VERSION" -lt 18 || "$NODE_VERSION" -gt 22 ]]; then
        INSTALL_NODE=true
    else
        INSTALL_NODE=false
    fi
fi

if [[ "$INSTALL_NODE" = true ]]; then
    echo -e "${GREEN}Installing Node.js 22.x...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
else
    echo -e "${GREEN}Node.js version $(node -v) is already suitable (v18 to v22).${NC}"
fi

NODE_VERSION=$(node -v)
if [[ $NODE_VERSION != v22* ]]; then
    echo -e "${YELLOW}Node.js 22.x is required. Current: $NODE_VERSION${NC}"
    exit 1
else
    echo -e "${GREEN}Node.js $NODE_VERSION installed.${NC}"
fi

# ======================
# === Встановлення n8n ===
# ======================

echo -e "${GREEN}Installing latest n8n globally...${NC}"
npm config set prefix /usr
npm uninstall -g n8n || true
npm install -g n8n@latest

if ! command -v n8n &> /dev/null; then
    echo -e "${YELLOW}n8n installation failed.${NC}"
    exit 1
fi

# ======================
# === Генерація .env ===
# ======================

echo -e "${GREEN}Creating .env file...${NC}"
cat > "$INSTALL_DIR/.env" << EOL
N8N_HOST=$N8N_HOST
N8N_PORT=$N8N_PORT
N8N_PROTOCOL=$N8N_PROTOCOL

# Add more environment variables here if needed
EOL

chmod 600 "$INSTALL_DIR/.env"
chown $N8N_USER:$N8N_USER "$INSTALL_DIR/.env"

# ======================
# === Створення systemd служби ===
# ======================

echo -e "${GREEN}Creating systemd service for n8n...${NC}"

cat > /etc/systemd/system/n8n.service << EOL
[Unit]
Description=n8n workflow automation tool
After=network.target

[Service]
Type=simple
User=$N8N_USER
EnvironmentFile=$INSTALL_DIR/.env
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/n8n start
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# ======================
# === Запуск та статус ===
# ======================

echo -e "${GREEN}Enabling and starting n8n service...${NC}"
systemctl daemon-reload
systemctl enable n8n
systemctl restart n8n

systemctl status n8n --no-pager

# ======================
# === Завершення ===
# ======================

echo -e "${GREEN}✅ n8n успішно встановлено та запущено як systemd-сервіс під користувачем '$N8N_USER'.${NC}"
echo
echo -e "${GREEN}📄 .env файл знаходиться за адресою:${NC} $INSTALL_DIR/.env"
echo
echo -e "${GREEN}⚙️ Команди для керування службою:${NC}"
echo -e "  ▸ Перевірити статус:   ${YELLOW}sudo systemctl status n8n${NC}"
echo -e "  ▸ Перезапустити:       ${YELLOW}sudo systemctl restart n8n${NC}"
echo -e "  ▸ Зупинити:            ${YELLOW}sudo systemctl stop n8n${NC}"
echo -e "  ▸ Увімкнути автозапуск:${YELLOW}sudo systemctl enable n8n${NC}"
echo -e "  ▸ Вимкнути автозапуск: ${YELLOW}sudo systemctl disable n8n${NC}"
echo
echo -e "${GREEN}📦 Перегляд логів у реальному часі:${NC}"
echo -e "  ${YELLOW}sudo journalctl -u n8n -f${NC}"
echo
echo -e "${GREEN}🎉 Готово! n8n працює на http://$N8N_HOST:$N8N_PORT${NC}"
echo -e "${GREEN}Node.js версія: $(node -v) | n8n версія: $(n8n --version)${NC}"

