# 🧑‍🏫 Guía del Instructor — Checklist completo

> Objetivo: llegar a la hora del taller con TODO pre-configurado. Los asistentes solo ejecutan scripts.

## 📅 Semana antes

### 1. Gateway central en AWS (EC2)
- [ ] Crear EC2 **Ubuntu 22/24** (t3.small alcanza sobrado)
- [ ] **Security Group**: Inbound → SSH (22, solo tu IP) + **TCP 3001** (0.0.0.0/0)
- [ ] SSH a la instancia y ejecutar: `bash server/aws_freellmapi_setup.sh`
- [ ] Anotar los dos valores que imprime: **GATEWAY_URL** y **GATEWAY_KEY**
- [ ] Probar desde fuera: `curl -H "Authorization: Bearer KEY" http://IP:3001/v1/models`

### 2. Proyecto Google Cloud para el correo (Gmail API)
- [ ] console.cloud.google.com → crear proyecto "taller-agentes-ia"
- [ ] Habilitar **Gmail API**
- [ ] Pantalla de consentimiento OAuth → External → agregar **TODOS los correos de asistentes** como *test users* ← por eso pedimos la lista con anticipación
- [ ] Credenciales → Crear **OAuth Client ID → Aplicación de escritorio** → descargar JSON
- [ ] Guardarlo como `client_secret_taller.json` y compartirlo por Drive (solo a asistentes)

### 3. Repo
- [ ] Repo ya está en GitHub (privado): invitar asistentes (Settings → Collaborators → email de GitHub) o generar fine-grained token de lectura y darlo el día del taller
- [ ] Ajustar `.env.example` — dejar los valores REALES de GATEWAY_URL directamente (la key va aparte)

## 📅 Día antes
- [ ] Verificar lista de correos → todos como test users en Google Cloud
- [ ] Guardar GATEWAY_KEY en sobre/diapositiva para entregarla al iniciar el paso 02
- [ ] Probar el flujo COMPLETO tú mismo en una VM limpia (cronometra: debe dar ≤ 40 min)
- [ ] Verificar `systemctl status freellmapi` en el EC2

## ⏰ Hora antes
- [ ] EC2 arriba + curl externo OK
- [ ] PCs de la sala: internet + navegador + cuenta GitHub de cada asistente
- [ ] Proyector listo con tu propia demo funcionando
- [ ] Link corto para clonar el repo (ej: bit.ly/taller-agentes)

## 🎬 Durante (tu guion)
- **0-5**: Demo tuya: "miren lo que MI asistente hace por Telegram" (impacto primero)
- **5-15**: PASO 01 — todos instalando (circula por la sala; el script es la clase)
- **15-25**: PASO 02 — entrega la KEY en pantalla, todos deben ver PROOF-OK antes de seguir
- **25-40**: PASO 03 — BotFather en el celular + pairing. Momento "wow": todos chateando con su agente
- **40-50**: PASO 04 — OAuth Gmail (aquí salen los errores de test users → tener TROUBLESHOOTING a mano)
- **50-60**: Reto libre: que le pidan a su agente algo real + check final + foto grupal

## 🧹 Después
- [ ] **Rotar la GATEWAY_KEY** (o apagar la EC2) — no dejes el gateway abierto
- [ ] Compartir el repo (o hacerlo temporalmente público) para que repliquen en casa
