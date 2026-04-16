---
typ: sub-projekt
name: "PulsePeptides"
aliase: ["PulsePeptides", "Pulse", "Pulse Peptides", "PulseBot"]
ueber_projekt: "[[thalor]]"
bereich: client_work
umfang: offen
status: aktiv
kapazitaets_last: mittel
kontakte: ["[[kalani-ginepri]]"]
tech_stack: ["n8n", "slack", "google-sheets", "gmail", "browserless", "openai"]
notion_url: ""
erstellt: 2026-04-16
notizen: "Peptide-E-Commerce, Batch-Management via PulseBot (Slack) + n8n Cloud + Google Sheets. Unbezahltes Referenzprojekt."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

Internes Batch-Management für kompletten Batch-Lifecycle (Order → Receive → Lab → Active → Archive) über **Slack-Bot + n8n + Google Sheets** für Kalani Ginepris Peptide-E-Commerce. Plus OCR-Pipeline für Janoshik-Labor-Testergebnisse.

- **Stack:** n8n Cloud, Slack (PulseBot), Google Sheets (SSOT, 17 Spalten), Gmail, Browserless, OpenAI GPT-4o
- **Primäre Interface:** Slack Slash-Command `/pulse` mit Subcommands
- **Externes Labor:** Janoshik (HPLC + Endotoxin-Tests)
- **Batch-ID-Schema:** `{SupplierCode}{YY}{Q#}{Seq}{ProductCode}` - z.B. `LP26Q11BPC`
- **Status-Lifecycle:** Ordered → Received → Testing → Partially Tested → Active → Archived

**3 n8n-Workflows:**
1. PulseBot Router
2. PulseBot Interactivity
3. Janoshik Backfill

**Kritische Patterns:**
- Slack 3s-Timeout → async Response-Pattern (sofort ACK, Worker hinterher)
- Gmail Send Lab Email MUSS erfolgreich sein bevor Status-Update (Reliability-Gate)

## Aktueller Stand

Stand 2026-04-15: Chat "Pulse Peptides Admin Hub Angebot bewerten" - Kalani evaluiert Admin-Hub-Angebot. Vorherige Implementierung (PulseBot, Janoshik OCR) läuft produktiv.

## Offene Aufgaben

_(werden aus Claude-Logs destilliert in Phase D)_

## Out of Scope

- E-Commerce-Frontend / Shop-System
- Kundendaten-Management
- Payment-Abwicklung

## Kontakte

- [[kalani-ginepri]] - Auftraggeber, Entscheider
