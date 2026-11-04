#!/usr/bin/env python3
"""Autoriza tu Gmail para el taller — guarda token.json (no se sube a git)."""
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = [
    "https://www.googleapis.com/auth/gmail.send",
    "https://www.googleapis.com/auth/gmail.readonly",
]

def main():
    flow = InstalledAppFlow.from_client_secrets_file("client_secret_taller.json", SCOPES)
    creds = flow.run_local_server(port=0, prompt="consent")
    with open("token.json", "w") as f:
        f.write(creds.to_json())
    print("token.json guardado ✅ (credencial local, nunca se sube a GitHub)")

if __name__ == "__main__":
    main()
