# Food Scanner Status — STEP 3 Done, Pipeline Adjustments for Edge Function

Created: 12. April 2026 14:41
Doc ID: DOC-52
Doc Type: Architecture
Gelöscht: Yes
Last Edited: 12. April 2026 17:41
Last Reviewed: 12. April 2026
Lifecycle: Deprecated
Notes: SUPERSEDED durch Food Scanner Pipeline Status v7 (Food Scanner Pipeline Status v7 — Live, Latenz-Roadmap (Food%20Scanner%20Pipeline%20Status%20v7%20%E2%80%94%20Live,%20Latenz-Roa%2034091df493868145a075e5ea7d42313a.md)) am 2026-04-12. Content bleibt als Historie.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Volatile
Stack: Supabase
Verified: Yes

# Zweck

Snapshot nach Session 2026-04-12 Abend. STEP 1-3 abgeschlossen, Pipeline für lokale Quellen live, jetzt bereit für Cross-DB Borrowing + STEP 4 Edge Function.

**Verweise:**

- [Original Execution Plan](Food%20Scanner%20Execution%20Plan%20%E2%80%94%20Step-by-Step%2033f91df493868197bec3cd01d4bab225.md)
- [Handover STEP 1+2](Food%20Scanner%20Handover%20%E2%80%94%20STEP%201+2%20Done,%20STEP%203%20Read%2034091df4938681179d0de9dc2ff829f5.md)
- [Skill-Doc](Coralate%20Food%20Scanner%20Skill%20%E2%80%94%20Verdichtetes%20Wissen%2033f91df4938681248a73ddd9aede9682.md)

# Aktueller DB-Stand

**Supabase `vviutyisqtimicpfqbmi` (Pro Plan, 8GB Storage)**

DB-Size: 494 MB / 8 GB · nutrition_db Tabelle: 479 MB · **23.623 Foods importiert**

| Quelle | Rows | Makros% | Minerals% | Vitamine% |
| --- | --- | --- | --- | --- |
| USDA_SR | 7.793 | 99% | 97% | 87% |
| BLS | 7.140 | 100% | 100% | 65% |
| CIQUAL | 3.341 | 80% | 79% | 35% |
| COFID | 2.886 | 78% | 95% | 60% |
| NEVO | 2.328 | 100% | 98% | 96% |
| USDA_FND | 135 | 89% | 96% | 53% |

Alle Rows haben Embeddings (1536-dim), Name_en, mindestens Kalorien. OFF wurde getestet und wieder gelöscht — wird später separat integriert (siehe unten).

# Was in dieser Session passiert ist

**STEP 3 Import-Pipeline gebaut + durchgelaufen:**

- Python-Script `import_nutrition_dbs.py` (945 Zeilen) — lokal auf User-Rechner
- Alle 6 Parser validiert an echten Daten
- Probleme gelöst: USDA Foundation Lab-Sample-Noise (11k → 135 echte Foods gefiltert), NEVO Pipe-Delimiter + Komma-Decimal, CIQUAL XML Teneur-Parser, CoFID row1-Header, Windows Python-Version-Mismatch, psycopg2-Connection-String mit Session-Pooler
- Filter `enerc_kcal IS NOT NULL` eingeführt — fängt Lab-Sample-Noise in allen Quellen ab

**Supabase Plan-Upgrade:**

- Wechsel auf Pro Plan wegen 500MB Limit auf Free Tier
- Upgrade war erforderlich für OFF-Integration und später für Production-Workloads

# OFF-Status: Parkiert bis nach v1

OFF wurde getestet und wieder gelöscht. Gründe:

- Packaged-Foods haben nur 15% Mineral-Coverage, 2% Vitamin-Coverage — dramatisch schlechter als wissenschaftliche DBs
- ~1.5 Mio Rows würden DB auf 2-3 GB aufblähen
- Embedding-Kosten ~$30 statt ~$5

**Plan für OFF v1.1 (nach Edge Function Launch):**

1. OFF vollständig in `nutrition_db` importieren
2. Mit Cross-DB Borrowing verknüpfen — semantic neighbor fill von BLS/USDA_SR für fehlende Mikros
3. Embeddings generieren für semantische Suche
4. Integration in Tier 1 Retrieval (nicht nur Tier 0 Barcode)

# Anpassungen am Architektur-Plan (WICHTIG)

## 1. Barcode wird client-side dekodiert (Jann-Update)

Die React-Native-App hat einen nativen Barcode-Scanner. Der Barcode-String wird direkt an die Edge Function übergeben, kein Vision-Call nötig.

