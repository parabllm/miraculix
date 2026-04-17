---
typ: log
projekt: "[[pulsepeptides]]"
datum: 2026-03-19
art: entscheidung
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["n8n", "slack", "google-sheets"]
---

Pulse-Restrukturierung. Chat "Pulse Restrukturierung" (270 Messages, 599k chars) + Folge-Chat "Pulse Neuer Workflow Plan" (16 Messages, 74k chars).

## Architektur-Rework

3 n8n-Workflows definiert:
1. **PulseBot Router** - Slash-Command-Dispatcher
2. **PulseBot Interactivity** - Button/Modal-Responder (Slack 3s-Timeout Pattern)
3. **Janoshik Backfill** - periodischer Abgleich Labor-Ergebnisse

**Slack 3s-Timeout Pattern** etabliert: Sofort ACK, Worker-Node hinterher, User erfährt via Update-Message.

## Single Source of Truth

Google Sheet mit 17 Spalten (Batch-Daten + Test-Ergebnisse). **Status-Lifecycle:** Ordered → Received → Testing → Partially Tested → Active → Archived.

## Batch-ID-Schema

`{SupplierCode}{YY}{Q#}{Seq}{ProductCode}` - z.B. `LP26Q11BPC`.

## Quelle

Claude-Chats "Pulse Restrukturierung" + "Pulse Neuer Workflow Plan" 2026-03-19.
