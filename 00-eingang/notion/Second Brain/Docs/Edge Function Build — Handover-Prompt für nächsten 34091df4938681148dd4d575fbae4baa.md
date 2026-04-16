# Edge Function Build — Handover-Prompt für nächsten Chat

Created: 12. April 2026 15:21
Doc ID: DOC-54
Doc Type: Setup Runbook
Gelöscht: No
Last Edited: 12. April 2026 17:41
Last Reviewed: 12. April 2026
Lifecycle: Deprecated
Notes: Handover-Prompt für Edge Function Build im nächsten Chat plus Rollback-Referenzen.
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: Supabase
Verified: Yes

# Follow-Up Prompt für nächsten Chat

Kopier den Prompt in einen neuen Chat im coralate Projekt. Claude hat dort frischen Context und kann Edge Function sauber bauen.

---

## Prompt zum Kopieren

```
Wir bauen jetzt die Edge Function food-scanner. Kontext:

Lese zuerst diese Notion-Docs:
1. https://www.notion.so/34091df4938681549168f91af273bc0d (Architektur v2 nach Jann-Adjustments)
2. https://www.notion.so/33f91df493868197bec3cd01d4bab225 (Original Plan - STEP 4 Details)
3. https://www.notion.so/34091df4938681c0bdb8efa67e62b864 (Letzter Progress Log)

Status:
- Supabase vviutyisqtimicpfqbmi (Pro Plan, eu-west-1)
- nutrition_db: 25.623 Foods mit Embeddings
- Cross-DB Borrowing Passes ausgeführt / laufend
- food_scan_cache Schema-Update 002 ist applied
- RPC match_nutrition(query_embedding, match_count) existiert
- OPENAI_API_KEY als Edge Function Secret hinterlegt

Task: Edge Function food-scanner bauen mit:
- 3 Flows: barcode (Tier 0 OFF Live-API), image (Tier 1 Vision+pgvector+RRF → Tier 3 Synthesis), recalculate (pure SQL)
- Per-Ingredient-Nutrient-Breakdown in Response (alle 19 Nährwerte)
- ThinkFirst XML Prompt für GPT-4o Vision mit Strict JSON Schema
- Quality Gate: logprob_mean > -0.5 AND top_cosine > 0.75
- Cache-Write in food_scan_cache mit SHA256 Image-Hash
- gpt-4o für Vision
- Sauberer Rollback + Handover-Doc für Jann

Lieferung: alle Files, Deploy via Supabase MCP, HTML Test-Tool, Notion-Doc Update.

Mach Step-by-Step-Plan, zeig jedes File vor Deploy.
```

---

# Rollback-SQL gesichert

## food_scan_cache Rollback

```sql
DROP INDEX IF EXISTS food_scan_cache_barcode_idx;
ALTER TABLE public.food_scan_cache DROP COLUMN IF EXISTS corrected_totals;
ALTER TABLE public.food_scan_cache DROP COLUMN IF EXISTS original_totals;
ALTER TABLE public.food_scan_cache DROP COLUMN IF EXISTS corrected_ingredients;
ALTER TABLE public.food_scan_cache DROP COLUMN IF EXISTS ingredients;
ALTER TABLE public.food_scan_cache DROP COLUMN IF EXISTS barcode;
```

## Borrowing Pass 2 + 3 Commands

```
python borrow_nutrients.py --execute --threshold 0.6 --min-neighbors 3 --resume
python borrow_nutrients.py --execute --threshold 0.65 --min-neighbors 4 --resume
```

## Edge Function Rollback (nach Deploy)

```
supabase functions delete food-scanner --project-ref vviutyisqtimicpfqbmi
```