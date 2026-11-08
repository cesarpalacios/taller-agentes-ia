#!/usr/bin/env bash
# PASO 3 — Crea tu bot de Telegram y habla con tu asistente
set -e
cd "$(dirname "$0")/.."
# Cargar nvm (los scripts no heredan el PATH de Node en una terminal nueva)
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
command -v openclaw >/dev/null 2>&1 || { echo "❌ openclaw no está instalado o no está en el PATH — ejecuta primero: bash scripts/01_instalar.sh"; exit 1; }

# Que el agente responda en español
bash "$(dirname "$0")/idioma_es.sh" || echo "⚠️  No se pudo configurar el idioma; puedes ejecutar: bash scripts/idioma_es.sh"

cat <<'PASOS'
📱 PASO A — Crea tu bot (1 minuto):
   1. Abre Telegram y busca @BotFather
   2. Envía: /newbot
   3. Ponle nombre (ej: Asistente de Maria)
   4. Ponle usuario (debe terminar en bot, ej: maria_asistente_bot)
   5. BotFather te da un TOKEN — cópialo
PASOS

read -p "🔑 Pega aquí el token del bot: " TOKEN
[ -n "$TOKEN" ] || { echo "❌ Token vacío"; exit 1; }

openclaw config set channels.telegram.botToken "$TOKEN"
echo "✅ Bot configurado en OpenClaw"

cat <<'PASOS'
📱 PASO B — Empareja tu Telegram:
   1. Busca tu bot por su usuario y envíale: hola
   2. El bot responde con un CÓDIGO de emparejamiento
PASOS

openclaw pairing list telegram 2>/dev/null || true
read -p "🔑 Pega el código de emparejamiento: " CODE
[ -n "$CODE" ] && openclaw pairing approve telegram "$CODE"

echo -e "\n💬 ¡Listo! Escribe a tu bot por Telegram algo como: 'Resume qué es un agente de IA en 3 líneas'"
echo "➡️  Continúa con: bash scripts/04_email.sh"
