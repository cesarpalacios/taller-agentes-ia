# 🛠️ Troubleshooting — soluciones rápidas

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `node: command not found` | Node no instalado o nueva terminal sin nvm | `export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh" && nvm use 24` |
| `EACCES` al instalar con npm | intentaste con sudo | NO uses sudo — todo con nvm en tu usuario |
| Gateway HTTP 000/timeout | Security Group de AWS cerrado o PC sin internet | Abre TCP 3001 (origen My IP) en el Security Group de tu EC2. Tú: probar `ping google.com` |
| Gateway HTTP 401 | GATEWAY_KEY mal copiada en `.env` | Revisar espacios/comillas en `.env` y repetir `02_proveedor.sh` |
| `PROOF-OK` no aparece | provider registrado con URL equivocada | Borrar y repetir: `openclaw config unset models.providers.freellmapi` + paso 02 |
| Bot de Telegram no responde | token mal pegado | `openclaw config set channels.telegram.botToken "TOKEN_CORRECTO"` |
| Bot pide código de emparejamiento | normal la primera vez | `openclaw pairing list telegram` → `openclaw pairing approve telegram CÓDIGO` |
| Google: "access blocked" / 403 access_denied | tu correo NO está como *Usuario de prueba* en TU proyecto | Google Cloud → Pantalla de consentimiento → Usuarios de prueba → agrega tu correo (ver docs/GMAIL_OAUTH.md) |
| `gmail_setup.py`: la página final no carga (localhost:8080) | es lo esperado en un servidor | Copia la URL completa de la barra de direcciones y pégala en la terminal |
| `python3: command not found` | PC muy capado | Pedir al admin de sala instalar python3-venv, o usar WSL |
| ¿Se subió mi .env o token a GitHub? | no debería | `git status` — si aparecen, NO hagas push; revisa que `.gitignore` esté intacto y quita esos archivos del índice (`git rm --cached`) |

## Comandos útiles de diagnóstico
```bash
openclaw --version                    # ¿CLI viva?
curl -m 8 -H "Authorization: Bearer $GATEWAY_KEY" $GATEWAY_URL/v1/models | head -c 200
openclaw config get models.providers.freellmapi
openclaw channels list                # estado de telegram
openclaw pairing list telegram
```
