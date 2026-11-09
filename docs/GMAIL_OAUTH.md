# Paso 4 — Crea tu propio acceso a Gmail (Google Cloud)

Usas **tu propio proyecto de Google Cloud**; no necesitas credenciales de nadie más.
Todo se hace en el **navegador de tu PC**, con **tu cuenta de Google** (~5 min). No requiere tarjeta.

## 1. Proyecto
1. Entra a <https://console.cloud.google.com> con tu cuenta.
2. Selector de proyecto (arriba) → **Proyecto nuevo** → nombre `agente-taller` → **Crear** y selecciónalo.

## 2. Habilitar Gmail API
1. Menú ☰ → **APIs y servicios** → **Biblioteca**.
2. Busca **Gmail API** → **Habilitar**.

## 3. Pantalla de consentimiento
1. **APIs y servicios** → **Pantalla de consentimiento de OAuth** (en consolas nuevas: **Google Auth Platform**).
2. Tipo de usuario: **Externo** → Crear.
3. Nombre de la app (cualquiera), correo de asistencia y de contacto: el tuyo.
4. **Usuarios de prueba (Test users)** → **Agregar usuarios** → escribe **tu propio correo** → Guardar.
   > Sin este paso Google bloqueará el acceso ("access blocked").

## 4. Credenciales (ID y secreto de cliente)
1. **APIs y servicios** → **Credenciales** → **Crear credenciales** → **ID de cliente de OAuth**.
2. Tipo de aplicación: **Aplicación de escritorio** (*Desktop app*) → Crear.
3. Copia el **ID de cliente** (`...apps.googleusercontent.com`) y el **Secreto de cliente** (`GOCSPX-...`).

## 5. En tu EC2
```bash
bash scripts/04_email.sh
```
1. Pega el ID y el secreto cuando los pida.
2. El script imprime un enlace: ábrelo en el navegador de tu PC y autoriza.
3. Si aparece **"Google no verificó esta aplicación"**: *Configuración avanzada* → *Ir a … (no seguro)*. Es tu propia app.
4. Al terminar, el navegador mostrará una página que **no carga** (`http://localhost:8080/?code=…`). Es lo esperado:
   copia la **URL completa** de la barra de direcciones y pégala en la terminal.
5. El script envía un correo de prueba.

## Problemas frecuentes

| Problema | Solución |
|----------|----------|
| `Error 403: access_denied` / "access blocked" | Tu correo no está en **Usuarios de prueba** (paso 3.4) |
| `redirect_uri_mismatch` | El cliente debe ser tipo **Aplicación de escritorio**, no "Web" |
| `invalid_grant` al pegar la URL | El código caduca en minutos: repite `bash scripts/04_email.sh` (borra `email/token.json` si existe) |
| `Gmail API has not been used in project…` | Habilita **Gmail API** en el **mismo** proyecto (paso 2) y espera 1–2 min |
| Dejó de enviar a los 7 días | En modo de prueba el permiso caduca a los 7 días: borra `email/token.json` y repite el paso 4 |
