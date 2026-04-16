# Borrowing läuft, food_scan_cache + Edge Function nächste Schritte

Areas: coralate
Confidence: Confirmed
Created: 12. April 2026 15:15
Date: 12. April 2026
Gelöscht: No
Log ID: LG-7
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Claude session
Summary: Borrowing Pass 1 live, 3-Pass-Strategie ausgearbeitet. Jann Voice-Call bestätigt Ingredient-Korrektur-Anforderungen. food_scan_cache Schema-Update + Edge Function nächste Schritte.
Type: Progress

**Verweis Status-Doc:** [Food Scanner Status](../Docs/Food%20Scanner%20Status%20%E2%80%94%20STEP%203%20Done,%20Pipeline%20Adjust%2034091df4938681989eaadf7eba915b3e.md)

## Was passiert ist

- Cross-DB Borrowing Pass 1 live: threshold 0.55, min 2 Nachbarn, Top-20-Pool
- Script läuft lokal auf Deniz' Rechner, ~1h20 ETA
- 3-Pass-Strategie bestätigt: Pass 1 (0.55/2) → Pass 2 (0.6/3 `--resume`) → Pass 3 (0.65/4 `--resume`)
- Self-Healing-Mechanik: mit jedem Pass wächst der Nachbarschafts-Pool, striktere Kriterien finden trotzdem mehr Hits
- SQL-Funktion `borrow_missing_nutrients_v2(id, threshold, min_n)` parametrisch in DB deployed

## Jann Voice-Call — Pipeline-Adjustments

Ergänzend zu den früheren Anpassungen (client-side Barcode, per-Ingredient-Breakdown) bekräftigt:

- User muss Gramm-Werte pro Ingredient editieren
- Neue Zutaten hinzufügen, bestehende entfernen
- Nach Re-submit frische Totals erwarten
- `food_scan_cache` muss Original + Korrektur separat speichern für Feedback-Flywheel

## Nächster Schritt

1. `food_scan_cache` Schema erweitern (ALTER TABLE, 4 neue Spalten)
2. Edge Function `food-scanner` bauen (Dual-Flow + Recalculate-Endpoint)
3. HTML Test-Tool für Deniz zum eigenen Testen

## BLS/USDA food_groups

Parkiert — wird nicht gebraucht weil Borrowing food_group nicht als Filter nutzt, nur Embeddings. Später optional als Qualitäts-Guardrail.