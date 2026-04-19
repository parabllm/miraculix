---
typ: sub-projekt
name: "Food Scanner"
aliase: ["Food Scanner", "Food-Scanner", "Food DB"]
ueber_projekt: "[[coralate]]"
bereich: produkt
umfang: geschlossen
status: aktiv
lieferdatum: ""
kapazitaets_last: hoch
kontakte: ["[[jann-allenberger]]"]
tech_stack: ["supabase", "postgres", "pgvector", "python", "openai", "deno", "edge-functions"]
notion_url: ""
erstellt: 2026-04-16
notizen: "Nährwert-Retrieval-Pipeline für Coralate. Hybrid 3-Tier Architektur. Edge Function live. Stand 19.04.: Etappen 1+2 der Nutrient-DB-Roadmap durch (food_group_normalized 100% befüllt, provenance.values pro Nutrient)."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

Nährwert-Retrieval-Pipeline für coralate's Food-Tracking. Scannt Foods → matcht gegen 5 Nährwert-DBs + Open Food Facts → liefert harmonisierte Nährwert-Daten an die App.

**Architektur (v8, gelocked):** Hybrid 3-Tier
- Tier 1: Fast Cache (`food_scan_cache`)
- Tier 2: Hybrid Retrieval (pgvector + BM25 + Geo via RRF)
- Tier 3: LLM-Fallback mit Safety-Rails

**Harmonisierungs-Achse:** INFOODS (identifiziert in Phase 1)
**Scope:** 5 Nährwert-DBs + OFF (Open Food Facts)

**Edge Function** (Supabase Deno) produktiv, Latenz-Roadmap in Arbeit.

## Aktueller Stand

Stand 2026-04-19. Etappe 1 der Nutrient-DB-Roadmap abgeschlossen.

- ~~Phase 1 Daten-Uploads komplett~~ 2026-04-11
- ~~INFOODS als Harmonisierungs-Achse identifiziert~~ 2026-04-11
- ~~STEP 1+2 Done (Architektur-Lock V5.1)~~ 2026-04-11
- ~~STEP 3 Import durch~~ 2026-04-11
- ~~Pipeline-Anpassungen von Jann~~ 2026-04-11
- ~~Borrowing läuft, `food_scan_cache` + Edge Function~~ 2026-04-11
- ~~v1→v7 Iteration komplett~~ 2026-04-12
- ~~Edge Function produktiv, Latenz-Roadmap~~ 2026-04-12
- ~~Session-Abschluss 2026-04-13: Master-Doc DOC-62 erstellt, Auth gelöst, 9 Docs archiviert~~
- ~~Pipeline Production-Ready, Chat-Übergabe vorbereitet~~ 2026-04-13
- ~~DB Reset + Clean Re-Import, bereit für Multi-Layer-Design~~ 2026-04-13
- ~~Kritische Einsicht: Matching-System = Grundinfrastruktur für Backfill, Borrowing, Retrieval~~ 2026-04-13
- ~~Etappe 1 Food-Group-Backfill: alle 23.305 Rows klassifiziert in 21 Kategorien (gpt-4.1-mini, 5 Iterationen, ~$6.50)~~ 2026-04-19
- ~~Etappe 2 Provenance-Schema: provenance.values Block pro Row, 20 Nutrient-Einträge je Row (measured/none), Coverage-Bericht erstellt~~ 2026-04-19

## Offene Aufgaben

- Etappe 3: Cross-DB Borrowing (Dry-Run + Audit + Commit, Category + CV + Simple-Item Regeln). Hauptkandidaten laut Coverage-Bericht: Vitamin A (47% measured), B6 (51%), Folate (51%).
- Etappe 4: Vision-Prompt V2 + RPC-Erweiterung (XML-structured, food_group Output)
- Etappe 5: OFF Lazy-Load (Barcode persistiert in DB mit Borrowing-Policy)
- Skript-Files committen ins Repo unter `corelate-v3/scripts/food-group-backfill/`

## Kontext-Notizen

- Retrieval-Taxonomy-Research: 20 Categories identifiziert (Etappe 1 implementiert mit 21, food_additives ergänzt)
- V5.1 Architektur-Lock mit Hybrid 3-Tier bestätigt, Geo via RRF
- Safety-Rails für Scope 5 DBs + OFF definiert
- LLM-Imputation für Nutrient-Werte: verworfen (Research 2026-04-14, bestätigt durch Etappe 1 Erfahrung)
- Snapshot-Tabelle `nutrition_db_food_group_backup` bleibt bestehen bis Etappe 3 durch

## Detail-Docs

- [[architektur-v8]] - Master-Architektur (Storage, Auth, Edge Functions, pgvector, Cache, Schema) - ersetzt 9 ältere Docs
- [[frontend-integration]] - React-Native-Integration für Jann (SSE, Konfirmation, Recalc)
- [[prompt-log]] - Vision-Prompt-Versionierung (aktuell v5, Prinzipien-basiert)
- [[roadmap]] - Nutrient DB Roadmap (Borrowing-Hierarchie, Matching-System)

## Kontakte

- [[jann-allenberger]] - Backend-Adjustments, Pipeline-Input
