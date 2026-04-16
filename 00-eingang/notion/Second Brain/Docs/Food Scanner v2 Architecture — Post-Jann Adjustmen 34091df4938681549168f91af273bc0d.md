# Food Scanner v2 Architecture — Post-Jann Adjustments, Ready for Edge Function

Created: 12. April 2026 15:16
Doc ID: DOC-53
Doc Type: Architecture
Gelöscht: Yes
Last Edited: 12. April 2026 17:41
Last Reviewed: 12. April 2026
Lifecycle: Deprecated
Notes: DEPRECATED 2026-04-13. War schon als SUPERSEDED markiert. Wird offiziell durch Architecture v8 Doc ersetzt nach Build+Test in Session 2026-04-13.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Volatile
Stack: Supabase
Verified: Yes

# Zweck

Aktueller Architektur-Stand nach Jann Voice-Call 2026-04-12. Alle Pipeline-Adjustments konsolidiert, ready für Edge Function Build. **Dieses Doc ersetzt inhaltlich** [Food Scanner Status](Food%20Scanner%20Status%20%E2%80%94%20STEP%203%20Done,%20Pipeline%20Adjust%2034091df4938681989eaadf7eba915b3e.md) als aktuelle Referenz.

**Verweise:**

- [Original Execution Plan](Food%20Scanner%20Execution%20Plan%20%E2%80%94%20Step-by-Step%2033f91df493868197bec3cd01d4bab225.md)
- [Handover STEP 1+2](Food%20Scanner%20Handover%20%E2%80%94%20STEP%201+2%20Done,%20STEP%203%20Read%2034091df4938681179d0de9dc2ff829f5.md)

# Status

| STEP | Status |
| --- | --- |
| STEP 1 Schema-Extraktion | ✅ DONE |
| STEP 2 Migration 001 | ✅ DONE (applied in Prod) |
| STEP 3 Import-Pipeline | ✅ DONE (25.623 Foods mit Embeddings) |
| STEP 3.5 Cross-DB Borrowing | ⏳ IN PROGRESS (Pass 1 läuft) |
| STEP 3.6 food_scan_cache Schema-Update | ⏳ NEXT |
| STEP 4 Edge Function food-scanner | ⏳ TODO |
| STEP 5 HTML Test-Tool | ⏳ TODO |
| STEP 6 Jann Handover | ⏳ TODO |

# Architektur-Adjustments (kumuliert nach Jann-Feedback)

## Adjustment 1 — Client-side Barcode-Decoding

App dekodiert Barcode lokal. Edge Function bekommt Barcode-String direkt, **kein Vision-Call für Packaged Foods**.

**Impact Request-Contract:**

```json
// Flow A: Barcode
{ "barcode": "4003239123456" }

// Flow B: Image (Vision)
{ "image_url": "https://...", "user_context": {...} }

// Flow C: Recalculate (nach User-Korrektur)
{ "ingredients": [{"name": "Lamb", "grams": 200, "matched_source": "BLS/T320000"}] }
```

## Adjustment 2 — Per-Ingredient-Breakdown in Response

User muss einzelne Ingredient-Gramme editieren können. App rechnet dann lokal neu (ohne neuen Edge-Function-Call).

**Impact Response-Shape:**

```json
{
  "tier_used": "tier1_vision",
  "dish_name": "Lamm-Tagine",
  "ingredients": [
    {
      "name": "Lamb",
      "grams": 150,
      "matched_source": "BLS/T320000",
      "per_ingredient_nutrients": {
        "kcal": 294, "protein_g": 37.5, "fat_g": 15.9, "carbs_g": 0,
        "na_mg": 86, "k_mg": 339, "ca_mg": 12, "fe_mg": 2.75,
        "vita_rae_ug": 0, "vitd_ug": 0, "vite_mg": 0.2,
        "thia_mg": 0.13, "ribf_mg": 0.33, "nia_mg": 8.8,
        "vitb6_mg": 0.5, "foldfe_ug": 27
      }
    }
  ],
  "totals": {...},
  "confidence": 0.87
}
```

