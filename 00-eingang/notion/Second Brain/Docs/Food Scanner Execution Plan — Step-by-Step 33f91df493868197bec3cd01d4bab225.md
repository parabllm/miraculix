# Food Scanner Execution Plan — Step-by-Step

Created: 12. April 2026 00:19
Doc ID: DOC-49
Doc Type: Architecture
Gelöscht: No
Last Edited: 12. April 2026 00:19
Last Reviewed: 11. April 2026
Lifecycle: Active
Notes: SOFT ARCHIVED - Execution-Plan größtenteils abgearbeitet. Aktueller Stand in Pipeline Status Doc v7 (2026-04-12). Pipeline läuft produktiv.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Volatile
Stack: Supabase
Verified: Yes

# Zweck

Live Execution Plan für Food Scanner Build. Nächste Claude-Instanz arbeitet Step-by-Step ab und aktualisiert Session Log am Ende.

# Readiness

- pgvector aktiviert
- food-scans Bucket
- raw-nutrition-data mit 5 DBs (BLS, CIQUAL 2025, USDA Foundation 2025-12, USDA SR Legacy 2018-04, CoFID 2021, NEVO 2025 v9.0)
- OPENAI_API_KEY Secret
- CIQUAL Doku analysiert: 3.484 Foods × 74 Komponenten, per 100g edible, A-D Confidence, INFOODS-codiert

# Safety IMMUTABLE

**Darf:** food_entries erweitern, nutrition_db + food_scan_cache neu, Edge Function food-scanner, food-scans Bucket.

**Tabu:** cora_memories, cora_facts, cora_call_queue, ai_suggestions, knowledge_chunks, profiles, workouts, workout_sessions, exercises, food_day_records, Auth-Tabellen, bestehende RLS Policies.

**Pflicht:** Rollback-SQL pro Migration im selben File. ON CONFLICT Idempotenz. Keine destruktiven UPDATE/DELETE auf Existing. Dry-Run vor echtem Run. Jede Session dokumentiert im Session Log.

# Core 19 Nutrients (INFOODS-Codes)

**Makros:** ENERC (kcal), PROCNT (protein g), FAT (fat g), CHOAVL (carbs g), FIBTG (fibre g)

**Mikros:** NA (sodium mg), K (potassium mg), CA (calcium mg), FE (iron mg), MG (magnesium mg), ZN (zinc mg), VITA_RAE (vit A μg RE), VITD (vit D μg), VITE (vit E mg α-TE), VITC (vit C mg), THIA (B1 mg), RIBF (B2 mg), NIA (B3 mg), VITB6A (B6 mg), FOLDFE (B9 μg DFE)

# STEP 1 — Schema-Extraktion

Via bash_tool alle 5 DBs entpacken und lesen.

**Commands:**

```bash
mkdir -p work && cd work
unzip -o /mnt/user-data/uploads/BLS_4_0_2025_DE.zip -d bls/
pip install py7zr openpyxl pandas --quiet
python -c "import py7zr; py7zr.SevenZipFile('/mnt/user-data/uploads/2025_11_03.7z','r').extractall('ciqual/')"
unzip -o /mnt/user-data/uploads/FoodData_Central_foundation_food_csv_2025-12-18.zip -d usda_fnd/
unzip -o /mnt/user-data/uploads/FoodData_Central_sr_legacy_food_csv_2018-04.zip -d usda_sr/
unzip -o /mnt/user-data/uploads/NEVO2025_v9_0.zip -d nevo/
cp /mnt/user-data/uploads/McCance_Widdowsons_Composition_of_Foods_Integrated_Dataset_2021_.xlsx cofid.xlsx
find . -type f | head -50
```

**Pro DB extrahieren:**

1. Alle Dateien listen
2. Haupt-Tabelle identifizieren (CIQUAL: Table_Ciqual_2025.xlsx Tab 'Food composition'; USDA: food.csv + food_nutrient.csv + nutrient.csv; BLS: Haupt-Excel; CoFID: Proximates + Inorganics + Vitamins Tabs; NEVO: NEVO2025_v9.0.xlsx)
3. Header-Zeile und alle Spalten dokumentieren
4. 20-50 Beispielzeilen ausgeben
5. INFOODS-Code-Mapping finden (CIQUAL Tab 'INFOODS codes', USDA nutrient.csv via nutrient_nbr, BLS via Doku)
6. Einheiten pro Spalte festhalten
7. Missing-Value-Darstellung identifizieren (CIQUAL=dash, USDA=NULL, NEVO=possibly 0)

