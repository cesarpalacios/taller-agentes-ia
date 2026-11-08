# 🤖 Taller: Productividad con Agentes de IA — Construye tu propio asistente en 1 hora

Repo oficial del taller. Cada participante monta su propio ecosistema de agentes IA:

- **OpenClaw** (open source) = el cerebro del asistente
- **FreeLLMAPI** (gateway central en AWS) = acceso a modelos de lenguaje gratuitos
- **Telegram** = conversación con tu asistente desde el celular
- **Gmail** = envío de correos automatizados

## ☁️ Paso 0 — Crea tu servidor (EC2) en AWS Learner Lab

Tu agente corre en un servidor en la nube. Resumen (guía completa con capturas de ruta y solución de problemas: [`docs/00_crear_ec2.md`](docs/00_crear_ec2.md)):

1. **AWS Academy → Learner Lab → Start Lab** y espera el círculo verde.
2. **AWS → EC2 → Launch instance** con:
   - AMI: **Ubuntu Server 22.04 / 24.04 LTS**
   - Tipo: **t3.small** · Disco: **20 GiB**
   - Key pair nuevo (`.pem`) · Security Group con **SSH (22)**
3. **Connect** → *EC2 Instance Connect* (usuario `ubuntu`), o `ssh -i taller.pem ubuntu@<IP_PUBLICA>`.
4. Dentro del servidor: `sudo apt update && sudo apt install -y git curl`

> ⚠️ El lab se apaga y la IP pública cambia al reiniciarlo. Al terminar, **End Lab**.

## ⚡ Flujo del taller — ejecuta los scripts EN ORDEN (dentro de tu EC2)

```bash
git clone https://github.com/cesarpalacios/taller-agentes-ia.git
cd taller-agentes-ia

cp .env.example .env        # pide los valores al instructor
nano .env                   # GATEWAY_URL y GATEWAY_KEY

bash scripts/00_preflight.sh   # verifica tu equipo y conexión al gateway
bash scripts/01_instalar.sh    # instala Node + OpenClaw (~5 min)
bash scripts/02_proveedor.sh   # conecta OpenClaw al gateway → prueba PROOF-OK
bash scripts/03_telegram.sh    # crea tu bot y habla con tu asistente
bash scripts/04_email.sh       # conecta tu Gmail y envía un correo de prueba
bash scripts/99_check.sh       # verificación final 🎉
```

## 📋 Agenda (60 min)

| Min | Actividad | Script |
|-----|-----------|--------|
| Antes | Paso 0: crear tu EC2 (hazlo al llegar o antes) | [guía](docs/00_crear_ec2.md) |
| 0-5 | Intro + demo del instructor | — |
| 5-15 | Instalar Node + OpenClaw | 01 |
| 15-25 | Conectar al gateway IA (FreeLLMAPI) | 02 |
| 25-40 | Tu bot de Telegram — primer chat con tu agente | 03 |
| 40-50 | Correo: tu agente envía email | 04 |
| 50-60 | Retos libres + cierre | 99 |

## ✅ Requisitos (antes de llegar)

1. Correo electrónico activo — **enviado al organizador con anticipación**
2. Cuenta de GitHub (gratis — github.com)
3. Telegram instalado en tu celular
4. Acceso a **AWS Academy Learner Lab** (invitación del instructor)
5. Sin necesidad de saber programar — todo es copiar y ejecutar

## 🛠️ Si algo falla

Mira `docs/TROUBLESHOOTING.md` o levanta la mano — hay solución para todo.

## 🔒 Privacidad

Este repo es privado. Tu `.env`, tokens y credenciales NUNCA se suben a GitHub (están en `.gitignore`).

---

Instructor: Cesar Palacios · cesar.palacios@aossas.com
