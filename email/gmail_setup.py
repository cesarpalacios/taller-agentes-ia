#!/usr/bin/env python3
"""Autoriza TU Gmail para el taller — guarda token.json (no se sube a git).

Funciona en un servidor sin navegador (EC2): abres el enlace en el navegador de tu PC,
autorizas, y pegas aquí la URL a la que Google te redirige (la página no cargará, es normal).
"""
import os
import sys

# El redirect es http://localhost (nada escucha ahí): permitimos http solo para este flujo local.
os.environ.setdefault("OAUTHLIB_INSECURE_TRANSPORT", "1")
os.environ.setdefault("OAUTHLIB_RELAX_TOKEN_SCOPE", "1")

from google_auth_oauthlib.flow import InstalledAppFlow  # noqa: E402

SCOPES = [
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/gmail.readonly",
]
REDIRECT = "http://localhost:8080/"


def main():
    flow = InstalledAppFlow.from_client_secrets_file(
        "client_secret_taller.json", SCOPES, redirect_uri=REDIRECT
    )
    url, _ = flow.authorization_url(access_type="offline", prompt="consent")

    print("\n1) Abre este enlace en el navegador de TU PC e inicia sesión con TU cuenta de Google:\n")
    print(url)
    print(
        "\n2) Si ves 'Google no verificó esta aplicación': pulsa 'Configuración avanzada' → "
        "'Ir a ... (no seguro)'. Es TU propia app, es seguro.\n"
        "3) Acepta los permisos. Al final el navegador mostrará una página que NO carga "
        "(http://localhost:8080/?code=...). Es lo esperado.\n"
        "4) Copia la URL COMPLETA de la barra de direcciones y pégala aquí.\n"
    )
    resp = input("URL completa (o solo el valor de code=): ").strip()
    if not resp:
        print("❌ No pegaste nada.")
        sys.exit(1)

    if resp.startswith("http"):
        flow.fetch_token(authorization_response=resp)
    else:
        flow.fetch_token(code=resp)

    with open("token.json", "w") as f:
        f.write(flow.credentials.to_json())
    print("token.json guardado ✅ (credencial local, nunca se sube a GitHub)")


if __name__ == "__main__":
    main()
