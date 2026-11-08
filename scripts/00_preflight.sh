#!/usr/bin/env bash
# PASO 0 — Verifica si TU servidor puede correr el taller completo (capacidad, red y herramientas)
#
# MÍNIMOS para correr TODO el taller (OpenClaw + FreeLLMAPI con Docker + Telegram + Gmail):
#   • Linux con apt (Ubuntu 22.04/24.04 LTS recomendado) y sudo sin contraseña
#   • RAM:   >= 3.5 GB recomendado (t3.medium). Mínimo absoluto 2 GB (t3.small) + swap
#   • Disco: >= 8 GB libres
#   • CPU:   >= 2 vCPU recomendado (1 funciona, más lento)
#   • Internet hacia: npm, GitHub, nodejs.org, ghcr.io (Docker), freellmapi.co, Telegram y Google
#   • Puerto 3001 libre (panel de FreeLLMAPI)
#   • Node.js >= 24.16 (lo instala el script 01 si falta)
set -u
cd "$(dirname "$0")/.."
FALLAS=0   # bloquea el taller
AVISOS=0   # funciona, pero con riesgo o lentitud

ok(){   echo "✅ $1"; }
info(){ echo "ℹ️  $1"; }
warn(){ echo "⚠️  $1"; AVISOS=$((AVISOS+1)); }
mal(){  echo "❌ $1"; FALLAS=$((FALLAS+1)); }

echo "══════════ 1/4  CAPACIDAD DEL SERVIDOR ══════════"

# Sistema operativo
if [ "$(uname -s)" != "Linux" ]; then
  mal "Sistema $(uname -s): el taller corre en una EC2 Ubuntu (ver docs/00_crear_ec2.md)"
else
  . /etc/os-release 2>/dev/null || true
  ok "Linux: ${PRETTY_NAME:-desconocido}"
  case "${ID:-}" in ubuntu|debian) : ;; *) warn "Se recomienda Ubuntu 22.04/24.04 LTS (los scripts usan apt)";; esac
  command -v apt-get >/dev/null 2>&1 || mal "No hay apt-get: los scripts 01 y 01b necesitan Ubuntu/Debian"
fi

# sudo sin contraseña
if sudo -n true 2>/dev/null; then ok "sudo disponible sin contraseña"; else mal "No tienes sudo sin contraseña (necesario para instalar Docker y crear swap)"; fi

