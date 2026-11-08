#!/usr/bin/env bash
# PASO 99 — Verificacion final del taller
cd "$(dirname "$0")/.."
# Cargar nvm (los scripts no heredan el PATH de Node en una terminal nueva)
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
command -v openclaw >/dev/null 2>&1 || { echo "❌ openclaw no está instalado o no está en el PATH — ejecuta primero: bash scripts/01_instalar.sh"; exit 1; }
PUNTOS=0

echo "1/3 🧠 Cerebro (gateway IA)..."
if openclaw infer model run --gateway --model freellmapi/auto --prompt "Reply with exactly: PROOF-OK" 2>/dev/null | grep -q "PROOF-OK"; then
  echo "   ✅ IA respondiendo"; PUNTOS=$((PUNTOS+1))
else echo "   ❌ IA no responde — repite 02_proveedor.sh"; fi

echo "2/3 📱 Telegram..."
if openclaw config get channels.telegram.botToken >/dev/null 2>&1 && [ "$(openclaw config get channels.telegram.botToken 2>/dev/null)" != "null" ] && [ -n "$(openclaw config get channels.telegram.botToken 2>/dev/null)" ]; then
  echo "   ✅ Bot configurado — escribele hola a tu bot"; PUNTOS=$((PUNTOS+1))
else echo "   ❌ Sin bot — repite 03_telegram.sh"; fi

echo "3/3 📧 Gmail..."
if [ -f email/token.json ]; then
  echo "   ✅ Gmail autorizado"; PUNTOS=$((PUNTOS+1))
else echo "   ❌ Sin autorizacion Gmail — repite 04_email.sh"; fi

echo ""
[ "$PUNTOS" = "3" ] && echo "🎉 ECOSESTEMA COMPLETO — 3/3. Ya tienes tu asistente de IA funcionando."                      || echo "⚠️  Llevas $PUNTOS/3 — completa lo que falta y vuelve a correr este check."
