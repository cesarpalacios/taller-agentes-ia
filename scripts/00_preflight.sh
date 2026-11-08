#!/usr/bin/env bash
# PASO 0 — Verifica tu equipo y la conexión al gateway de IA
set -u
cd "$(dirname "$0")/.."
FALLAS=0

ok(){ echo "✅ $1"; }
mal(){ echo "❌ $1"; FALLAS=1; }

# .env
if [ ! -f .env ]; then cp .env.example .env && ok ".env creado (GATEWAY_URL/GATEWAY_KEY se rellenan solos en el paso 01b)"; else ok ".env encontrado"; fi
[ -f .env ] && set -a && . ./.env && set +a

# herramientas base
command -v git  >/dev/null && ok "git instalado"        || mal "falta git"
command -v curl >/dev/null && ok "curl instalado"       || mal "falta curl"
command -v node >/dev/null 2>&1 || mal "Node.js NO instalado (normal si aun no ejecutas 01_instalar.sh)"

# version de node si existe
if command -v node >/dev/null 2>&1; then
  V=$(node -e "console.log(process.versions.node.split('.')[0])" 2>/dev/null || echo 0)
  [ "$V" -ge 24 ] 2>/dev/null && ok "Node $V.x (OpenClaw pide >= 24.16)" || mal "Node demasiado viejo ($V) — OpenClaw necesita >= 24.16 (ejecuta 01_instalar.sh)"
fi

# gateway alcanzable
if [ -z "${GATEWAY_KEY:-}" ] || [ "${GATEWAY_KEY:-}" = "cambia-esta-key" ]; then
  echo "ℹ️  Gateway IA: aun no configurado (normal — lo instalas en el paso 01b)"
elif [ -n "${GATEWAY_URL:-}" ]; then
  RESP=$(curl -s -m 8 -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $GATEWAY_KEY" "$GATEWAY_URL/v1/models")
  [ "$RESP" = "200" ] && ok "Gateway IA responde en $GATEWAY_URL" || mal "Gateway no responde (HTTP $RESP) — revisa GATEWAY_URL/GATEWAY_KEY o tu internet"
else
  [ -f .env ] || true
fi

[ "$FALLAS" = "0" ] && echo -e "\n🟢 TODO LISTO para el taller" || echo -e "\n🔴 Corrige lo anterior antes de continuar"
