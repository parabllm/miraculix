---

## typ: aufgabe name: "Janoshik OCR Pipeline" projekt: "[[pulsepeptides]]" status: erledigt benoetigte_kapazitaet: mittel kontext: \["desktop"\] kontakte: \[[kalani-ginepri]]"\] quelle: notion_migration vertrauen: extrahiert erstellt: 2026-04-16

OCR-Pipeline die Janoshik Labor-Testergebnisse automatisch aus Screenshots extrahiert und ins Google Sheet schreibt. Backfill-Workflow einmalig ausgeführt, Mail-Check-Flow als Extension geplant.

## Architektur

- **Externes Labor:** Janoshik ([janoshik.com](http://janoshik.com))
- **Test-Typen:** HPLC (Reinheit/Konzentration) und Endotoxin (Sterilität)
- **Ergebnis-Format:** Öffentliche Result-URL pro Test
- **OCR-Stack:** Browserless (Headless Chrome) + OpenAI GPT-4o + Google Drive (Base64-Übergabe)

## Test-Typen

TestAnalyseHPLCReinheits- und KonzentrationsanalyseEndotoxinSterilität / Endotoxin-Belastung

Jeder Test liefert eine öffentliche Result-URL, die im Google Sheet gespeichert wird.

## Backfill Workflow (WF3) - einmalig

Zur Initialbefüllung des Sheets (32 historische Janoshik-Test-Links) genutzt.

```
Manual Trigger
└── All Links (Code) - hardcoded Array mit 32 URLs
    └── Loop Over Items (SplitInBatches)
        └── Screenshot (HTTP → Browserless) - macht Screenshot der Test-Seite
            └── Drive Upload → Drive Download
                └── OCR Analyze (OpenAI GPT-4o) - extrahiert Testergebnisse
                    └── Parse OCR (Code) - strukturiert Output
                        └── Rename File (Drive)
                            └── Valid Batch? (IF)
                                ├── JA  → Find Batch (Sheets)
                                │         └── Row Exists? (IF)
                                │              ├── JA  → Update Test Results → Update Sheet Row
                                │              └── NEIN→ Create New Batch → Append New Batch
                                └── NEIN→ (Skip)
```

### OCR-Logik

- Erkennt HPLC vs. Endotoxin Tests automatisch
- Setzt `Test Type = "Both"` wenn beide Tests auf einer Seite
- Berechnet Status automatisch nach Ergebnissen
- `Valid Batch?` filtert Seiten ohne auswertbare Testergebnisse

### Credentials

- Browserless (Headless Chrome für Screenshots)
- OpenAI GPT-4o (OCR + Datenextraktion)
- Google Drive (temporärer File-Upload/Download für Base64-Übergabe)
- Google Sheets (kalani drive)

## Planned Extension: Mail Check Flow

Geplant: automatische Verarbeitung laufender Testergebnisse statt manueller Nachpflege. Zweck: Erkennen wenn Janoshik Testergebnisse per E-Mail schickt → Sheet automatisch updaten.

### `determine_status()` Logik

```js
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

### Flow-Struktur (geplant)

```
Gmail Trigger (Janoshik Absender)
└── Parse E-Mail - Batch-ID und Test-Typ extrahieren
    └── Find Batch in Sheet
        └── Determine Status
            └── Update Sheet Row (Result-Link + Status)
                └── Slack Notification → Kalani
```
