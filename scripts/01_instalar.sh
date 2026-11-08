#!/usr/bin/env bash
# PASO 1 — Instala Node.js 24 + OpenClaw (sin sudo, usa nvm)
set -e
cd "$(dirname "$0")/.."

# OpenClaw exige Node >=24.16 <25  o  >=26.1
node_ok(){ command -v node >/dev/null 2>&1 && node -e "const [a,b]=process.versions.node.split('.').map(Number);process.exit((a===24&&b>=16)||a>26||(a===26&&b>=1)?0:1)"; }

if node_ok; then
  echo "✅ Node $(node -v) ya instalado"
else
  echo "📦 Instalando Node 24 con nvm (OpenClaw no funciona con Node 22)..."
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  . "$NVM_DIR/nvm.sh"
  nvm install 24
  nvm use 24
  nvm alias default 24
  node_ok || { echo "❌ Node $(node -v) no cumple el mínimo de OpenClaw (>=24.16)"; exit 1; }
fi

# Poca RAM (<3 GB) + sin swap => npm es "Killed" por falta de memoria. Creamos 2 GB de swap.
MEM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
if [ "$MEM_MB" -lt 3000 ] && [ "$(swapon --show --noheadings | wc -l)" = "0" ]; then
  echo "💾 RAM baja (${MEM_MB} MB): creando 2 GB de swap para que la instalación no falle..."
  sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile >/dev/null && sudo swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

echo "📦 Instalando OpenClaw (puede tardar unos minutos)..."
npm install -g openclaw@latest --no-fund --no-audit
echo "✅ OpenClaw $(openclaw --version 2>/dev/null | head -1) instalado"

echo "🧙 Asistente de configuración inicial..."
echo "   👉 Cuando pregunte por MODELO/PROVEEDOR elige: Skip / Omitir (lo configuramos en el paso 02)"
openclaw onboard --non-interactive --accept-risk 2>/dev/null || openclaw onboard

echo -e "\n✅ PASO 1 COMPLETO — continúa con: bash scripts/01b_freellmapi.sh"