# RAM + swap
MEM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
SWAP_MB=$(awk '/SwapTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
if   [ "$MEM_MB" -ge 3500 ]; then ok "RAM ${MEM_MB} MB (óptimo para el taller completo)"
elif [ "$MEM_MB" -ge 1800 ]; then
  if [ "$SWAP_MB" -ge 1500 ]; then warn "RAM ${MEM_MB} MB + swap ${SWAP_MB} MB: corre, pero más lento. Ideal: t3.medium (4 GB)"
  else warn "RAM ${MEM_MB} MB: justa. El script 01 creará 2 GB de swap. Ideal: t3.medium (4 GB)"; fi
else mal "RAM ${MEM_MB} MB: insuficiente (npm se 'mata' por falta de memoria). Usa t3.small como mínimo, mejor t3.medium"; fi

# Disco libre en /
DISK_GB=$(df -BG --output=avail / 2>/dev/null | tail -1 | tr -dc '0-9')
DISK_GB=${DISK_GB:-0}
if   [ "$DISK_GB" -ge 8 ]; then ok "Disco libre ${DISK_GB} GB"
elif [ "$DISK_GB" -ge 5 ]; then warn "Disco libre ${DISK_GB} GB: justo (recomendado >= 8 GB)"
else mal "Disco libre ${DISK_GB} GB: insuficiente (necesitas >= 8 GB; crea la EC2 con 20 GiB)"; fi

# CPU
CPUS=$(nproc 2>/dev/null || echo 1)
if [ "$CPUS" -ge 2 ]; then ok "CPU: $CPUS vCPU"; else warn "CPU: $CPUS vCPU — funciona, pero las instalaciones serán lentas"; fi

echo
echo "══════════ 2/4  RED (acceso a lo que el taller necesita) ══════════"
chk(){ # chk <nombre> <url>
  local code; code=$(curl -s -m 8 -o /dev/null -w "%{http_code}" "$2" 2>/dev/null || echo 000)
  if [ "$code" != "000" ]; then ok "$1 accesible"; else mal "Sin acceso a $1 ($2) — revisa internet / firewall de salida"; fi
}
chk "npm (instalar OpenClaw)"          https://registry.npmjs.org/
chk "GitHub (repo y nvm)"              https://github.com
chk "nodejs.org (Node 24)"             https://nodejs.org/dist/
chk "ghcr.io (imagen Docker FreeLLMAPI)" https://ghcr.io/v2/
chk "freellmapi.co (instalador)"       https://freellmapi.co/install.sh
chk "Telegram (tu bot)"                https://api.telegram.org
chk "Google (Gmail y Gemini)"          https://accounts.google.com

echo
echo "══════════ 3/4  HERRAMIENTAS ══════════"
command -v git  >/dev/null && ok "git instalado"  || mal "falta git  (sudo apt install -y git)"
command -v curl >/dev/null && ok "curl instalado" || mal "falta curl (sudo apt install -y curl)"

export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null 2>&1
if command -v node >/dev/null 2>&1; then
  if node -e "const [a,b]=process.versions.node.split('.').map(Number);process.exit((a===24&&b>=16)||a>26||(a===26&&b>=1)?0:1)"; then
    ok "Node $(node -v) (cumple >= 24.16)"
  else
    warn "Node $(node -v) es muy viejo: OpenClaw pide >= 24.16 (el script 01_instalar.sh lo actualiza)"
  fi
else
  info "Node.js aún no instalado (normal: lo instala el script 01_instalar.sh)"
fi
command -v openclaw >/dev/null 2>&1 && ok "OpenClaw instalado ($(openclaw --version 2>/dev/null | head -1))" || info "OpenClaw aún no instalado (script 01)"
command -v docker   >/dev/null 2>&1 && ok "Docker instalado" || info "Docker aún no instalado (lo instala el script 01b)"

# Puerto 3001
if command -v ss >/dev/null 2>&1 && ss -ltn 2>/dev/null | grep -q ':3001 '; then
  if command -v docker >/dev/null 2>&1 && sudo -n docker ps 2>/dev/null | grep -qi freellm; then ok "Puerto 3001: ya lo usa tu FreeLLMAPI"
  else warn "Puerto 3001 ocupado por otro proceso (lo necesita FreeLLMAPI)"; fi
else ok "Puerto 3001 libre"; fi

# .env y gateway
[ -f .env ] || { cp .env.example .env && ok ".env creado"; }
[ -f .env ] && set -a && . ./.env && set +a
if [ -z "${GATEWAY_KEY:-}" ] || [ "${GATEWAY_KEY:-}" = "cambia-esta-key" ]; then
  info "Gateway IA aún no configurado (normal: lo instalas en el paso 01b)"
elif [ -n "${GATEWAY_URL:-}" ]; then
  RESP=$(curl -s -m 8 -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $GATEWAY_KEY" "$GATEWAY_URL/v1/models")
  [ "$RESP" = "200" ] && ok "Gateway IA responde en $GATEWAY_URL" || mal "Gateway no responde (HTTP $RESP) — revisa GATEWAY_URL/GATEWAY_KEY"
fi

echo
echo "══════════ 4/4  VEREDICTO ══════════"
if [ "$FALLAS" -gt 0 ]; then
  echo "🔴 NO puedes correr el taller completo todavía: $FALLAS problema(s) bloqueante(s) (❌). Corrígelos y repite este script."
  echo "   Mínimos: Ubuntu + sudo · RAM >= 2 GB (ideal 4 GB) · 8 GB de disco · internet a npm/GitHub/ghcr.io/Telegram/Google."
  exit 1
elif [ "$AVISOS" -gt 0 ]; then
  echo "🟡 El taller correrá COMPLETO, con $AVISOS aviso(s) (⚠️): puede ir más lento o requerir pasos extra. Puedes continuar."
else
  echo "🟢 TODO LISTO: tu servidor cumple lo necesario para el taller completo."
fi
echo "➡️  Siguiente: bash scripts/01_instalar.sh"
