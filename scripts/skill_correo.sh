#!/usr/bin/env bash
# Le enseña a tu agente OpenClaw a ENVIAR CORREOS con tu Gmail (instala la skill "enviar-correo").
# Requiere haber completado scripts/04_email.sh (token.json). Es seguro repetirlo.
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WS="${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
DIR="$WS/skills/enviar-correo"

[ -f "$REPO/email/token.json" ] || { echo "❌ Aún no autorizaste tu Gmail. Ejecuta primero: bash scripts/04_email.sh"; exit 1; }
[ -e "$REPO/email/.venv/bin/python" ] || { echo "❌ Falta el entorno Python (email/.venv). Ejecuta: bash scripts/04_email.sh"; exit 1; }

mkdir -p "$DIR"
cat > "$DIR/SKILL.md" <<EOF
---
name: enviar-correo
description: Envía correos reales desde el Gmail del usuario cuando pida enviar, mandar o escribir un email.
---

# Enviar correo con Gmail

Tienes acceso a la cuenta Gmail del usuario mediante un script local. Cuando el usuario te pida
enviar o mandar un correo, **úsalo siempre**. NUNCA digas que no tienes servicio de correo ni
le pidas que lo envíe él mismo.

## Pasos
1. Redacta el asunto y el cuerpo (en español, salvo que el usuario pida otro idioma).
2. Guarda el cuerpo en un archivo, por ejemplo \`/tmp/correo.txt\`.
3. Usa la herramienta \`exec\` para ejecutar:

\`\`\`bash
$REPO/email/.venv/bin/python $REPO/email/gmail_enviar.py --to "DESTINATARIO" --subject "ASUNTO" --body-file /tmp/correo.txt
\`\`\`

4. Si la salida dice "Correo enviado", confirma al usuario el destinatario y el asunto.

## Reglas
- Envía SOLO al destinatario que el usuario indicó. Si falta el destinatario, pregúntalo.
- Si el usuario dijo que lo envíes "cuando termines", envíalo apenas el texto esté listo, sin pedir más confirmación.
- Si el script falla, resume el error en una línea y sugiere ejecutar \`bash scripts/04_email.sh\`.
EOF

echo "✅ Skill 'enviar-correo' instalada en $DIR"

# Refuerzo en AGENTS.md (reglas de operación que OpenClaw siempre inyecta al agente)
AGENTS="$WS/AGENTS.md"; MARK="<!-- taller-correo -->"
touch "$AGENTS"
if ! grep -q "$MARK" "$AGENTS"; then
  cat >> "$AGENTS" <<EOF

$MARK
## Correo electrónico
- SÍ puedes enviar correos: tienes la skill \`enviar-correo\` (Gmail del usuario) y la herramienta \`exec\`.
- Cuando el usuario pida enviar/mandar un correo, redáctalo y ENVÍALO con esa skill. Nunca respondas que no hay servicio de correo ni le pidas que lo envíe él.
EOF
  echo "✅ Regla de correo añadida a $AGENTS"
fi
if command -v openclaw >/dev/null 2>&1; then
  openclaw skills list 2>/dev/null | grep -i "enviar-correo" || echo "ℹ️  No aparece aún en 'openclaw skills list'; reinicia con: openclaw gateway restart"
fi
echo "ℹ️  Escríbele /new a tu bot en Telegram (sesión nueva) y pídele: 'envía un correo de prueba a tu@correo.com'"
