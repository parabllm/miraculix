# Food Scanner Handover — STEP 1+2 Done, STEP 3 Ready

Created: 12. April 2026 10:59
Doc ID: DOC-51
Doc Type: Architecture
Gelöscht: No
Last Edited: 12. April 2026 10:59
Last Reviewed: 12. April 2026
Lifecycle: Deprecated
Notes: Handover Session 2026-04-12. STEP 1+2 done in Prod, STEP 3 ready.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: Supabase
Verified: Yes

# Zweck

Dieses Doc dokumentiert die Session vom 12.04.2026. Nächste Session startet STEP 3. **Verweist auf den Originalplan:** [Food Scanner Execution Plan](Food%20Scanner%20Execution%20Plan%20%E2%80%94%20Step-by-Step%2033f91df493868197bec3cd01d4bab225.md).

# Status

| STEP | Status |
| --- | --- |
| STEP 1 Schema-Extraktion | ✅ DONE |
| STEP 2 Migration + RPC | ✅ DONE (applied in Prod) |
| STEP 3 Python Import-Script | ⏳ TODO |
| STEP 4 Edge Function | ⏳ TODO |
| STEP 5 HTML Test-Tool | ⏳ TODO |
| STEP 6 Deployment Guide | ⏳ TODO |

# STEP 1 Ergebnisse

## Storage-Formate (verifiziert an echten Files)

| DB | Format | Haupt-Datei | Mapping |
| --- | --- | --- | --- |
| BLS | Wide-Excel, 7141×418 | BLS_4_0_Daten_2025_DE.xlsx + Components_DE_EN.xlsx | Header `{CODE} {Name} [{unit}]`, 146 INFOODS-Codes |
| CIQUAL | **XML Relational** (nicht Excel!) | alim+compo+const+alim_grp .xml | `<code_INFOODS>` explizit, 74 const, 3484 Foods |
| USDA Foundation | CSV Long | food+food_nutrient+nutrient.csv | `nutrient_nbr`→Dict |
| USDA SR Legacy | CSV Long (35 MB) | idem | 474 Nutrients |
| NEVO | **Pipe-CSV + Komma-Decimal** | NEVO2025_v9.0.csv | Codes in Header |
| CoFID | Excel Multi-Tab, **Codes in row1!** | McCance_Widdowsons_2021.xlsx | WATER, NA, RET, THIA |
| OFF | HTTP Stream gzip | [openfoodfacts.org/products.csv.gz](http://openfoodfacts.org/products.csv.gz) | EU-Filter |

## Core 19 Nutrients

Alle 6 DBs decken vollständig ab: ENERC_kcal, PROCNT, FAT, CHOAVL, FIBTG, NA, K, CA, FE, MG, ZN, VITA_RAE, VITD, VITE, VITC, THIA, RIBF, NIA, VITB6, FOLDFE.

## 4 Risiken gelöst

| Risiko | Realität | Mitigation |
| --- | --- | --- |
| CIQUAL teneur | 257k Werte: numerisch, Komma, `nd/-`, `<X`, `traces` | `parse_ciqual_teneur()`: nd→NULL, traces→0, <X→X/2, Komma→Punkt |
| NEVO Delimiter | 147 Pipes, `,` Decimal | `sep=' |
| USDA SR 35 MB | DictReader O(1) | 50k-Batches, <100 MB RAM, KEIN [pd.read](http://pd.read)_csv |
| CoFID Header | row0=labels, row1=CODES, row3+=data | Skip row0+row2, row1 als Mapping |

# STEP 2 — Migration 001 applied

**Supabase:** `vviutyisqtimicpfqbmi` (eu-west-1). Migration: `food_scanner_001_setup`.

**DB-Objekte:**

- `public.nutrition_db` — 19 Core Nutrients + Meta + `embedding vector(1536)`
- HNSW Cosine-Index + Btree (source, food_group, origin) + Partial Index auf NULL name_en
- `public.food_scan_cache` — SHA256-Dedup + user_corrections jsonb + GDPR CASCADE
- RPC `match_nutrition(embedding, count)` für Edge Function
- `set_updated_at()` Trigger
- RLS: nutrition_db read-auth, food_scan_cache owner-only

# Abweichungen vom Originalplan

**1. Schema-Erweiterungen in nutrition_db:**

- `name_original_lang char(2) NOT NULL` — gezielter Translation-Batch
- `name_en_source text` — unterscheidet native/translated/NULL
- `vitb6_mg` statt `vitb6a_mg` — vereinheitlicht VITB6 (NEVO/CoFID) und VITB6A (CIQUAL)

Hintergrund: User-Decision war "keine Translation jetzt, Spalte für später".

**2. CIQUAL ist XML, nicht Excel** — ElementTree statt openpyxl. Sauberer, keine Merged Cells.

**3. `food_entries` Mikro-Erweiterung entfällt** — Tabelle existiert noch nicht. Jann baut sie später mit Mikros direkt drin.

**4. `food_scan_cache.user_id` mit FK + CASCADE** — explizit für GDPR Art.17.

**5. RPC härter** — `SECURITY INVOKER`, `SET search_path`, Guard gegen NULL-Embeddings.

# STEP 3 Checklist

## Parser

- [ ]  BLS openpyxl + Header-Parsing
- [ ]  CIQUAL ElementTree + `parse_ciqual_teneur()`
- [ ]  USDA Fnd+SR: DictReader streaming, Pivot Long→Wide per fdc_id
- [ ]  CoFID row1-Header, Tabs mergen
- [ ]  NEVO pandas pipe+comma
- [ ]  OFF HTTP stream+gzip+EU-Filter

## Pipeline

- [ ]  Einheiten-Normalizer μg/mg/g
- [ ]  Embedding-Text `{name_en or name_original} | {name_original} | {food_group}`
- [ ]  OpenAI text-embedding-3-small, Batch 100
- [ ]  Upsert via Supabase MCP execute_sql, Batch 500
- [ ]  Checkpoint-JSON für Resume
- [ ]  `--dry-run` → staging + Report
- [ ]  Cross-DB Borrowing Post-Step

**Cost:** ~30k Foods × 50 Tokens × $0.02/1M = <$5 einmalig

# Referenzen

- Original Execution Plan: [Food Scanner Execution Plan — Step-by-Step](Food%20Scanner%20Execution%20Plan%20%E2%80%94%20Step-by-Step%2033f91df493868197bec3cd01d4bab225.md)
- Skill-Doc: [Coralate Food Scanner Skill — Verdichtetes Wissen](Coralate%20Food%20Scanner%20Skill%20%E2%80%94%20Verdichtetes%20Wissen%2033f91df4938681248a73ddd9aede9682.md)
- Build Log: [Food Scanner Build Log — Safety, Sequence, Sessions](Food%20Scanner%20Build%20Log%20%E2%80%94%20Safety,%20Sequence,%20Session%2033f91df49386812e92f8c91983278b21.md)
- Master Doc: [Food Scanner Master — Stack, DB-Harmonisierung, Build-Plan](Food%20Scanner%20Master%20%E2%80%94%20Stack,%20DB-Harmonisierung,%20Bu%2033f91df49386818fb7fdf8086abf4b44.md)

# Prompt für nächste Session

> Ich mache weiter mit STEP 3 Python Import-Script. Stand im Handover-Doc (Docs DB, Titel "Food Scanner Handover — STEP 1+2 Done"). Migration 001 live in Supabase `vviutyisqtimicpfqbmi`. 4 Risiken gelöst. 6 DB-Files unter `/mnt/user-data/uploads/`. Lies zuerst das Handover, dann bau das Script mit Plan-and-Execute.
>