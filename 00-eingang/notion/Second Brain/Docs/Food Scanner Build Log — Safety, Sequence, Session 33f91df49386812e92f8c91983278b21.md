# Food Scanner Build Log — Safety, Sequence, Sessions

Created: 12. April 2026 00:13
Doc ID: DOC-48
Doc Type: Architecture
Gelöscht: No
Last Edited: 12. April 2026 00:13
Last Reviewed: 11. April 2026
Lifecycle: Active
Notes: Build-Log für Food Scanner. Aktiv ab 2026-04-11 Abend. Safety-Boundaries und reversible Build-Sequenz definiert. Jede Session dokumentiert hier ihren Fortschritt.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Volatile
Stack: Supabase
Verified: Yes

# Zweck dieses Docs

Live-Build-Log für den Food Scanner. Jede Chat-Session die am Scanner baut, dokumentiert hier was sie gemacht hat, damit nachfolgende Sessions (auch andere Claude-Instanzen) den State exakt verstehen. Safety-kritisch weil Migrations und Code-Deployments reversibel bleiben müssen.

# Safety Boundaries (IMMUTABLE)

**Darf bearbeitet werden:**

- food_entries Tabelle (Erweiterung um Spalten erlaubt)
- Neue Tabellen anlegen: nutrition_db, food_scan_cache
- Neue Edge Function: food-scanner
- Supabase Storage Buckets food-scans und raw-nutrition-data

**TABU — niemals anfassen:**

- cora_memories, cora_facts, cora_call_queue, ai_suggestions, knowledge_chunks
- profiles (Jann)
- workouts, workout_sessions, exercises (Jann)
- food_day_records (Cora-eligible aggregates, Vorsicht)
- Auth Tabellen, RLS Policies bestehender Tabellen

**Reversibilität Pflicht:**

- Jede Migration braucht Rollback-Statement im selben Doc
- Keine DROP ohne Backup-Hinweis
- Keine destruktiven UPDATE/DELETE auf bestehende Daten
- Import-Script muss idempotent sein (bei Re-Run keine Duplikate)

# Final Stack (Stand 2026-04-11 Abend)

- Vision: GPT-4o + Strict JSON Schema + logprobs + XML ThinkFirst Prompt
- Retrieval: pgvector, EINE nutrition_db Tabelle, INFOODS-Codes als Harmonisierungs-Achse
- RRF (k=60) für Geo/Time/History als Soft Re-Ranking
- 3-Tier: Tier 0 OFF Barcode API, Tier 1 Vision+pgvector, Tier 3 GPT-4o Synthesis + Feedback Flywheel
- Einziger Secret: OPENAI_API_KEY

# Scope v0 — 5 DBs + OFF

1. BLS 4.0 Deutschland
2. CIQUAL 2025 Frankreich (3.484 Foods × 74 Komponenten, Doku analysiert)
3. USDA Foundation 2025-12
4. USDA SR Legacy 2018-04
5. CoFID UK 2021
6. NEVO 2025 v9.0 Niederlande
7. OFF via CSV-Stream (HTTP direkt, kein Upload)

**Raus aus v0:** TürKomp, STFCJ. Nachziehbar in v0.5.

# Supabase Readiness Status

- [x]  food-scans Bucket angelegt
- [x]  raw-nutrition-data Bucket mit 5 DBs befüllt
- [x]  OPENAI_API_KEY Secret gesetzt
- [ ]  pgvector Extension aktiviert (Deniz TODO, Database → Extensions → vector)

# Anforderungen (Kern)

1. **Output-Konsistenz garantiert:** Egal welches Gericht, egal welche Region — immer dieselben 14 Mikros + 5 Makros, keine Nulls im Frontend
2. **INFOODS als Harmonisierungs-Achse:** ENERC, PROCNT, FAT, CHOAVL, FIBTG, VITC, FE, NA, VITA_RAE usw.
3. **NULL-Imputation Kaskade:** Cross-DB Borrowing → Recipe-Based Reconstruction → Bognár-Faktoren → OFF-Ergänzung. Jeder Wert mit Quality-Flag (analytical/borrowed/calculated/imputed)
4. **Geo NIEMALS Hard Filter:** nur RRF Soft Re-Ranking
5. **Qualität > Latenz > Cost**

