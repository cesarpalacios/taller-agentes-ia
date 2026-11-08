#!/usr/bin/env bash
# Configura a tu agente para que SIEMPRE responda en español (escribe en SOUL.md del workspace)
# Es seguro repetirlo: no duplica el bloque.
set -e

WS="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
SOUL="$WS/SOUL.md"
MARK="<!-- taller-idioma-es -->"

mkdir -p "$WS"
touch "$SOUL"

if grep -q "$MARK" "$SOUL"; then
  echo "✅ El idioma español ya estaba configurado en $SOUL"
else
  cat >> "$SOUL" <<EOF

$MARK
## Idioma
- Responde SIEMPRE en español, sin importar el idioma del modelo o del mensaje, salvo que te pidan explícitamente otro idioma.
- Usa un tono cercano, claro y breve. Tutea al usuario.
- Los comandos, código y nombres técnicos se dejan tal cual, pero tus explicaciones van en español.
EOF
  echo "✅ Idioma español configurado en $SOUL"
fi

echo "ℹ️  Si tu bot ya había respondido en inglés, escríbele /new en Telegram para empezar una conversación nueva."