**Output:** Schema-Vergleichs-Matrix als Markdown-Tabelle. Zeilen = DBs, Spalten = 19 Core Nutrients mit INFOODS-Code. Zellen = vorhanden / fehlt / ableitbar.

**Stop:** Matrix an Deniz, Freigabe abwarten.

# STEP 2 — Migration SQL

**Files:** `migrations/001_food_scanner_setup.sql` + `migrations/001_rollback.sql`

**001_food_scanner_setup.sql:**

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS nutrition_db (
  id bigserial PRIMARY KEY,
  source text NOT NULL CHECK (source IN ('BLS','CIQUAL','USDA_FND','USDA_SR','COFID','NEVO','OFF')),
  source_id text NOT NULL,
  name_original text NOT NULL,
  name_en text,
  origin_country text,
  food_group text,
  enerc_kcal numeric,
  procnt_g numeric,
  fat_g numeric,
  choavl_g numeric,
  fibtg_g numeric,
  na_mg numeric, k_mg numeric, ca_mg numeric, fe_mg numeric,
  mg_mg numeric, zn_mg numeric,
  vita_rae_ug numeric, vitd_ug numeric, vite_mg numeric, vitc_mg numeric,
  thia_mg numeric, ribf_mg numeric, nia_mg numeric, vitb6a_mg numeric, foldfe_ug numeric,
  confidence_code text,
  provenance jsonb DEFAULT '{}'::jsonb,
  embedding vector(1536),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(source, source_id)
);