# Build-Sequenz (Plan-and-Execute)

**Schritt 1 — Schema-Extraktion (nächster Chat, zuerst)**

- bash_tool: alle 5 DBs extrahieren, Header lesen, INFOODS-Codes identifizieren
- Schema-Vergleichs-Matrix erstellen
- Unified Schema definieren
- Stand an Deniz → Freigabe abwarten

**Schritt 2 — SQL Migration (nach Freigabe)**

- CREATE EXTENSION vector
- CREATE TABLE nutrition_db mit 19 Pflicht-Spalten + embedding vector(1536)
- CREATE TABLE food_scan_cache
- ALTER TABLE food_entries für fehlende Mikro-Spalten
- Rollback-SQL im gleichen File
- Stand an Deniz → Freigabe abwarten

**Schritt 3 — Python Import-Script**

- 5 DBs aus raw-nutrition-data Bucket lesen (Service Role Key lokal beim User)
- OFF via HTTP-Stream von [static.openfoodfacts.org](http://static.openfoodfacts.org)
- Normalisieren via INFOODS-Codes
- NULL-Imputation anwenden
- Batch embedding via text-embedding-3-small (100er)
- Idempotenter Insert (ON CONFLICT via source+source_id)
- Checkpoint-File für Resume
- Dry-Run Modus erst, dann echter Import auf Freigabe

**Schritt 4 — Edge Function food-scanner**

- Deno/TypeScript, Supabase Edge Function
- Tier 0 Barcode: OFF Live API
- Tier 1 Vision: GPT-4o XML Prompt + Strict Schema + logprobs
- pgvector Cosine Search + RRF Re-Ranking
- Tier 3 Synthesis: GPT-4o Fallback mit Bognár-Faktoren
- Quality Gate per Logprob + Cosine
- Conflict Resolution: DB-Priority über LLM
- Provenance Tracking pro Zutat
- Dry-Run Deployment erst, dann echter Deploy auf Freigabe

**Schritt 5 — HTML Test-Tool**

- Mobile-optimiert
- Foto-Upload in food-scans Bucket
- Edge Function Call
- Ergebnis-Anzeige wie Frontend
- Logging-Panel pro Scan (Tier-Trace, Confidence, Timing)
- Korrektur-Buttons (User-Feedback zurück in food_scan_cache)
- Batch-Modus für Massen-Tests

**Schritt 6 — Deployment Guide**

- Step-by-Step Checkliste
- Rollback-Szenarien pro Schritt

# Session-Log

**Session 1 (2026-04-11 Abend, Token-Ende in diesem Chat):**

- Stack final festgezogen
- 5 DBs + Doku analysiert (CIQUAL komplett)
- INFOODS-Harmonisierung identifiziert
- Safety Boundaries definiert
- Notion Doku angelegt
- Go von Deniz für Build-Phase erteilt
- Supabase vorbereitet (food-scans Bucket, OPENAI_API_KEY, raw Bucket gefüllt)
- **Ausstehend für User:** pgvector Extension aktivieren
- **Nächste Session startet mit:** bash_tool Schema-Extraktion der 5 DBs

# Follow-Up-Prompt für nächsten Chat

Siehe separates Doc oder im Master-Doc unter "Prompt für neuen Chat" Sektion. Wichtig: 5 DB-Files neu hochladen (BLS ZIP, CIQUAL 7z + Doku PDF, USDA Foundation ZIP, USDA SR Legacy ZIP, CoFID xlsx, NEVO ZIP — TürKomp und STFCJ NICHT mehr hochladen).