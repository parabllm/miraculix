---
typ: aufgabe
name: "Nutrient DB Roadmap"
projekt: "[[food-scanner]]"
status: in_arbeit
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[jann-allenberger]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Master-Plan nach kritischer Voice-Input-Einsicht 2026-04-14: Matching-System ist zentrale Infrastruktur für Backfill + Borrowing + User-Retrieval gleichzeitig.

## Anforderungen (non-negotiable)

1. **Vollständigkeit:** Jede Row in `nutrition_db` hat am Ende alle 20 Nährwerte (5 Makros + 15 Mikros), entweder gemessen, sicher geborgt, oder explizit als "unbekannt" markiert.
2. **Provenance pro Wert:** Für jeden Nutrient-Wert dokumentiert woher: `measured` (Original-Quelle), `borrowed_from:{source_id}` (aus anderer Row übernommen), `imputed` (LLM-geschätzt), `none` (keine Daten).
3. **Kategorisch sicher:** Borrowing nur zwischen Rows derselben `food_group_normalized`, mit expliziter Unsafe-Liste (plant-based vs animal, sugar-free vs sugar, fortified vs unfortified).

## Kern-Architektur-Einsicht

**Das Matching-System ist eine einzige Infrastruktur** für drei Aufgaben gleichzeitig:

1. **DB-internes Borrowing** - Row A borgt Mikros von Row B
2. **User-Retrieval** - Vision-Output in DB-Row
3. **OFF Lazy-Load** - neuer OFF-Eintrag in wissenschaftliche Referenz für Mikro-Enrichment

Konsequenz: Matching-System muss zuerst stehen und robust sein bevor alles andere gebaut wird. Sonst passiert der zweite DB-Reset (wie beim letzten Borrowing-Crash).

## Borrowing-Hierarchie

Für jeden fehlenden Nutrient-Wert:

### Stufe 1: Cross-DB Borrowing (echte gemessene Werte)

Suche in anderen Rows mit:
- gleicher `food_group_normalized` (Pflicht)
- Similarity >= 0.85 (konservativ)
- Wert vorhanden
- Kategorie in Safe-List

Provenance: `{method: "borrowed", source: "USDA_SR/12345", similarity: 0.91}`

### Stufe 2: Median-Borrowing (mehrere Nachbarn)

Mehrere Rows mit Wert, Varianz < 20%.
Provenance: `{method: "borrowed_median", sources: [...], n: 4}`

### Stufe 3: NULL

Wenn keine Nachbarn verfügbar oder Kategorie unsafe. Provenance: `{method: "none"}`. UI: "keine Daten verfügbar".

**LLM-Imputation verworfen** (Entscheidung 2026-04-14, bestätigt 2026-04-19):
- Research zeigte Failure-Modes: Regression-to-Mean, halluzinierte Mikro-Werte, biologisch unmögliche Kombinationen
- Erfahrung aus Etappe 1: LLMs eignen sich für Klassifikation (kategorisch), nicht für numerische Werte
- Policy: "Unknown is better than wrong." Transparente NULLs > fabrizierte Werte.

## Category-Safe-Listen

### Safe für Borrowing (17 Kategorien)

- grains_pasta, bakery, breakfast_cereals
- vegetables, fruits, legumes_nuts_seeds
- meat_unprocessed, meat_processed, seafood
- dairy_eggs, fats_oils, herbs_spices
- sauces_condiments, food_additives, prepared_dishes
- snacks, beverages_nonalcoholic

### Unsafe (NIE borrowen, auch bei hoher Similarity)

- plant_based_alternatives (Fortifizierung variiert extrem)
- supplements (Dosierungen variieren)
- beverages_alcoholic (bimodal in Nährwerten)
- sweets_desserts (Zucker- / Fett-Gehalt variiert)
- packaged-Produkte mit "sugar-free", "low-fat", "fortified"

Policy bei unsafe: Wert bleibt NULL, UI zeigt "unbekannt".

## Phasen-Plan

### Phase 0: Dokumentation
Dieses Doc als Master-Plan, laufend aktualisiert.

### Phase 1: Matching-System (Grundinfrastruktur)

**1a. ERLEDIGT 2026-04-19.** `food_group_normalized` Backfill (23.305 Rows) via LLM-Klassifikation (gpt-4.1-mini, strict JSON Enum, 21 Kategorien). 100% Coverage. Skript in `corelate-v3/scripts/food-group-backfill/`. Snapshot-Tabelle `nutrition_db_food_group_backup` als Rollback-Basis. Details: [[2026-04-19-etappe-1-food-group-backfill-abgeschlossen]].

### Must-have vor App-Launch

- Multi-Layer Matching für Avocado-vs-Avocado-Oil-Problem (food_group_normalized Filter im match_nutrition RPC)
- food_group_normalized Backfill für alle 25.558 Einträge
- Frontend ScanResultScreen in React Native (Jann)
- Frontend Camera/Gallery/Barcode-Picker Komponenten (Jann)
- Daily Macros Aggregation (View über `food_scan_log WHERE status='confirmed' AND DATE(confirmed_at) = today`)

### Mittelfristig

- Manuell-Eingabe-Modus (für Sachen ohne Bild/Barcode wie Glas Wasser, Vitamin-Pille)
- Edit eines bereits confirmed Scans (nachträglich Grams ändern)
- Re-Scan eines failed Scans per Klick (statt neues Foto)
- Bognár-Faktoren für Kochverlust bei tier1_vision
- Hybrid-Tier `tier1_vision_hybrid` für Gerichte mit teilweise erkanntem Barcode
- Knowledge-Base-Integration: Cora kann scan-basiert Coaching geben

### Langfristig

- Apple Health und Google Fit Sync für Aktivitätsdaten
- Foto-Persistierung und Deletion-Policy (DSGVO Art. 17)
- Multi-Plate-Recognition (mehrere Teller auf einem Bild)
- User-Confidence-Loop: wenn User oft korrigiert, lernt System seine Präferenzen

## Bekannte Bugs

- **Inferred Ingredients konservativ:** Vision schätzt z.B. 10g Öl beim Anbraten, real sind's oft 20-30g. Fix → kalibrierter Vision-Prompt v2.
- **OFF-Daten ohne name_en:** 2.000 Einträge können nicht sauber semantisch gefunden werden. Fix → Translation-Pipeline für OFF.
- **Edge Function Cold Start:** erster Scan nach 10min Inaktivität braucht 1-2s extra. Mitigation → keepalive-Endpoint periodisch aufrufen.
