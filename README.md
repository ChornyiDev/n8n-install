# 🛠️ n8n Secure Installer

This script automates the installation of [n8n](https://n8n.io) as a **systemd service** on a Linux server, running under a **dedicated system user `n8n`** for enhanced security.

---

## ⚙️ What the Script Does

* Checks for Node.js (supported versions: **v18–v22**)
* Installs Node.js 21.x if needed
* Installs `n8n` globally via `npm`
* Creates system user `n8n`
* Generates `.env` file in `/home/n8n/.n8n/.env`
* Creates systemd service `n8n.service`
* Starts the service and enables autostart on system boot

---

## 📦 How to Use

```bash
# 1. Clone the repository
git clone https://github.com/ChornyiDev/n8n-install.git ~/n8n-install

# 2. Change directory
cd ~/n8n-install

# 3. Run script as root or via sudo
sudo bash install-n8n.sh
```

> ⚠️ The script **must be run with root privileges** as it creates a user, installs packages, and configures the service.

---

## ✅ After Installation

* n8n will be running as a **system service**
* Running under the `n8n` user
* Configuration file:
  `/home/n8n/.n8n/.env`
* System service file:
  `/etc/systemd/system/n8n.service`

---

## 🔧 Service Management Commands

```bash
# Check status
sudo systemctl status n8n

# Restart service
sudo systemctl restart n8n

# Stop service
sudo systemctl stop n8n

# Enable autostart
sudo systemctl enable n8n

# Disable autostart
sudo systemctl disable n8n

# View logs in real-time
sudo journalctl -u n8n -f

# Edit configuration
nano /home/n8n/.n8n/.env
```

---

## 🌐 Access

After startup, n8n will be available at:

```
http://your-ip:5678
```

> If you're using a reverse proxy or changing the configuration — update the `.env` file.

---

## 📅 Updating n8n

The repository includes a separate script [`update-n8n.sh`](./update-n8n.sh) that:

- checks the current n8n version
- updates via `npm`
- restarts the service only if the version has changed

### 🔧 Manual Update

```bash
sudo bash update-n8n.sh
```

### 🕛 Auto-update (optionally)

To set up automatic updates every Sunday at 12:00 via Crontab:

```bash
(crontab -l 2>/dev/null; echo "0 12 * * 0 /full/path/to/update-n8n.sh 2>> /var/log/n8n-update.log") | crontab -
```

> Note: The log only records errors (stderr) in `/var/log/n8n-update.log`

---

## 📁 Structure

```
~/n8n-install/
├── install-n8n.sh     # main installation script
├── update-n8n.sh      # update script
├── example.env        # configuration example
├── README.md          # documentation
└── nginx/            
    └── n8n.conf      # initial nginx configuration
```

---

## 📜 License

MIT — use, modify, distribute.
