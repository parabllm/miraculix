# Coralate Food Scanner Skill — Verdichtetes Wissen

Created: 12. April 2026 00:22
Doc ID: DOC-50
Doc Type: Reference
Gelöscht: No
Last Edited: 12. April 2026 00:22
Last Reviewed: 11. April 2026
Lifecycle: Active
Notes: Skill-Dokument für alle Food Scanner Sessions.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: Supabase
Verified: Yes

# Zweck

Skill-Dokument für alle zukünftigen Claude-Sessions am coralate Food Scanner. Verdichtetes Wissen aus 6 Research-Rounds und Architecture-Sessions.

# Core Architecture

**3-Tier Hybrid:** Tier 0 OFF Live API Barcodes, Tier 1 GPT-4o Vision + pgvector, Tier 3 GPT-4o Synthesis + Feedback Flywheel. Tier 2 SKIPPED.

**Harmonisierung:** INFOODS-Codes FAO-Standard. Mapping über Codes, nicht Spaltennamen.

**Storage:** EINE nutrition_db mit source-Flag, NICHT pro Land. pgvector durchsucht parallel, RRF re-rankt.

**Einziger Secret:** OPENAI_API_KEY.

# 19 Core Nutrients

**Makros:** ENERC kcal, PROCNT g, FAT g, CHOAVL g, FIBTG g

**Mikros:** NA, K, CA, FE, MG, ZN (mg), VITA_RAE μg, VITD μg, VITE mg, VITC mg, THIA, RIBF, NIA, VITB6A mg, FOLDFE μg. Alle per 100g edible.

# Hard Constraints

1. Qualität > Latenz > Cost
2. Geo NIEMALS Hard Filter, nur RRF k=60
3. Output-Konsistenz: keine Nulls, 19 Felder strukturell
4. Internationale Coverage Pflicht
5. DSGVO Position 3 Pre-Launch
6. Plan-and-Execute strikt
7. Loggen nur auf Anweisung
8. Alles reversibel, Rollback pro Migration

# NULL-Imputation Kaskade

1. Cross-DB Borrowing via semantic neighbors
2. Recipe-Based Reconstruction mit Bognár-Faktoren
3. OFF-Ergänzung für Markenprodukte
4. Imputed Flag mit food_group median

Jeder Wert hat Provenance {method, source, confidence}.

# Gelöste Fallen

- FatSecret US-only Free
- Edamam kein Free Dev Tier
- Gemini 2.5 Flash bricht 56% Vision-Schema
- Self-Reported Confidence in JSON = Theater
- Geo als Hard Filter zerstört Cross-Country-Matching
- Separate Tabellen pro Land zerstören RRF
- Pure pgvector API-frei reicht nicht global
- n8n 60s Timeout
- MLLMs priorisieren Kontext in 93% Fälle, XML ThinkFirst Pflicht

# RRF Pattern

```
RRF = 1/(60 + rank_semantic) + 1/(60 + rank_geo)
```

Semantik Haupttreiber, Geo nur Tiebreaker.

# ThinkFirst Prompt

XML-getaggt. Modell verbalisiert erst Bild bevor user_context gelesen wird. Priorität visual > text > context. Konflikt: trust the image.

# Supabase

- vviutyisqtimicpfqbmi, eu-west-1
- Extensions: vector, pgmq
- Buckets: food-scans, raw-nutrition-data
- Edge Functions: cora-engine (existiert), food-scanner (zu bauen)

# Tabu-Tabellen

cora_memories, cora_facts, cora_call_queue, ai_suggestions, knowledge_chunks, profiles, workouts, workout_sessions, exercises, food_day_records, Auth, bestehende RLS.

# Bearbeitbar

food_entries (Erweiterung), nutrition_db (neu), food_scan_cache (neu).

# Referenzen

- Food Scanner Master — Stack, DB-Harmonisierung, Build-Plan
- Food Scanner Execution Plan — Step-by-Step
- Food Scanner Build Log — Safety, Sequence, Sessions
- Daily Logs: V5.1 Reports, Phase 1 Uploads, Build-Phase Go

# DB-Details Phase 1

- **BLS 4.0** DE ~7.140 Foods, 138 Spalten
- **CIQUAL 2025** FR 3.484 Foods × 74 Komponenten, 2 Tabs, per 100g edible, A-D Confidence, Missing=dash
- **USDA Foundation 2025-12 + SR Legacy 2018-04** food.csv + food_nutrient.csv + nutrient.csv, Mapping via nutrient_nbr
- **CoFID 2021** UK xlsx Proximates + Inorganics + Vitamins Tabs
- **NEVO 2025 v9.0** NL
- TürKomp + STFCJ aus v0 raus, v0.5 Nachzug

# OFF Import

HTTP-Stream von [static.openfoodfacts.org](http://static.openfoodfacts.org), on-the-fly gzip, Filter EU + vollständige Nährwerte, INFOODS-Mapping, Batch-Embedding, Upsert. Kein Download, kein Supabase Upload.

# Für jede neue Session

Lies zusätzlich Execution Plan und Build Log bevor du Code schreibst. Safety-Boundaries strikt. Keine Logs ohne Anweisung. Plan-and-Execute: Vorschlag → Freigabe → Umsetzung → Session Log Update.