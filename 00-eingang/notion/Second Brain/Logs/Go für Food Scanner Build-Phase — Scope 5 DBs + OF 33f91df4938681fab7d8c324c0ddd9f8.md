# Go für Food Scanner Build-Phase — Scope 5 DBs + OFF, Safety-Rails definiert

Areas: coralate
Confidence: Confirmed
Created: 12. April 2026 00:12
Date: 11. April 2026
Gelöscht: No
Log ID: LG-5
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Manual
Type: Decision

# Go für Build-Phase erteilt

Deniz hat Go gegeben für Migration, Import, Edge Function, HTML Test-Tool. Supabase vorbereitet: food-scans Bucket angelegt, raw-nutrition-data Bucket mit 5 DBs gefüllt (BLS, CIQUAL 2025, USDA Foundation+SR Legacy, CoFID, NEVO — Türkei und Japan raus), OPENAI_API_KEY Secret gesetzt. Dieser Chat ist Token-technisch am Ende, nächster Chat übernimmt mit frischem Budget.

# Scope-Anpassung

TürKomp und STFCJ sind aus dem v0 Scope raus. Bleibt: BLS, CIQUAL 2025, USDA Foundation 2025-12, USDA SR Legacy 2018-04, CoFID 2021, NEVO 2025 v9.0 + OFF via CSV-Stream.

# Hard Safety Constraints für Build-Phase

1. food_entries darf bearbeitet werden
2. Alle Cora AI Tabellen (cora_memories, cora_facts, cora_call_queue, ai_suggestions, knowledge_chunks usw.) sind TABU
3. profiles und workouts sind TABU (Jann)
4. Alles ab jetzt muss reversibel sein (Migrations mit Rollback)
5. Jeder Schritt wird in einem neuen Build-Doc dokumentiert damit andere Chats den State verstehen
6. Plan-and-Execute strikt

# OFF Import-Strategie

Python Script streamt direkt von [static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz](http://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz), dekomprimiert on-the-fly, filtert auf EU-Länder + vollständige Nährwerte, mapped via INFOODS, embeddet via text-embedding-3-small, insertet in nutrition_db. Resumable via Checkpoint. Kein lokaler Download, kein Supabase Upload.

# Next Chat

Follow-Up-Prompt ist im Food Scanner Master Doc hinterlegt. Neuer Chat startet mit Schema-Extraktion der 5 DBs via bash_tool, dann Unified Schema, Migration, Import, Edge Function, Test-Tool. Alles Plan-and-Execute.