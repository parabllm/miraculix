---
typ: log
projekt: "[[pulsepeptides]]"
datum: 2026-03-17
art: fortschritt
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["n8n", "openai", "gmail", "browserless", "google-sheets"]
---

Janoshik Testergebnisse-Flow gebaut. Chat "Janoshik Testergebnisse Flow" (144 Messages, 297k chars).

## OCR-Pipeline

Lab-Report-Parsing-Flow: Gmail (Janoshik-Email) → Browserless (PDF-Extract) → OpenAI GPT-4o (strukturiertes JSON-Output) → Google Sheet-Update.

**Reliability-Gate:** Gmail-Send-Lab-Email MUSS erfolgreich sein **bevor** Status-Update in Google Sheet passiert. Wenn Gmail failed → Status bleibt im vorigen State → Retry-Mechanik greift.

## Quelle

Claude-Chat "Janoshik Testergebnisse Flow" 2026-03-17.
