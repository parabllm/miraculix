---
typ: aufgabe
name: "Nutrition DB Stand"
projekt: "[[food-scanner]]"
status: in_arbeit
benoetigte_kapazitaet: niedrig
kontext: ["desktop"]
kontakte: []
quelle: direkte_erfassung
vertrauen: extrahiert
erstellt: 2026-04-19
---

Single-source-of-truth für den aktuellen Daten-Stand der `nutrition_db` Tabelle. Wird nach jeder Etappe aktualisiert. Aktueller Stand Ende 2026-04-19, Live-Run Etappe 3 läuft zu dem Zeitpunkt.

## Quantität

23.305 Rows total, verteilt auf 6 wissenschaftliche Quellen. Kein OFF-Import mehr direkt in der DB (historisch raus wegen Datenqualität, jetzt Cache-Aside Lazy-Load pro Barcode-Scan).

| Source | Rows | Anteil |
|---|---:|---:|
| USDA_SR | 7.793 | 33% |
| BLS | 7.140 | 31% |
| CIQUAL | 3.341 | 14% |
| COFID | 2.886 | 12% |
| NEVO | 2.328 | 10% |
| USDA_FND | 135 | <1% |

Architektur-Doc v8 erwähnt noch 25.558 und 2.000 OFF-Rows. Diese Zahl ist veraltet, OFF wurde beim DB-Reset 2026-04-13 entfernt.

## Qualitäts-Layer

### Layer 1: Makros (100% Coverage)

Alle 23.305 Rows haben `enerc_kcal`, `procnt_g`, `fat_g`, `choavl_g` gemessen oder berechnet. Diese Spalten werden in Etappe 3 nicht angefasst.

### Layer 2: Mikros (variierende Coverage)

Stand vor Etappe 3:

| Nutrient | Gefüllt | Coverage |
|---|---:|---:|
| Sodium | 22.759 | 97.7% |
| Calcium | 22.450 | 96.3% |
| Iron | 22.380 | 96.0% |
| Potassium | 22.171 | 95.1% |
| Magnesium | 21.945 | 94.2% |
| Zinc | 21.744 | 93.3% |
| Thiamine | 21.665 | 93.0% |
| Vitamin C | 20.554 | 88.2% |
| Riboflavin | 19.276 | 82.7% |
| Niacin | 19.246 | 82.6% |
| Fiber | 16.654 | 71.5% |
| Vitamin E | 16.549 | 71.0% |
| Vitamin D | 16.436 | 70.5% |
| Vitamin B6 | 11.849 | 50.8% |
| Folate | 11.758 | 50.5% |
| Vitamin A | 11.027 | 47.3% |

Gesamt: 391.683 von 466.100 Zellen über 20 Nutrient-Spalten = 84.0%.

## Strukturelle Spalten

### food_group_normalized

100% gefüllt seit Etappe 1 (2026-04-19). 21 Kategorien, davon 17 Safe + 4 Unsafe für Borrowing.

Top-Kategorien nach Volumen: meat_unprocessed 17.4%, prepared_dishes 16.2%, vegetables 9.5%, sweets_desserts 8.7%.

Index: `idx_nutrition_food_group_normalized` (btree).

### provenance (jsonb)

100% gefüllt seit Etappe 2. Schema:

```json
{
  "source_file": "USDA_SR/food_nutrient.csv",
  "values": {
    "enerc_kcal": { "method": "measured", "source": "USDA_SR/169909" },
    "vitd_ug":    { "method": "none" }
  }
}
```

Etappe 3 wird `method: "borrowed_from"` als dritte Methode hinzufügen, Schema bleibt gleich.

### embedding (vector 1536)

100% gefüllt. Model: OpenAI `text-embedding-3-small`. Basis-Text: `name_en`. Index: HNSW Cosine.

`food_group` wurde explizit NICHT in Embedding-Text eingerechnet, damit SQL-Prefilter und Vector-Ranking sauber getrennt bleiben.

## Schema-Fixpunkte

### 20 Nutrient-Spalten (numeric, nullable)

Energie, 4 Makros, 6 Mineralien, 9 Vitamine. Alle pro 100g.

### Schlüssel

- `id bigint` PK
- `(source, source_id)` unique
- `source` CHECK in ('BLS', 'CIQUAL', 'USDA_FND', 'USDA_SR', 'COFID', 'NEVO', 'OFF')

OFF in der CHECK-Constraint erlaubt aber aktuell keine Rows. Für Lazy-Load vorgesehen.

## Snapshots

- `nutrition_db_food_group_backup` (23.305) - Rollback-Basis für Etappe 1, wird nach Etappe 3 abgeschlossen entfernt
- `nutrition_db_borrowing_backup` (23.305) - Rollback-Basis für Etappe 3, enthält alle 20 Nutrient-Spalten + provenance

## Aktive Indexes

- `nutrition_db_embedding_idx` HNSW auf `embedding`
- `nutrition_db_source_uid` unique btree auf `(source, source_id)`
- `nutrition_db_food_group_idx` btree auf `food_group`
- `idx_nutrition_food_group_normalized` btree auf `food_group_normalized`

## RPCs

### match_nutrition (aktiv)

Standard-Match ohne Category-Filter. Wird von Edge Function `food-scanner` genutzt.

### match_nutrition_filtered (aktiv)

Mit Postgres-seitigem Prefilter auf `food_group_normalized` und `nutrient_not_null`. Wird von Borrow-Script genutzt. Whitelist-Validierung für `nutrient_column`.

## Erwartung nach Etappe 3

Live-Run in Arbeit. Projektion:

- Gesamtcoverage 84% auf 86-88%
- Vitamin A 47% auf 55-60%
- Vitamin B6 51% auf 60-65%
- Folate 51% auf 60-65%
- 11.000 bis 15.000 neue Borrows mit `method: "borrowed_from"` Provenance

100% Coverage ist nicht das Ziel. Unsafe-Kategorien (plant_based, supplements, alcoholic, sweets) bleiben NULL. Biologisch nicht vorhandene Mikros (Vitamin D in pflanzlichen Foods) bleiben NULL. "Unknown is better than wrong."
