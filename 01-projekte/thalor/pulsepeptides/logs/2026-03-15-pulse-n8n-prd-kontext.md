---
typ: log
projekt: "[[pulsepeptides]]"
datum: 2026-03-15
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["n8n", "slack", "google-sheets", "gmail"]
---

**Projekt-Kickoff PulsePeptides.** Chat "Pulse n8n" (308 Messages, 426k chars). Kontext-Doku + PRD erstellt durch Frage-Antwort-Dialog.

## Ergebnis

- `context.md` für PulsePeptides angelegt (als Claude-Projekt-Kontext)
- PRD für Batch-Management-System
- Arbeitsweise für Claude definiert:
  - Flows Schritt für Schritt bauen
  - Jeden Schritt erklären, Bestätigung abwarten
  - Credentials **nie** selbst eintragen, immer User anleiten
  - Bei Fehlern zuerst Ursache analysieren, dann Lösung
  - Nie kompletten Flow auf einmal generieren
  - Immer vorherigen Schritt testen bevor weitergebaut

## Technischer Kontext (gelocked)

- n8n Cloud als Automation-Engine
- Slack Slash Commands als primäre UI
- Testergebnisse per Email von Janoshik
- Daten in Google Sheet + Google Drive

## Quelle

Claude-Chat "Pulse n8n" 2026-03-15.
