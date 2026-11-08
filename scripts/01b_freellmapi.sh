#!/usr/bin/env bash
# PASO 1b — Instala TU PROPIO gateway de IA (FreeLLMAPI) en esta EC2 y lo conecta al .env
# Requisito: Security Group con TCP 3001 abierto SOLO a "My IP" (ver docs/00_crear_ec2.md)
set -e
cd "$(dirname "$0")/.."

say(){ printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m❌ %s\033[0m\n' "$*" >&2; exit 1; }

PORT=3001
INSTALL_DIR="$HOME/freellmapi"

# ---------- 1. Docker ----------
if ! command -v docker >/dev/null 2>&1; then
  say "Instalando Docker (~2 min)..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io curl
  sudo apt-get install -y docker-compose-v2 || sudo apt-get install -y docker-compose
  sudo systemctl enable --now docker
else
  say "Docker ya está instalado"
fi

# ---------- 2. FreeLLMAPI (instalador oficial, expuesto para que abras el panel desde tu navegador) ----------
say "Instalando FreeLLMAPI (~2 min)..."
curl -fsSL https://freellmapi.co/install.sh -o /tmp/freellmapi-install.sh
sudo env FREELLMAPI_DIR="$INSTALL_DIR" PORT="$PORT" HOST_BIND=0.0.0.0 bash /tmp/freellmapi-install.sh

# ---------- 3. Datos para abrir el panel ----------
TOKEN=$(curl -s -m 3 -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 60" || true)
IP=$(curl -s -m 3 -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 || true)
[ -n "$IP" ] || IP=$(curl -s -m 5 http://checkip.amazonaws.com || echo "<IP_PUBLICA_DE_TU_EC2>")

CONT=$(sudo docker ps --format '{{.Names}}' | grep -i freellm | head -1 || true)
CODE=""
[ -n "$CONT" ] && CODE=$(sudo docker logs "$CONT" 2>&1 | grep -i "setup code" | tail -1 || true)

cat <<MSG

=======================================================================
 🌐 Abre el panel de TU gateway en el navegador de tu PC:

      http://$IP:$PORT

 1) Crea tu cuenta (correo + contraseña de tu elección).
${CODE:+    Código de configuración que te pida:
    $CODE
}
 2) Página "Keys" → agrega AL MENOS UNA key gratuita de un proveedor:
      • Groq ............ https://console.groq.com/keys
      • Google AI Studio  https://aistudio.google.com/apikey
    (crea la key en el sitio del proveedor y pégala en el panel)

 3) En la misma página "Keys" copia tu UNIFIED API KEY (arriba).
=======================================================================

MSG

# ---------- 4. Pegar la unified key y configurar .env ----------
[ -f .env ] || cp .env.example .env
read -rp "Pega aquí tu UNIFIED API KEY: " GKEY
GKEY=$(printf '%s' "$GKEY" | tr -d '[:space:]')
[ -n "$GKEY" ] || die "No pegaste ninguna key. Vuelve a ejecutar: bash scripts/01b_freellmapi.sh"

HTTP=$(curl -s -m 10 -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $GKEY" "http://localhost:$PORT/v1/models" || true)
[ "$HTTP" = "200" ] || die "La key no fue aceptada (HTTP $HTTP). Cópiala de nuevo desde la página Keys y reintenta."

sed -i "s|^GATEWAY_URL=.*|GATEWAY_URL=http://localhost:$PORT|" .env
sed -i "s|^GATEWAY_KEY=.*|GATEWAY_KEY=$GKEY|" .env
echo "✅ .env configurado (GATEWAY_URL y GATEWAY_KEY)"

# ---------- 5. Prueba real de una respuesta ----------
say "Probando una respuesta de IA real..."
RESP=$(curl -s -m 60 "http://localhost:$PORT/v1/chat/completions" \
  -H "Authorization: Bearer $GKEY" -H "Content-Type: application/json" \
  -d '{"model":"auto","messages":[{"role":"user","content":"Responde solo: GATEWAY-OK"}]}' || true)
if printf '%s' "$RESP" | grep -q "GATEWAY-OK"; then
  echo -e "\n✅ PASO 1b COMPLETO — tu gateway responde 🧠\n➡️  Continúa con: bash scripts/02_proveedor.sh"
else
  echo "⚠️  El gateway está arriba pero no respondió. ¿Agregaste al menos una key de proveedor en la página Keys?"
  echo "    Respuesta: ${RESP:0:200}"
  echo "    Agrega la key y vuelve a ejecutar este script (es seguro repetirlo)."
  exit 1
fi