## Adjustment 3 — Recalculate-Endpoint

Separater Pfad in der Edge Function: nimmt Ingredient-Liste mit neuen Gramm-Werten, rechnet Totals neu. **Keine Vision-Calls, keine Embedding-Calls**, reine SQL-Arithmetik. <200ms.

## Adjustment 4 — food_scan_cache Schema-Erweiterung (NEU)

Ursprüngliche Migration 001 hat die Tabelle angelegt, aber ohne Jann-spezifische Felder. Benötigt jetzt:

```sql
ALTER TABLE public.food_scan_cache ADD COLUMN IF NOT EXISTS barcode text;
ALTER TABLE public.food_scan_cache ADD COLUMN IF NOT EXISTS ingredients jsonb;
ALTER TABLE public.food_scan_cache ADD COLUMN IF NOT EXISTS corrected_ingredients jsonb;
ALTER TABLE public.food_scan_cache ADD COLUMN IF NOT EXISTS original_totals jsonb;
ALTER TABLE public.food_scan_cache ADD COLUMN IF NOT EXISTS corrected_totals jsonb;

CREATE INDEX IF NOT EXISTS food_scan_cache_barcode_idx ON public.food_scan_cache (barcode) WHERE barcode IS NOT NULL;
```

- `barcode` — Tier 0 Scans referenzierbar
- `ingredients` — schnelle jsonb-Querys ohne im `result` path-hopping
- `corrected_ingredients` — User's finale editierte Liste
- `original_totals` + `corrected_totals` — Diff-Analyse für Scan-Qualität-Feedback

# Edge Function Struktur (zu bauen)

```
supabase/functions/food-scanner/
├── index.ts           Router: barcode | image | recalculate
├── tier0_barcode.ts   OFF Live-API Call
├── tier1_vision.ts    GPT-4o Vision + pgvector + RRF + Quality Gate
├── tier3_synthesis.ts Fallback mit Bognár-Kochverlust-Faktoren
├── recalculate.ts     Pure SQL-Arithmetik aus Ingredient-Liste
├── prompts.ts         ThinkFirst XML Prompt + Strict JSON Schema
└── types.ts           TypeScript Interfaces
```

**Secrets benötigt:** `OPENAI_API_KEY` (bereits als Edge Function Secret hinterlegt).

**Modell-Auswahl:** `gpt-4o` für Vision (nicht 4o-mini — Vision-Qualität kritisch).

# food_entries Tabelle (Jann)

Existiert noch nicht. Jann baut sie separat in seiner eigenen Migration. Schema-Spec wird geliefert nachdem Edge Function fertig ist.

Wichtig: food_entries muss **alle 19 Mikros als Spalten** haben von Anfang an (BLS standard schema matchen) — damit coralate später die Daten pro User-Meal aggregieren kann.

# Cross-DB Borrowing Status (live)

**Pass 1 läuft:** threshold=0.55, min_neighbors=2, Top-20-Nachbarn-Pool. ETA 1h30, ~19.407 Rows Zielvolumen.

**Nach Pass 1:** Pass 2 mit `--threshold 0.6 --min-neighbors 3 --resume`

**Nach Pass 2:** Pass 3 mit `--threshold 0.65 --min-neighbors 4 --resume`

Self-Healing-Mechanik: mit jedem Pass wächst der Nachbarschafts-Pool (weil Pass 1 Werte schreibt die in Pass 2 als Nachbarn verfügbar sind), deshalb strengere Kriterien finden trotzdem mehr Hits.

# Was NACH diesem Doc ansteht

1. food_scan_cache ALTER TABLE Migration (5 Min)
2. Edge Function index.ts + Tier-Files schreiben (~45 Min)
3. Via Supabase MCP deployen
4. HTML Test-Tool bauen (~15 Min)
5. Deniz testet live mit echten Fotos/Barcodes
6. Handover-Doc für Jann mit Edge Function Contract + food_entries Schema-Spec