CREATE INDEX IF NOT EXISTS nutrition_db_embedding_idx ON nutrition_db USING hnsw (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS nutrition_db_source_idx ON nutrition_db(source);
CREATE INDEX IF NOT EXISTS nutrition_db_food_group_idx ON nutrition_db(food_group);
CREATE INDEX IF NOT EXISTS nutrition_db_origin_idx ON nutrition_db(origin_country);

CREATE TABLE IF NOT EXISTS food_scan_cache (
  id bigserial PRIMARY KEY,
  scan_hash text UNIQUE NOT NULL,
  image_path text,
  result jsonb NOT NULL,
  confidence numeric,
  tier_used text CHECK (tier_used IN ('tier0_barcode','tier1_vision','tier3_synthesis')),
  user_confirmed boolean DEFAULT false,
  user_corrections jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS food_scan_cache_hash_idx ON food_scan_cache(scan_hash);
CREATE INDEX IF NOT EXISTS food_scan_cache_confirmed_idx ON food_scan_cache(user_confirmed) WHERE user_confirmed = true;
```

**001_rollback.sql:**

```sql
DROP TABLE IF EXISTS food_scan_cache;
DROP TABLE IF EXISTS nutrition_db;
```

**002_food_entries_micros.sql:** Vor Erstellung `food_entries` via Supabase MCP inspizieren um keine bestehenden Spalten zu duplizieren. Dann ALTER TABLE ADD COLUMN IF NOT EXISTS für fehlende 14 Mikros. Rollback: ALTER TABLE DROP COLUMN IF EXISTS für jede hinzugefügte.

**Stop:** SQL an Deniz, Freigabe abwarten vor Ausführung.

# STEP 3 — Python Import-Script

**File:** `import/import_nutrition_dbs.py`

**Struktur:**

```python
# Phases sequentiell, resumable via checkpoint file
# 1. BLS → normalize → embed → upsert
# 2. CIQUAL (INFOODS codes explicit in 'INFOODS codes' tab)
# 3. USDA Foundation (nutrient_id via nutrient.csv)
# 4. USDA SR Legacy (same mapping)
# 5. CoFID (header-based mapping via Doku)
# 6. NEVO (header-based mapping)
# 7. OFF via HTTP stream
```

**Kern-Funktionen:**

- `load_infoods_mapping(source)` → dict[raw_column → infoods_code]
- `normalize_to_infoods(raw_row, source, mapping)` → dict mit allen 19 Core Spalten, Einheiten-Konvertierung (μg/mg/g auf Standard)
- `build_embedding_text(row)` → f"{name_en} | {name_original} | {food_group}" für multilingual embedding
- `embed_batch(texts, batch_size=100)` → OpenAI text-embedding-3-small
- `upsert_row(row)` → INSERT ON CONFLICT(source, source_id) DO UPDATE
- `checkpoint(source, last_processed_id)` → JSON file für Resume
- `dry_run_report(source)` → Statistiken: row_count, null_rates pro Spalte, sample

**OFF Stream-Pattern:**

```python
import gzip, urllib.request, csv

url = "https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz"
EU_COUNTRIES = {'germany','france','united-kingdom','netherlands','spain','italy','belgium','austria','poland','denmark','sweden','finland','portugal','ireland','czech-republic','greece'}

def stream_off():
    req = urllib.request.Request(url, headers={'User-Agent': 'coralate-import/1.0'})
    with urllib.request.urlopen(req) as resp:
        with gzip.open(resp, mode='rt', encoding='utf-8', errors='replace') as f:
            reader = csv.DictReader(f, delimiter='\t')
            for row in reader:
                if not has_full_nutrition(row): continue
                countries = (row.get('countries_en') or '').lower()
                if not any(c in countries for c in EU_COUNTRIES): continue
                yield normalize_off(row)

def has_full_nutrition(row):
    required = ['energy-kcal_100g','proteins_100g','fat_100g','carbohydrates_100g']
    return all(row.get(k) and row[k].strip() for k in required)
```

**Dry-Run Modus:** `--dry-run` Flag schreibt in `nutrition_db_staging` temporäre Tabelle und printet:

- Row count pro Source
- NULL-Rate pro der 19 Spalten
- 5 zufällige Samples pro Source
- Embedding-Token-Usage geschätzt

**Cross-DB Borrowing nach Import (separater Step):**

```python
# Für jede Zeile mit NULL in Mikro X:
# 1. Semantic Neighbor Query (cosine distance top 10, same food_group)
# 2. Wenn Neighbor den Wert hat: kopieren, provenance → {"borrowed_from": source+id, "original_null": true}
# 3. Wenn nicht: flag imputed_needed für Recipe-Based Reconstruction
```

**Stop:** Dry-Run Output an Deniz, Freigabe für echten Import abwarten.

# STEP 4 — Edge Function food-scanner

**File:** `supabase/functions/food-scanner/index.ts`

**Flow:**

1. Request Body: `{ image_url?, barcode?, user_context: { location, time, recent_meals } }`
2. **Tier 0:** Wenn `barcode` → fetch OFF Live API `https://world.openfoodfacts.org/api/v2/product/${barcode}.json` → map zu Core 19 → return mit `tier_used='tier0_barcode'`
3. **Tier 1:** GPT-4o Vision Call mit XML-Prompt (siehe unten), Strict JSON Schema für Zutaten, `logprobs: true`. Response parsen → pro Zutat embedding → pgvector cosine search top-50 via RPC `match_nutrition` → RRF mit Geo/Time als Soft Hint (k=60) → Quality Gate: logprob mean > -0.5 UND top cosine similarity > 0.75
4. **Tier 3:** Falls Quality Gate fails → GPT-4o Synthesis mit Einzelzutaten-Rekonstruktion und Bognár-Faktoren für Kochverluste → markiert als `tier_used='tier3_synthesis'`, `confidence='estimated'`
5. Response in food_scan_cache schreiben mit scan_hash = SHA256 von image_bytes

**XML Prompt Template:**

```xml
<system_instructions>
You are a food recognition assistant. Priority: visual evidence > text > context.
Never override clear visual evidence based on location, time, or history.
</system_instructions>
<processing_rules>
1. Analyze the image first: textures, colors, visible ingredients, cooking method
2. Use user_context only as weak tiebreaker between visually equivalent candidates
3. If visual and context conflict, trust the image and note the conflict
</processing_rules>
<user_context>
<location>{location}</location>
<local_time>{time}</local_time>
<recent_meals>{history}</recent_meals>
</user_context>
<task>
Identify the food in the image. Return JSON matching the schema.
For each ingredient: name_en, name_de, estimated_grams, cooking_method.
Reason step-by-step in a reasoning field before the final ingredients array.
</task>
```

**Strict JSON Schema:**

```json
{
  "type": "object",
  "properties": {
    "reasoning": {"type": "string"},
    "dish_name_guess": {"type": "string"},
    "ingredients": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name_en": {"type": "string"},
          "name_de": {"type": "string"},
          "estimated_grams": {"type": "number"},
          "cooking_method": {"type": "string"}
        },
        "required": ["name_en","estimated_grams"]
      }
    }
  },
  "required": ["reasoning","ingredients"]
}
```

**pgvector Search RPC:**

```sql
CREATE OR REPLACE FUNCTION match_nutrition(
  query_embedding vector(1536),
  match_count int DEFAULT 50
)
RETURNS TABLE (id bigint, source text, name_en text, origin_country text, similarity float, full_row jsonb)
LANGUAGE sql STABLE AS $$
  SELECT id, source, name_en, origin_country,
    1 - (embedding <=> query_embedding) AS similarity,
    to_jsonb(nutrition_db) AS full_row
  FROM nutrition_db
  ORDER BY embedding <=> query_embedding
  LIMIT match_count;
$$;
```

**RRF Re-Ranking (TypeScript):**

```tsx
const k = 60;
function rrf(candidates, userCountry) {
  const semanticRank = [...candidates].sort((a,b) => b.similarity - a.similarity);
  const geoRank = [...candidates].sort((a,b) => 
    (b.origin_country === userCountry ? 1 : 0) - (a.origin_country === userCountry ? 1 : 0)
  );
  return candidates.map(c => {
    const sR = semanticRank.indexOf(c) + 1;
    const gR = geoRank.indexOf(c) + 1;
    return { ...c, rrf_score: 1/(k+sR) + 1/(k+gR) };
  }).sort((a,b) => b.rrf_score - a.rrf_score);
}
```

**Response Shape:**

```json
{
  "tier_used": "tier1_vision",
  "dish_name": "Lamm-Tagine mit Kichererbsen",
  "ingredients": [{"name":"lamb","grams":150,"matched_source":"BLS","similarity":0.89}],
  "totals": {"enerc_kcal": 520, "procnt_g": 32, ...},
  "provenance": [{"nutrient":"vitc_mg","method":"analytical","source":"BLS"}],
  "confidence": 0.87,
  "latency_ms": 3200
}
```

**Stop:** Deploy auf Staging, Deniz testet via Test-Tool, Freigabe für Production abwarten.

# STEP 5 — HTML Test-Tool

**File:** `test-tool/index.html` (single file, mobile-first, Tailwind via CDN)

**Features:**

- Foto-Upload (input type=file accept=image/* capture=environment für Camera)
- Upload in food-scans Bucket via Supabase JS Client (anon key)
- Call Edge Function food-scanner mit user_context (location via browser Geolocation API optional, time aus [Date.now](http://Date.now), recent_meals leer für Test)
- Display: Bild Thumbnail + alle 19 Nährwerte als Grid + Confidence Badge + Tier-Trace
- Logging Panel rechts: Timing Breakdown pro Tier, Embedding-Query, pgvector Top-5 Kandidaten, RRF-Scores, Quality-Gate Entscheidung
- Korrektur-Buttons: "Zutat hinzufügen", "Zutat entfernen", "Menge ändern"
- Nach Korrektur: PATCH food_scan_cache mit user_confirmed=true und user_corrections jsonb
- Batch-Modus: mehrere Bilder uploaden, Ergebnisse als Tabelle mit CSV-Export
- Mobile-First: funktioniert auf iPhone Safari direkt, kein Build-Step

**Stop:** Tool live, Deniz testet mit echten Fotos, Feedback sammeln, Korrekturen fließen in food_scan_cache.

# STEP 6 — Deployment Guide

Separates Doc `Food Scanner Deployment Guide` in Docs DB. Step-by-Step Checkliste, Rollback pro Schritt, Troubleshooting für häufige Fehler (pgvector nicht aktiv, OpenAI Rate Limit, OFF Stream timeout, Embedding Dimension mismatch).

# Session Log

Template:

```
## Session N (YYYY-MM-DD)
- Gemacht: ...
- Blockiert: ...
- Nächster Schritt: ...
- Migrations angewendet: ...
- Rollback-Status: ...
- Files erstellt: ...
```

**Session 1 (2026-04-11 Abend):** Plan und Skill angelegt. Readiness bestätigt. Alle 5 DBs im raw-nutrition-data Bucket. pgvector aktiv. OPENAI_API_KEY gesetzt. Nächste Session startet mit STEP 1 Schema-Extraktion.