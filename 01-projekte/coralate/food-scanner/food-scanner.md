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
tech_stack: ["supabase", "postgres", "pgvector", "python", "openai", "deno", "edge-functions", "node"]
notion_url: ""
erstellt: 2026-04-16
notizen: "Nährwert-Retrieval-Pipeline für Coralate. Hybrid 3-Tier Architektur. Edge Function live (food-scanner v15). Stand 19.04. abends: Etappe 3 Cross-DB Borrowing Live-Run läuft, Vision-Prompt-Analyse mit konkreten Bugs aus food_scan_log abgeschlossen, v6-Spec in Arbeit."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

Nährwert-Retrieval-Pipeline für coralate's Food-Tracking. Scannt Foods, matcht gegen 6 wissenschaftliche Nährwert-DBs, liefert harmonisierte Nährwert-Daten an die App.

**Architektur (v8, gelocked):** Hybrid 3-Tier
- Tier 0: Barcode direkt via Open Food Facts (cache-aside Lazy-Load geplant)
- Tier 1: Vision via Gemini 2.5 Flash Lite, matched gegen nutrition_db
- Tier 1 Hybrid: Vision mit teilweise erkanntem Barcode (geplant)

**Edge Function** `food-scanner` (v15) produktiv. Vorgänger `food-scanner-gemini` seit 2026-04-13 deprecated (returns 410).

## Aktueller Stand

Stand 2026-04-19 abends. Etappen 1+2+3 der Nutrient-DB-Roadmap durch oder in Live-Run.

- ~~Phase 1 Daten-Uploads komplett~~ 2026-04-11
- ~~INFOODS als Harmonisierungs-Achse identifiziert~~ 2026-04-11
- ~~STEP 1+2 Done (Architektur-Lock V5.1)~~ 2026-04-11
- ~~STEP 3 Import durch~~ 2026-04-11
- ~~Pipeline-Anpassungen von Jann~~ 2026-04-11
- ~~Borrowing läuft, food_scan_cache + Edge Function~~ 2026-04-11
- ~~v1→v5 Iteration komplett~~ 2026-04-12
- ~~Edge Function produktiv, Latenz-Roadmap~~ 2026-04-12
- ~~Session-Abschluss: Master-Doc DOC-62, Auth gelöst, 9 Docs archiviert~~ 2026-04-13
- ~~Pipeline Production-Ready~~ 2026-04-13
- ~~DB Reset + Clean Re-Import (OFF entfernt, 23.305 Rows aus 6 Quellen)~~ 2026-04-13
- ~~food-scanner-gemini deprecated (410 Gone), food-scanner v15 live~~ 2026-04-13
- ~~Kritische Einsicht: Matching-System = Grundinfrastruktur~~ 2026-04-13
- ~~Etappe 1 Food-Group-Backfill: 23.305 Rows in 21 Kategorien~~ 2026-04-19
- ~~Etappe 2 Provenance-Schema: values-Block pro Row, 20 Einträge~~ 2026-04-19
- ~~Etappe 3 Script-Entwicklung: borrow-nutrients-v2 mit Modifier-Rules + LLM-Judge~~ 2026-04-19
- ~~Vision-Prompt Analyse: 5 Bugs aus echten Scans dokumentiert~~ 2026-04-19
- Etappe 3 Live-Run läuft (abends 2026-04-19, Laufzeit 2-3h erwartet)

## Offene Aufgaben

- Etappe 3 Live-Run Coverage-Verifikation via SQL
- Log Etappe 3 Abschluss mit finalen Zahlen nach Live-Run
- Vision-Prompt v6 entwickeln auf Basis der 5 Bugs (nächster Chat)
- `match_nutrition` RPC fixen: Rows mit >80% Null-Mikros aus Top-Matches filtern
- Fallback bei leerem match_nutrition Ergebnis implementieren
- Prompt in DB migrieren (prompt_versions Tabelle, v1 für vision_scanner)
- Etappe 4: State-Tags für Apfel-vs-Apfelkompott-Problem
- Etappe 5: OFF Cache-Aside Lazy-Load für Barcode-Scans
- Script-Files committen ins Repo unter `corelate-v3/scripts/borrow-nutrients/`

## Kontext-Notizen

- Retrieval-Taxonomy-Research: 21 Kategorien, 17 Safe + 4 Unsafe für Borrowing
- V5.1 Architektur-Lock mit Hybrid 3-Tier bestätigt, Geo via RRF
- LLM-Imputation für Nutrient-Werte: verworfen, durch Borrowing mit LLM-Judge ersetzt
- Snapshot-Tabellen `nutrition_db_food_group_backup` und `nutrition_db_borrowing_backup` bleiben bis Etappe 3 abgeschlossen
- Vault-Prompt-Log dokumentiert bis v5, Production ist kompakter (80 Tokens) - Dokumentations-Lücke 2026-04-19 festgestellt

## Detail-Docs

- [[architektur-v8]] Master-Architektur, ersetzt 9 ältere Docs
- [[nutrition-db-stand]] Aktueller Daten-Stand der nutrition_db Tabelle
- [[borrow-script-v2]] Dokumentation des finalen Borrow-Scripts
- [[frontend-integration]] React-Native-Integration für Jann (SSE, Konfirmation, Recalc)
- [[prompt-log]] Vision-Prompt-Versionierung mit v6-Analyse
- [[roadmap]] Nutrient DB Roadmap

## Kontakte

- [[jann-allenberger]] Backend-Adjustments, Pipeline-Input
