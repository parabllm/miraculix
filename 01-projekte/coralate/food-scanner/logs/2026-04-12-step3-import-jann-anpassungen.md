---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-12
art: fortschritt
vertrauen: bestaetigt
quelle: chat_session
werkzeuge: ["supabase", "python"]
---

STEP 3 abgeschlossen. **23.623 Foods mit Embeddings in Supabase** (6 wissenschaftliche DBs). Supabase Free-Tier gerissen → Upgrade auf Pro.

## Import-Details

- Python-Import-Script final gebaut, lokal auf Windows ausgeführt
- USDA Foundation von 11k Lab-Sample-Noise auf 135 echte Foods gefiltert
- OFF getestet (2.500 Rows): Mikro-Coverage zu dünn (15% Minerals, 2% Vitamine) → **gelöscht, parkt bis v1.1**

## Jann-Feedback → Plan-Änderung

- **Barcode wird client-side dekodiert** → Edge Function kriegt Barcode-String direkt, kein Vision-Call für Packaged Foods
- **User muss Gramm-Werte pro Ingredient editieren können** → Response braucht per-Ingredient-Nutrient-Breakdown + neuer Recalculate-Endpoint

## Nächster Schritt

STEP 3.5 Cross-DB Borrowing (SQL-Migration, pure pgvector, keine API-Kosten) → dann STEP 4 Edge Function.
