# Paso 0 — Crea tu servidor (EC2) en AWS Learner Lab

Tu agente vive en un servidor en la nube. Aquí lo creas, una sola vez (~10 min).

## Configuración que necesitas

| Campo | Valor |
|-------|-------|
| Sistema operativo | **Ubuntu Server 22.04 o 24.04 LTS** |
| Tipo de instancia | **t3.medium** (mínimo t3.small) |
| Disco | 20 GiB (gp3) |
| Key pair | Nueva, formato `.pem` |
| Firewall (Security Group) | SSH (22) y **TCP 3001**, ambos con origen *My IP* |
| Usuario de conexión | `ubuntu` |

## Pasos

### 1. Inicia el lab
1. Entra a **AWS Academy** → tu curso → **Learner Lab**.
2. Pulsa **Start Lab** y espera a que el círculo junto a **AWS** se ponga **verde** (1–3 min).
3. Pulsa **AWS** para abrir la consola.

### 2. Lanza la instancia
1. En la consola busca **EC2** → **Launch instance**.
2. **Name:** `agente-<tu-nombre>`.
3. **AMI:** *Ubuntu Server 22.04 LTS* (o 24.04).
4. **Instance type:** `t3.medium`.
5. **Key pair (login):** *Create new key pair* → nombre `taller` → tipo RSA → formato `.pem` → **Create**. Guarda el archivo descargado.
   > Algunos labs ya traen una llave `vockey`. Puedes usarla en lugar de crear una nueva.
6. **Network settings:** *Edit* → deja la regla **SSH (22)** con origen **My IP** y pulsa *Add security group rule*: tipo **Custom TCP**, puerto **3001**, origen **My IP** (es el panel de tu gateway FreeLLMAPI).
7. **Storage:** 20 GiB gp3.
8. Pulsa **Launch instance**.

### 3. Conéctate
Elige la opción que te resulte más fácil.

**Opción A — desde el navegador (sin instalar nada)**
1. EC2 → **Instances** → selecciona tu instancia (estado *Running*).
2. **Connect** → pestaña **EC2 Instance Connect** → usuario `ubuntu` → **Connect**.

**Opción B — desde tu terminal**
1. Copia la **IPv4 pública** de la instancia.
2. Ejecuta:
   ```bash
   chmod 400 taller.pem        # en Linux/Mac
   ssh -i taller.pem ubuntu@<IP_PUBLICA>
   ```
   En Windows (PowerShell) usa el mismo comando `ssh`; si da error de permisos, ejecuta antes:
   `icacls taller.pem /inheritance:r /grant:r "$($env:USERNAME):R"`

### 4. Prepara el entorno
Ya dentro del servidor:

```bash
sudo apt update && sudo apt install -y git curl
git clone https://github.com/cesarpalacios/taller-agentes-ia.git
cd taller-agentes-ia
```

Sigue con el flujo del [README](../README.md): ejecuta los scripts en orden (`00`, `01`, `01b`…). El script `01b` instala **tu propio gateway FreeLLMAPI** y deja el `.env` listo.

## ⚠️ Importante

- **El lab se apaga solo** (sesión limitada). Al reiniciarlo, tu instancia puede volver a arrancar, pero **la IP pública cambia**: vuelve a copiarla desde la consola.
- Al terminar el taller pulsa **End Lab** (o *Stop* en la instancia) para no gastar crédito.
- **Nunca compartas tu archivo `.pem`.**

## Si algo falla

| Problema | Solución |
|----------|----------|
| No abre el panel `http://IP:3001` | Security Group → Inbound: agrega *Custom TCP 3001* con origen *My IP* (si tu IP cambió, actualízala) |
| El círculo AWS no se pone verde | Espera 2–3 min; si sigue rojo, pulsa *Start Lab* de nuevo |
| `Connection timed out` por SSH | Revisa que el Security Group permita SSH (22) y que usas la IP actual |
| `Permission denied (publickey)` | Usuario correcto (`ubuntu`) y el `.pem` de esa instancia |
| `UNPROTECTED PRIVATE KEY FILE` | Aplica el `chmod 400` (o el `icacls` en Windows) |
| No me deja crear la instancia | Tu lab puede restringir tipos: prueba `t3.small` o el tipo más grande que permita (revisa que tenga al menos 2 GB de RAM) |
