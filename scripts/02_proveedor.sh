#!/usr/bin/env bash
# PASO 2 — Conecta OpenClaw al gateway de IA (FreeLLMAPI) y prueba la ruta
set -e
cd "$(dirname "$0")/.."
# Cargar nvm (los scripts no heredan el PATH de Node en una terminal nueva)
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
command -v openclaw >/dev/null 2>&1 || { echo "❌ openclaw no está instalado o no está en el PATH — ejecuta primero: bash scripts/01_instalar.sh"; exit 1; }
[ -f .env ] || { echo "❌ Falta .env — ejecuta primero: bash scripts/01b_freellmapi.sh"; exit 1; }
set -a; . ./.env; set +a
[ -n "${GATEWAY_URL:-}" ] && [ -n "${GATEWAY_KEY:-}" ] || { echo "❌ .env sin GATEWAY_URL/GATEWAY_KEY — ejecuta primero: bash scripts/01b_freellmapi.sh"; exit 1; }

# 1. Guardar la key localmente (nunca se sube a git)
mkdir -p ~/.openclaw/taller && umask 077
printf '%s' "$GATEWAY_KEY" > ~/.openclaw/taller/freellm.key

# 2. Registrar proveedor freellmapi en OpenClaw
openclaw config set secrets.providers.freellmapi_key_file --provider-source file --provider-path ~/.openclaw/taller/freellm.key --provider-mode singleValue

printf '{"baseUrl":"%s/v1","api":"openai-completions","models":[{"id":"auto","name":"Auto (mejor modelo disponible)","api":"openai-completions"},{"id":"fusion","name":"Fusion","api":"openai-completions"},{"id":"kimi-k2.6","name":"Kimi K2.6","api":"openai-completions"},{"id":"qwen3-coder","name":"Qwen3 Coder","api":"openai-completions"}]}' "$GATEWAY_URL" > /tmp/flprovider.json
openclaw config set models.providers.freellmapi --strict-json "$(cat /tmp/flprovider.json)"
openclaw config set models.providers.freellmapi.apiKey --ref-provider freellmapi_key_file --ref-source file --ref-id value

# 3. Permitir la ruta del proveedor
openclaw config set agents.entries.main.modelPolicy.allow --strict-json '["freellmapi/*"]'

# 4. PRUEBA REAL de la ruta
echo "🧪 Probando ruta de IA (debe responder PROOF-OK)..."
openclaw infer model run --gateway --model freellmapi/auto --prompt "Reply with exactly: PROOF-OK" \
  && echo -e "\n✅ PASO 2 COMPLETO — tu agente ya tiene cerebro 🧠\n➡️  Continúa con: bash scripts/03_telegram.sh" \
  || { echo "❌ La prueba falló — revisa docs/TROUBLESHOOTING.md"; exit 1; }
