#!/usr/bin/env python3
"""Envía un correo con TU Gmail autorizado.

Usos:
  gmail_enviar.py destino@gmail.com                      # correo de prueba del taller
  gmail_enviar.py --to destino@x.com --subject "Asunto" --body-file cuerpo.txt
  gmail_enviar.py --to destino@x.com --subject "Asunto" --body "Texto del correo"
"""
import argparse
import base64
import os
import sys
from email.message import EmailMessage

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

AQUI = os.path.dirname(os.path.abspath(__file__))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("destino", nargs="?", help="destinatario (modo prueba si no hay --subject/--body)")
    p.add_argument("--to", dest="to")
    p.add_argument("--subject")
    p.add_argument("--body")
    p.add_argument("--body-file")
    a = p.parse_args()

    destino = a.to or a.destino
    if not destino:
        p.error("falta el destinatario")

    creds = Credentials.from_authorized_user_file(os.path.join(AQUI, "token.json"))
    if creds.expired and creds.refresh_token:
        creds.refresh(Request())

    svc = build("gmail", "v1", credentials=creds)
    yo = svc.users().getProfile(userId="me").execute()["emailAddress"]

    cuerpo = a.body
    if a.body_file:
        with open(a.body_file, encoding="utf-8") as f:
            cuerpo = f.read()
    if cuerpo is None:
        cuerpo = (
            "Hola!\n\nEste correo lo envió mi agente de IA montado en el taller "
            f"(OpenClaw + FreeLLMAPI + Gmail).\n\nEnviado desde: {yo}\n"
        )
    asunto = a.subject or "Prueba taller agentes IA ✅"

    msg = EmailMessage()
    msg["To"] = destino
    msg["From"] = yo
    msg["Subject"] = asunto
    msg.set_content(cuerpo)
    raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
    res = svc.users().messages().send(userId="me", body={"raw": raw}).execute()
    print(f"Correo enviado desde {yo} hacia {destino} | asunto: {asunto} | id={res['id']}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # mensaje corto para que el agente lo entienda
        print(f"ERROR al enviar: {e}", file=sys.stderr)
        sys.exit(1)
