#!/usr/bin/env python3
"""Envia un correo de prueba con tu Gmail autorizado. Uso: gmail_enviar.py destino@gmail.com"""
import sys
from email.message import EmailMessage
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

def main():
    destino = sys.argv[1] if len(sys.argv) > 1 else ""
    if not destino:
        print("Uso: gmail_enviar.py destino@gmail.com"); sys.exit(1)

    creds = Credentials.from_authorized_user_file("token.json")
    if creds.expired and creds.refresh_token:
        creds.refresh(Request())

    svc = build("gmail", "v1", credentials=creds)
    yo = svc.users().getProfile(userId="me").execute()["emailAddress"]

    msg = EmailMessage()
    msg["To"] = destino
    msg["From"] = yo
    msg["Subject"] = "Prueba taller agentes IA ✅"
    msg.set_content(
        f"Hola!\n\nEste correo lo envio mi agente de IA montado en el taller "
        f"(OpenClaw + FreeLLMAPI + Gmail).\n\nEnviado desde: {yo}\n"
    )
    mid = svc.users().messages().send(userId="me", body={"raw": __import__("base64").urlsafe_b64encode(msg.as_bytes()).decode()}).execute()
    print(f"Correo enviado desde {yo} hacia {destino} | id={mid['id']}")

if __name__ == "__main__":
    main()