**Impact auf Edge Function Contract:**

- Request akzeptiert ENTWEDER `{barcode: "..."}` ODER `{image_url: "..."}`
- Barcode-Pfad: direkt Tier 0 (OFF Live-API), sub-second response, keine Vision-Kosten
- Vision-Pfad: Tier 1 (Vision+Retrieval) → Tier 3 (Synthesis Fallback)

## 2. User-Korrektur von Ingredient-Grammwerten (Jann-Update)

User muss in der App einzelne Ingredient-Gramm-Werte ändern oder Zutaten hinzufügen/entfernen können. System muss neue Totale liefern.

**Impact auf Edge Function Response Shape:**

Jedes Ingredient muss mit **per-Ingredient-Nutrients** zurückkommen, damit App lokal rechnen kann:

```json
{
  "ingredients": [
    {
      "name": "Lamb",
      "grams": 150,
      "matched_source": "BLS/T320000",
      "per_ingredient_nutrients": {
        "kcal": 294, "protein_g": 37.5, "fat_g": 15.9
      }
    }
  ],
  "totals": {...}
}
```

**Neuer Recalculate-Endpoint** in Edge Function:

```
POST /food-scanner/recalculate
{ ingredients: [{name, grams, matched_source}, ...] }
```

Holt nutrition_db-Rows via matched_source, rechnet neu. Keine Vision/OpenAI-Kosten. <200ms.

## 3. food_scan_cache bleibt Schema-kompatibel

Kein Schema-Change nötig. User-Korrekturen landen in `user_corrections` jsonb:

```json
{
  "ingredients_modified": [
    {"original": {...}, "corrected": {"grams": 200}}
  ],
  "final_totals": {...}
}
```

# Was fehlt bis funktionaler Scanner — Step-by-Step

## STEP 3.5 — Cross-DB Borrowing Post-Step (SOFORT)

Fill NULL-Mikros via Semantic Neighbor Search. Ziel: Vitamin-Coverage von 65% auf 90%+ bringen.

- Pro Row mit NULL-Feld: top-10 semantic neighbors in derselben food_group
- Median-Wert übernehmen, provenance markieren: `{"ca_mg": {"borrowed_from": "BLS/C553000", "method": "semantic_neighbor_median"}}`
- Pure SQL + pgvector, keine API-Kosten, ~30-60 Min Laufzeit
- Deliverable: SQL-Migration `002_cross_db_borrowing.sql`

## STEP 4 — Edge Function `food-scanner`

**Dual-Flow Edge Function** (TypeScript/Deno):

- **Tier 0 Barcode:** `{barcode}` → OFF Live-API `/api/v2/product/{barcode}` → normalisierte Response
- **Tier 1 Vision:** `{image_url}` → GPT-4o Vision mit XML Prompt → Zutaten-JSON → pgvector `match_nutrition` RPC → RRF Re-Ranking → Quality Gate
- **Tier 3 Synthesis:** Fallback GPT-4o wenn Tier 1 Quality Gate failed
- **Recalculate-Endpoint:** Pure SQL, rechnet aus Ingredient-Liste neu
- Response immer mit per-Ingredient-Breakdown
- Cache-Write in food_scan_cache mit SHA256 Image-Hash

## STEP 5 — HTML Test-Tool

- Mobile-first, iPhone-Camera-Access
- Foto-Upload + Edge Function Call
- Ergebnis-Grid mit 19 Nährwerten + Tier-Trace + Confidence
- **Editable Grammwerte** pro Zutat — Test des Recalculate-Flows
- Korrektur-Speicherung in user_corrections

## STEP 6 — Jann Handover

- Edge Function Contract-Doc (Request/Response Shapes, Error Codes, Rate Limits)
- React-Native Integration Guide
- Test-Cases für beide Flows (Barcode + Foto)

## Später (nach v1 Launch)

- **OFF v1.1:** Kompletter Import + Cross-DB Borrowing für Packaged Foods
- **TürKomp + STFCJ:** v0.5 Erweiterung für Türkische/Japanische Küche
- **Translation-Pass:** `name_en IS NULL` Zeilen via gpt-4o-mini übersetzen (Platzhalter im Schema vorhanden)
- **USDA Foundation Cleanup:** Dedup von ~50-70% der verbliebenen Rows

# Was JETZT der nächste Schritt ist

**STEP 3.5 Cross-DB Borrowing starten** (1 SQL-Migration, läuft direkt über Supabase MCP, keine User-Action nötig). Dann STEP 4 Edge Function bauen.