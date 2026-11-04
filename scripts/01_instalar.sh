#!/usr/bin/env bash
# PASO 1 — Instala Node.js 22 + OpenClaw (sin sudo, usa nvm)
set -e
cd "$(dirname "$0")/.."

if command -v node >/dev/null 2>&1; then
  V=$(node -e "console.log(process.versions.node.split('.')[0])")
  if [ "$V" -ge 22 ]; then echo "✅ Node $V.x ya instalado"; SKIP_NODE=1; fi
fi

if [ "${SKIP_NODE:-}" != "1" ]; then
  echo "📦 Instalando Node 22 con nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"
  nvm install 22
  nvm use 22
fi

echo "📦 Instalando OpenClaw..."
npm install -g openclaw@latest
echo "✅ OpenClaw $(openclaw --version 2>/dev/null | head -1) instalado"

echo "🧙 Asistente de configuración inicial..."
echo "   👉 Cuando pregunte por MODELO/PROVEEDOR elige: Skip / Omitir (lo configuramos en el paso 02)"
openclaw onboard --non-interactive --accept-risk 2>/dev/null || openclaw onboard

echo -e "\n✅ PASO 1 COMPLETO — continúa con: bash scripts/02_proveedor.sh"
