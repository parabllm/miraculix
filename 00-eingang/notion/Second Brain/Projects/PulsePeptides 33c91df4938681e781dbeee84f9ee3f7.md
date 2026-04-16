# PulsePeptides

Agent Instructions: PulsePeptides = Peptide E-Commerce von Kalani. PulseBot (Slack) steuert Batch-Lifecycle via n8n Cloud. 3 Workflows: PulseBot Router, PulseBot Interactivity, Janoshik Backfill. Google Sheet mit 17 Spalten als Single Source of Truth. Bei Workflow-Fragen Docs 'PulseBot n8n Workflows' + 'Janoshik OCR Pipeline' checken. Slack 3s-Timeout Pattern beachten. Gmail Send Lab Email MUSS erfolgreich sein bevor Status-Update. Aktueller Stand offener Tasks und Features: aus Tasks DB + Logs DB lesen.
Areas: Client Work
Contacts: Kalani Ginepri (../Contacts/Kalani%20Ginepri%2033c91df4938681258cb7cf3407d00b63.md)
Created: 9. April 2026 00:10
Docs: PulseBot n8n Workflows (../Docs/PulseBot%20n8n%20Workflows%2033c91df4938681648ab1eaa1d1e740b7.md), Janoshik OCR Pipeline (../Docs/Janoshik%20OCR%20Pipeline%2033c91df4938681b08287c61eb457d405.md)
Gelöscht: No
Last Edited: 9. April 2026 00:10
Priority: 🟧 Aktiv
Project ID: PRJ-5
Status: In Progress
Tech Stack: Python, n8n
Type: Client

## Scope

Kleines Peptide E-Commerce Unternehmen. Internes Batch-Management für den kompletten Batch-Lifecycle (Order → Receive → Lab → Active → Archive) über Slack-Bot + n8n + Google Sheets. Plus OCR-Pipeline für Janoshik Labor-Testergebnisse.

## Constitution

- **Auftraggeber:** Kalani Ginepri
- **Auftragstyp:** Freelance, unbezahlt — Referenzprojekt für Agency-Aufbau
- **Stack:** n8n Cloud, Slack (PulseBot), Google Sheets, Gmail, Browserless, OpenAI GPT-4o
- **Primäre Interface:** Slack Slash Command `/pulse` mit Subcommands
- **Single Source of Truth:** Google Sheet mit 17 Spalten (Batch-Daten + Test-Ergebnisse)
- **Externes Labor:** Janoshik (HPLC + Endotoxin Tests)
- **Batch-ID Schema:** `{SupplierCode}{YY}{Q#}{Seq}{ProductCode}` — z.B. `LP26Q11BPC`
- **Status-Lifecycle:** Ordered → Received → Testing → Partially Tested → Active → Archived

## Stakeholder

- **Kalani Ginepri** (Auftraggeber, Decision Maker)

## Out of Scope

- E-Commerce-Frontend oder Shop-System
- Kundendaten-Management
- Payment-Abwicklung