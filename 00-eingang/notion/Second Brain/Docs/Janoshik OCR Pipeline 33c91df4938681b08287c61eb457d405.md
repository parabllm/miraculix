# Janoshik OCR Pipeline

Created: 9. April 2026 00:11
Doc ID: DOC-27
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 00:11
Lifecycle: Active
Notes: Janoshik OCR Backfill-Flow + Spec für geplanten Mail-Check Flow mit determine_status() Logik. Stable weil Spec technisch fixiert ist.
Pattern Tags: Enrichment, OCR
Project: PulsePeptides (../Projects/PulsePeptides%2033c91df4938681e781dbeee84f9ee3f7.md)
Stability: Stable
Stack: Python, n8n
Verified: No

## Scope

OCR-Pipeline die Janoshik Labor-Testergebnisse automatisch aus Screenshots extrahiert und ins Google Sheet schreibt. Enthält den Backfill-Workflow (einmalig) sowie die Spec für einen geplanten Mail-Check Flow (Automatisierung der laufenden Testergebnis-Verarbeitung).

## Architecture / Constitution

- **Externes Labor:** Janoshik ([janoshik.com](http://janoshik.com))
- **Test-Typen:** HPLC (Reinheit/Konzentration) und Endotoxin (Sterilität)
- **Ergebnis-Format:** Öffentliche Result-URL pro Test
- **OCR-Stack:** Browserless (Headless Chrome) + OpenAI GPT-4o + Google Drive (Base64-Übergabe)

## Test-Typen

| Test | Analyse |
| --- | --- |
| **HPLC** | Reinheits- und Konzentrationsanalyse |
| **Endotoxin** | Sterilität / Endotoxin-Belastung |

Jeder Test liefert eine öffentliche Result-URL die im Google Sheet gespeichert wird.

## Backfill Workflow (WF3) — Einmalig

Einmaliger Flow — wurde zur Initialbefüllung des Sheets genutzt (32 historische Janoshik-Test-Links).

### Node-Flow

```
Manual Trigger
└── All Links (Code) — hardcoded Array mit 32 URLs
    └── Loop Over Items (SplitInBatches)
        └── Screenshot (HTTP → Browserless) — macht Screenshot der Test-Seite
            └── Drive Upload → Drive Download
                └── OCR Analyze (OpenAI GPT-4o) — extrahiert Testergebnisse
                    └── Parse OCR (Code) — strukturiert Output
                        └── Rename File (Drive)
                            └── Valid Batch? (IF)
                                ├── JA  → Find Batch (Sheets)
                                │         └── Row Exists? (IF)
                                │              ├── JA  → Update Test Results (Code) → Update Sheet Row
                                │              └── NEIN→ Create New Batch (Code) → Append New Batch
                                └── NEIN→ (Skip)
```

### OCR-Logik

- Erkennt **HPLC** vs. **Endotoxin** Tests automatisch
- Setzt `Test Type = "Both"` wenn beide Tests auf einer Seite vorliegen
- Berechnet Status automatisch nach Ergebnissen
- `Valid Batch?` filtert Seiten ohne auswertbare Testergebnisse

### Credentials

- **Browserless** — Headless Chrome für Screenshots
- **OpenAI GPT-4o** — OCR + Datenextraktion
- **Google Drive** — Temporärer File-Upload/Download für Base64-Übergabe
- **Google Sheets** — kalani drive

## Planned Extension: Mail Check Flow

Geplanter Flow für automatische Verarbeitung laufender Testergebnisse statt manueller Nachpflege.

### Zweck

Automatisches Erkennen wenn Janoshik Testergebnisse per E-Mail schickt → Sheet automatisch updaten.

### `determine_status()` Logik

```jsx
function determine_status(hplc_result, endotoxin_result, test_type) {
  if (test_type === "HPLC") {
    return hplc_result ? "Active" : "Testing";
  }
  if (test_type === "Endotoxin") {
    return endotoxin_result ? "Active" : "Testing";
  }
  if (test_type === "Both") {
    if (hplc_result && endotoxin_result) return "Active";
    if (hplc_result || endotoxin_result) return "Partially Tested";
    return "Testing";
  }
}
```

### Flow-Struktur

```
Gmail Trigger (Janoshik Absender)
└── Parse E-Mail — Batch-ID und Test-Typ extrahieren
    └── Find Batch in Sheet
        └── Determine Status
            └── Update Sheet Row (Result-Link + Status)
                └── Slack Notification → Kalani
```