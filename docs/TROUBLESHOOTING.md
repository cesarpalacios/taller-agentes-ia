# 🛠️ Troubleshooting — soluciones rápidas

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `node: command not found` | Node no instalado o nueva terminal sin nvm | `export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh" && nvm use 24` |
| `EACCES` al instalar con npm | intentaste con sudo | NO uses sudo — todo con nvm en tu usuario |
| Gateway HTTP 000/timeout | Security Group de AWS cerrado o PC sin internet | Instructor: abrir TCP 3001 inbound. Tú: probar `ping google.com` |
| Gateway HTTP 401 | GATEWAY_KEY mal copiada en `.env` | Revisar espacios/comillas en `.env` y repetir `02_proveedor.sh` |
| `PROOF-OK` no aparece | provider registrado con URL equivocada | Borrar y repetir: `openclaw config unset models.providers.freellmapi` + paso 02 |
| Bot de Telegram no responde | token mal pegado | `openclaw config set channels.telegram.botToken "TOKEN_CORRECTO"` |
| Bot pide código de emparejamiento | normal la primera vez | `openclaw pairing list telegram` → `openclaw pairing approve telegram CÓDIGO` |
| Google: "App not verified / access blocked" | tu correo NO está como test user | Instructor: agregarte en OAuth consent → test users; luego reintentar |
| `gmail_setup.py` falla al abrir navegador | PC de sala sin navegador default | Copiar la URL que imprime a Chrome/ Firefox manualmente |
| `python3: command not found` | PC muy capado | Pedir al admin de sala instalar python3-venv, o usar WSL |
| ¿Se subió mi .env o token a GitHub? | no debería | `git status` — si aparecen, NO hagas push; avisa al instructor |

## Comandos útiles de diagnóstico
```bash
openclaw --version                    # ¿CLI viva?
curl -m 8 -H "Authorization: Bearer $GATEWAY_KEY" $GATEWAY_URL/v1/models | head -c 200
openclaw config get models.providers.freellmapi
openclaw channels list                # estado de telegram
openclaw pairing list telegram
```
