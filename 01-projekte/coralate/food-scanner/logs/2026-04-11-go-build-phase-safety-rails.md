---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-11
art: entscheidung
vertrauen: bestaetigt
quelle: manuell
werkzeuge: ["supabase"]
---

Go erteilt für Migration, Import, Edge Function, HTML Test-Tool. Supabase vorbereitet: `food-scans` Bucket angelegt, `raw-nutrition-data` mit 5 DBs gefüllt (BLS, CIQUAL 2025, USDA Foundation 2025-12, USDA SR Legacy 2018-04, CoFID 2021, NEVO 2025 v9.0). OFF via CSV-Stream. OPENAI_API_KEY als Supabase-Secret gesetzt.

## Scope-Anpassung

TürKomp und STFCJ raus aus v0. Bleibt: BLS, CIQUAL 2025, USDA Foundation, USDA SR Legacy, CoFID 2021, NEVO 2025 + OFF Stream.

## Hard Safety Constraints für Build

1. `food_entries` darf bearbeitet werden
2. Alle Cora-AI-Tabellen (`cora_memories`, `cora_facts`, `cora_call_queue`, `ai_suggestions`, `knowledge_chunks`…) sind **TABU**
3. `profiles` und `workouts` sind **TABU** (Jann)
4. Alles muss reversibel sein (Migrations mit Rollback)
5. Jeder Schritt in neuem Build-Doc dokumentiert
6. Plan-and-Execute strikt

## OFF Import-Strategie

Python-Script streamt direkt von `static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz`, dekomprimiert on-the-fly, filtert EU-Länder + vollständige Nährwerte, mapped via INFOODS, embeddet via `text-embedding-3-small`, insertet in `nutrition_db`. Resumable via Checkpoint. Kein lokaler Download, kein Supabase-Upload.
