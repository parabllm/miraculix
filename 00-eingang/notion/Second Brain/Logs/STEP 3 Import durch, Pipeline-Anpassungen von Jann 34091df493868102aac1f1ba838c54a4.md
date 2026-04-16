# STEP 3 Import durch, Pipeline-Anpassungen von Jann

Areas: coralate
Confidence: Confirmed
Created: 12. April 2026 14:44
Date: 12. April 2026
Gelöscht: No
Log ID: LG-6
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Claude session
Summary: STEP 3 abgeschlossen. 23.623 Foods in Supabase. Pro Plan geholt. Jann-Feedback triggert zwei Edge-Function-Anpassungen (Barcode-Dual-Flow, Per-Ingredient-Breakdown). Nächster Step: Cross-DB Borrowing.
Type: Progress

**Verweis auf Status-Doc:** [Food Scanner Status — STEP 3 Done](../Docs/Food%20Scanner%20Status%20%E2%80%94%20STEP%203%20Done,%20Pipeline%20Adjust%2034091df4938681989eaadf7eba915b3e.md)

## Was gemacht wurde

- STEP 3 Python Import-Script final gebaut und lokal auf Windows ausgeführt
- 6 wissenschaftliche DBs importiert: **23.623 Foods mit Embeddings in Supabase**
- Supabase Free-Tier Storage-Limit gerissen → Upgrade auf Pro Plan
- USDA Foundation von 11k Lab-Sample-Noise auf 135 echte Foods gefiltert
- OFF getestet (2.500 Rows) → Mikro-Coverage zu dünn (15% Minerals, 2% Vitamine) → gelöscht, parkiert bis v1.1

## Jann-Updates die Plan ändern

- **Barcode wird client-side dekodiert** → Edge Function kriegt Barcode-String direkt, kein Vision-Call für Packaged Foods
- **User muss Gramm-Werte pro Ingredient editieren können** → Response braucht per-Ingredient-Nutrient-Breakdown, neuer Recalculate-Endpoint

## Nächster Schritt

STEP 3.5 Cross-DB Borrowing (SQL-Migration, pure pgvector, keine API-Kosten) → dann STEP 4 Edge Function