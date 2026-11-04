#!/usr/bin/env bash
# [INSTRUCTOR] Bootstrap de FreeLLMAPI en EC2 Ubuntu 22/24 — el gateway central del taller
# Uso: bash aws_freellmapi_setup.sh   (como root o con sudo)
set -e
[ "$EUID" = "0" ] || { echo "Ejecuta con sudo"; exit 1; }

apt update && apt install -y git curl
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install -y nodejs

# Repo de FreeLLMAPI (monorepo npm: server/client/cli)
[ -d /opt/freellmapi ] || git clone https://github.com/tashfeenahmed/freellmapi.git /opt/freellmapi
cd /opt/freellmapi && npm ci

# Servicio systemd
cat > /etc/systemd/system/freellmapi.service <<UNIT
[Unit]
Description=FreeLLMAPI gateway (taller agentes IA)
After=network.target
[Service]
Type=simple
WorkingDirectory=/opt/freellmapi
ExecStart=/usr/bin/npm run dev -w server
Restart=always
Environment=NODE_ENV=development
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload && systemctl enable --now freellmapi
sleep 8 && systemctl status freellmapi --no-pager | head -5

# Firewall local (ademas abre el puerto 3001 en el Security Group de AWS)
command -v ufw >/dev/null && ufw allow 3001/tcp || true

# Cuenta admin + KEY unificada para los participantes
echo "== Crea la cuenta admin del gateway =="
read -p "Email admin (ej: instructor@taller.com): " AEMAIL
read -sp "Password admin (min 8): " APASS; echo
curl -s -X POST http://localhost:3001/api/auth/setup -H "Content-Type: application/json" -d "{\"email\":\"$AEMAIL\",\"password\":\"$APASS\"}" | head -c 200; echo

sleep 2
KEY=$(node -e "const db=require('/opt/freellmapi/node_modules/better-sqlite3')('/opt/freellmapi/server/data/freeapi.db',{readonly:true});console.log(db.prepare(\"SELECT value FROM settings WHERE key='unified_api_key'\").get().value)" 2>/dev/null)
echo ""
echo "======================================================="
echo "GATEWAY_URL = http://$(curl -s http://checkip.amazonaws.com):3001"
echo "GATEWAY_KEY = $KEY"
echo "======================================================="
echo "Estos DOS valores van en el .env de cada participante."
echo "Recuerda: Security Group AWS → Inbound → TCP 3001 desde 0.0.0.0/0"
