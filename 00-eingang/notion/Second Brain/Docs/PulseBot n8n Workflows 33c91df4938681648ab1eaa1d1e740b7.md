# PulseBot n8n Workflows

Created: 9. April 2026 00:11
Doc ID: DOC-26
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 00:11
Lifecycle: Active
Notes: Technische Spec der 3 PulseBot n8n Workflows mit Node-Flows, Slack 3s-Timeout-Pattern, Lab-Email-Constraint. Stable weil Workflows produktiv im Einsatz sind.
Pattern Tags: Webhook
Project: PulsePeptides (../Projects/PulsePeptides%2033c91df4938681e781dbeee84f9ee3f7.md)
Stability: Stable
Stack: Python, n8n
Verified: No

## Scope

Vollständige technische Dokumentation der 3 n8n Workflows für PulseBot (Slack-basiertes Batch-Management). Enthält Node-Flows, kritische Patterns und Credentials-Referenz.

## Architecture / Constitution

- **Platform:** n8n Cloud
- **Interface:** Slack Slash Command `/pulse` mit Subcommands
- **Datenspeicher:** Google Sheet (kalani drive) als Single Source of Truth mit 17 Spalten
- **3 Workflows:** PulseBot Router (34 Nodes), PulseBot Interactivity (35 Nodes), Janoshik Backfill (16 Nodes)

## Google Sheet — 17 Spalten

Batch Number · Product Name · Strength · Form · Supplier · Test Type · Status · Date Created · Order Tracking · Date Received · Date Sent to Lab · Test Tracking · HPLC Link · HPLC Result · Endotoxin Link · Endotoxin Result · Notes

## Verfügbare Commands

| Command | Funktion |
| --- | --- |
| `/pulse` | Dashboard mit Batch-Zahlen pro Status |
| `/pulse order` | Neue Bestellung (Modal: Produkt, Stärke, Supplier, Form, Test Type, Tracking) |
| `/pulse receive` | Wareneingang — gruppiert nach Tracking-Nummer mit Bestätigungs-Buttons |
| `/pulse lab` | Batches ans Labor schicken — Multi-Select → HTML-E-Mail an Janoshik → Status=Testing |
| `/pulse tracking` | Tracking-Nummer nachträglich zuordnen |
| `/pulse status` | Alle Batches gruppiert nach Status |
| `/pulse untested` | Offene Batches (nicht Active/Archived) |
| `/pulse batch` | Batch-Liste mit Detail-Buttons |

## WF1: PulseBot Router (34 Nodes)

Empfängt alle `/pulse` Slash Commands. Switch Node routet per Subcommand.

### Node-Flow

```
Webhook
└── Switch (per Subcommand)
    ├── /pulse         → Load Batches → Build Dashboard → Send Dashboard
    ├── /pulse order   → Open Order Modal (direkt trigger_id)
    ├── /pulse status  → Load Status → Build Status → Send Status
    ├── /pulse untested→ Load Untested → Build Untested → Send
    ├── /pulse batch   → Load Batches For Selection → Build Batch Buttons → Send
    ├── /pulse receive → Load Ordered → Has Ordered?
    │                     ├── JA  → Build Receive Modal → Send Receive List
    │                     └── NEIN→ Send No Batches
    ├── /pulse tracking→ Load For Tracking → Has Untracked?
    │                     ├── JA  → Build Tracking Modal → Open Tracking Modal
    │                     └── NEIN→ Respond No Data
    ├── /pulse lab     → Load Received → Has Received?
    │                     ├── JA  → Build Lab Modal → Send Lab List
    │                     └── NEIN→ Send No Received
    └── Unknown        → Unknown Command
```

### Slack 3-Sekunden-Timeout Pattern

- Bei Modal-Branches: parallel `Respond to Webhook (No Data)` sofort senden
- Dann async Daten über `response_url` nachliefern
- `/pulse order` öffnet Modal direkt (kein async nötig, da kein Sheet-Load)

## WF2: PulseBot Interactivity (35 Nodes)

Empfängt alle Modal-Submissions und Button-Klicks von Slack.

### Node-Flow

```
Webhook
└── Parse Payload (Code) — extrahiert type, callback_id, payload
    └── Switch (Route Action: {type}_{callback_id})
        ├── view_order_modal       → Get All Batches → Generate Batch ID
        │                            → Append row in sheet → Send a message (Slack confirm)
        ├── block_actions_batch    → Find Clicked Batch → Build Click Detail → Send Click Response
        ├── block_actions_receive  → Ask Confirm Single → Send Confirm Single
        ├── view_receive_confirm   → Load For Receive → Prepare Receive → Build Receive Updates
        │                            → Update Received → Build Receive Response → Send Receive Response
        ├── block_actions_tracking → Prepare Tracking Updates → Update row → Ask Confirm Tracking → Send Confirm Tracking
        ├── block_actions_lab      → Load Lab Batches → Build Lab Select Modal → Open Lab Modal
        ├── view_lab_submit        → Load Lab Submit Batches → Build Lab Email
        │                            → Send Lab Email (Gmail) — MUSS erfolgreich sein!
        │                            → Build Lab Updates → Update Lab Status → Send a message1
        └── Unknown                → Unknown Command
```

## Edge Cases — Wichtige Patterns

### Button → Modal Pattern

`trigger_id` läuft nach 3s ab. Deshalb: Nachricht mit Button schicken → Klick gibt frischen `trigger_id` → Modal öffnet sich sauber.

### Lab-Email Constraint

Gmail `Send Lab Email` MUSS erfolgreich sein bevor `Update Lab Status` ausgeführt wird. Fehler in der Mail = kein Status-Update.

### Parallele Verbindungen

Immer `.first()` statt `.item` verwenden — verhindert Fehler bei parallelen Branch-Outputs.

### Test-Type Mapping

- Im Sheet: `"Both"`
- In der Anzeige: `"HPLC + Endotoxin"`

## WF3: Janoshik Backfill (16 Nodes) — Einmalig

Einmaliger Flow zur Nachverarbeitung von 32 historischen Janoshik-Test-Links. Details siehe Doc "Janoshik OCR Pipeline".

## Credentials-Referenz

| Service | Credential |
| --- | --- |
| Slack | PulseBot API |
| Google Sheets | kalani drive |
| Gmail | adler |
| Browserless | — |
| OpenAI | GPT-4o |