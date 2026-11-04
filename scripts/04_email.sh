#!/usr/bin/env bash
# PASO 4 — Conecta tu Gmail: tu agente podra enviar correos
set -e
cd "$(dirname "$0")/.."

# 1. Cliente OAuth del taller (lo entrega el instructor)
[ -f email/client_secret_taller.json ] || {
  echo "❌ Falta email/client_secret_taller.json"
  echo "   Descargalo del enlace que compartio el instructor y guardalo en la carpeta email/"
  exit 1
}

# 2. Entorno Python aislado + dependencias
cd email
if [ ! -d .venv ]; then
  python3 -m venv .venv 2>/dev/null || { echo "❌ python3 no disponible"; exit 1; }
  ./.venv/bin/pip install -q google-auth google-auth-oauthlib google-api-python-client
fi

# 3. Autorizar tu Gmail (se abre el navegador — inicia sesion con TU cuenta)
echo "🔐 Se abrira el navegador para autorizar tu Gmail (usa TU cuenta, la misma que diste al organizador)..."
./.venv/bin/python gmail_setup.py

# 4. Prueba real de envio
set -a; [ -f ../.env ] && . ../.env; set +a
DEST="${GMAIL_TEST_TO:-}"
[ -n "$DEST" ] || read -p "📧 A que correo enviamos la prueba?: " DEST
./.venv/bin/python gmail_enviar.py "$DEST" \
  && echo -e "\n✅ PASO 4 COMPLETO — revisa la bandeja de $DEST\n➡️  Continua con: bash scripts/99_check.sh"
