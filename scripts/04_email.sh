#!/usr/bin/env bash
# PASO 4 — Conecta TU Gmail con TU propio proyecto de Google Cloud: tu agente podrá enviar correos
set -e
cd "$(dirname "$0")/.."

# 1. Credenciales OAuth: las creas tú en Google Cloud (con tu propio proyecto y tu propia cuenta)
if [ ! -f email/client_secret_taller.json ]; then
  cat <<'GUIA'

🔐 Crea tu propio acceso a Gmail (≈5 min) — guía con detalle: docs/GMAIL_OAUTH.md
   Hazlo en el navegador de tu PC, con TU cuenta de Google:

   1. https://console.cloud.google.com → selector de proyecto → NUEVO PROYECTO (ej: "agente-taller")
   2. Menú "APIs y servicios" → Biblioteca → busca "Gmail API" → HABILITAR
   3. "APIs y servicios" → Pantalla de consentimiento OAuth (o "Google Auth Platform"):
        • Tipo de usuario: EXTERNO
        • Nombre de la app: cualquiera · Correo de soporte: el tuyo
        • Usuarios de prueba (Test users) → AGREGA TU PROPIO CORREO  ← imprescindible
   4. "Credenciales" → CREAR CREDENCIALES → ID de cliente de OAuth
        • Tipo de aplicación: APLICACIÓN DE ESCRITORIO (Desktop app)
   5. Te muestra el ID de cliente y el Secreto de cliente → los pegas aquí abajo.

GUIA
  read -rp "📋 Pega tu ID de cliente (termina en .apps.googleusercontent.com): " CID
  read -rp "🔑 Pega tu Secreto de cliente (empieza con GOCSPX-): " CSEC
  CID=$(printf '%s' "$CID" | tr -d '[:space:]'); CSEC=$(printf '%s' "$CSEC" | tr -d '[:space:]')
  case "$CID" in *.apps.googleusercontent.com) : ;; *) echo "❌ Ese ID de cliente no parece válido"; exit 1;; esac
  [ -n "$CSEC" ] || { echo "❌ Secreto vacío"; exit 1; }
  CID="$CID" CSEC="$CSEC" python3 - <<'PY'
import json, os
cfg = {"installed": {
    "client_id": os.environ["CID"], "client_secret": os.environ["CSEC"],
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "redirect_uris": ["http://localhost"]}}
fd = os.open("email/client_secret_taller.json", os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
with os.fdopen(fd, "w") as f: json.dump(cfg, f)
PY
  echo "✅ Credenciales guardadas (solo en esta EC2, nunca en GitHub)"
fi

# 2. Entorno Python aislado + dependencias
cd email
if [ ! -d .venv ]; then
  if ! python3 -m venv .venv 2>/dev/null; then
    echo "📦 Instalando python3-venv..."
    sudo apt-get update -y >/dev/null && sudo apt-get install -y python3-venv python3-pip >/dev/null
    rm -rf .venv; python3 -m venv .venv || { echo "❌ python3 no disponible"; exit 1; }
  fi
  ./.venv/bin/pip install -q google-auth google-auth-oauthlib google-api-python-client
fi

# 3. Autorizar tu Gmail (flujo para servidor sin navegador)
if [ ! -f token.json ]; then
  ./.venv/bin/python gmail_setup.py
else
  echo "✅ Ya autorizaste tu Gmail (token.json existe; bórralo para repetir)"
fi

# 4. Prueba real de envío
set -a; [ -f ../.env ] && . ../.env; set +a
DEST="${GMAIL_TEST_TO:-}"
case "$DEST" in ""|tu-correo@gmail.com) DEST="";; esac
[ -n "$DEST" ] || read -rp "📧 ¿A qué correo enviamos la prueba?: " DEST
./.venv/bin/python gmail_enviar.py "$DEST"

# 5. Enseñarle a TU AGENTE a enviar correos (skill "enviar-correo") para que lo haga desde Telegram
cd ..
bash scripts/skill_correo.sh

echo -e "\n✅ PASO 4 COMPLETO — revisa la bandeja de $DEST\n➡️  Prueba desde Telegram: /new y luego 'escribe y envía un correo a $DEST sobre la IA en el trabajo'\n➡️  Continúa con: bash scripts/99_check.sh"
