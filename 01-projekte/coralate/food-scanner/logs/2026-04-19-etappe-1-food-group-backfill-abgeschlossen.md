---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-19
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["supabase", "openai", "node"]
---

Etappe 1 der Nutrient-DB-Roadmap durch. Alle 23.305 Rows haben jetzt `food_group_normalized` gesetzt. 100% Coverage. Damit ist das Fundament für Etappe 3 (Cross-DB Borrowing) gelegt: Borrowing kann ab jetzt kategorisch gefiltert werden.

## Ergebnis

- Coverage: 100% (23.305 / 23.305)
- 21 Kategorien aktiv, alle Sources abgedeckt
- Verteilung: meat_unprocessed 17.4%, prepared_dishes 16.2%, vegetables 9.5%, sweets_desserts 8.7% (Top 4)
- Index `idx_nutrition_food_group_normalized` (btree) bereit für Etappe 3
- Snapshot-Tabelle `nutrition_db_food_group_backup` bleibt bis Etappe 3 abgeschlossen

## Architektur

Lokales Node.js-Skript, kein Edge Function (Batch-Job, lokal sinnvoller). Stack:
- gpt-4.1-mini mit `response_format: json_schema` strict + Enum
- Batch-Size 50 Rows pro LLM-Call
- Stratified Dry-Run mit adaptiver Quota-Verteilung
- Snapshot-Tabelle als Rollback-Basis
- Checkpoint-File für Resume bei Abbruch
- Auto-Flag bei Confidence < 0.7 oder Unsafe-Kategorie

## Iterationen

5 Versionen der Taxonomie, jede nach einem Dry-Run:

- v1 (100 Rows): Baseline, 14 Safe + 4 Unsafe Kategorien aus Roadmap, 6 ergänzt
- v2 (100 Rows): meat_raw → meat_unprocessed (Restaurant-Steaks), food_additives als 21. Kategorie, Coating-Override-Regel
- v3 (102 Rows): Legume-Dip-Regel (Hummus, Tahini, Peanut Butter → legumes_nuts_seeds)
- v4 (1805 Rows): Sugar-Fix (Granulated Sugar, Honey, Syrups, Dessert-Mixes → sweets_desserts statt food_additives)
- v5 (5135 Rows): Flour-Fix (alle Mehlsorten → grains_pasta statt food_additives)

Jeder Fix wurde im nächsten Dry-Run verifiziert. Avg Confidence stieg von 0.961 auf 0.969.

## Bug-Patterns gefunden

Fehler beim Klassifizieren passieren systematisch entlang dieser Achsen:

- **Coating overridet Base nicht automatisch.** "Sugar-coated almond" landete erst bei legumes_nuts_seeds. LLM bevorzugt die Hauptzutat über die Verarbeitung.
- **Functional Ingredients zu breit interpretiert.** Mehl und Zucker wurden in food_additives gesteckt. Definition musste explizit "small amounts" und "not a primary nutritional contributor" aufnehmen.
- **Multi-Ingredient-Produkte landen reflexartig in prepared_dishes.** Hummus → prepared_dishes, obwohl >60% Kichererbse. Explizite Regel mit Prozentangabe nötig.

Patterns sind mit Beispielen im Prompt verankert. Nicht jede Edge wurde gefixt (Hummus ist genug, Guacamole-Ausnahme dokumentiert), nur die mit messbarem Borrowing-Impact in Etappe 3.

## Bugs im Skript

- **upsert vs UPDATE.** writeClassifications nutzte upsert, was bei Postgres NOT NULL Constraints triggert bevor ON CONFLICT evaluiert wird. Crash bei Row 1. Fix: echte UPDATEs per id mit Promise.allSettled.
- **502 Cloudflare killt Batch.** Promise.all crasht beim ersten failed Update. Fix: allSettled + Retry-Logic mit exponential backoff (1s, 2s, 4s, 8s, 16s).
- **Resume vergisst missing_from_response Items.** classifiedIds wurde direkt nach LLM-Call befüllt, auch für Items wo das LLM die ID weggelassen hatte. Beim Resume wurden die als "schon erledigt" geskippt. Fix: nur Items mit category != null in processedIds.
- **Supabase 1000-Row Default-Cap.** dry-run mit limit=10000 ergab 5135 statt 10000, weil .limit(1973) silent auf 1000 gecapped wurde. Bug betrifft nur große Dry-Runs, nicht Full-Run (der nutzt Cursor-Pagination mit Batch 50).

## Cost

- Dry-Runs (5x): ~$2.50 zusammen
- Full-Run: ~$4
- Total Etappe 1: ~$6.50

## Entscheidungen aus Research-Phase bestätigt

- LLM für Klassifikation taugt (gpt-4.1-mini mit strict JSON Enum: 0 Parse-Errors über 23.305 Rows)
- LLM-Imputation für Nutrient-Werte bleibt verworfen (Etappe 1 zeigt nicht das Gegenteil)
- Provenance pro Wert (Etappe 2) ist next, weil ohne das kein nachvollziehbares Borrowing möglich ist

## Files

Im Repo `corelate-v3/scripts/food-group-backfill/`:
- backfill-food-groups.mjs (Hauptskript, 600 Zeilen)
- taxonomy.mjs (21 Kategorien, Unsafe-Liste, System-Prompt v5)
- setup-snapshot.sql
- package.json
- README.md

## Nächste Schritte

- Etappe 2: Provenance-Schema. Spalte `provenance jsonb` existiert bereits in nutrition_db, Schema und Backfill fehlen. OFF 2026 Smart-Aggregation als Vorbild.
- Snapshot-Tabelle `nutrition_db_food_group_backup` behalten bis Etappe 3 durch.
- Skript-Files ins Repo committen (Etappe 1 Reproduzierbarkeit)
