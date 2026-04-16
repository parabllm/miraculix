# Food Scanner Backend — Supabase Doku (Stand 12.04.2026)

Created: 12. April 2026 18:54
Doc ID: DOC-59
Doc Type: Architecture
Gelöscht: No
Last Edited: 12. April 2026 22:50
Last Reviewed: 12. April 2026
Lifecycle: Deprecated
Notes: Vollstaendige Supabase-Backend-Doku fuer Food Scanner Stand 12.04.2026. Gemini-Function ist Haupt-Pfad, v7 Fallback. Ab hier nur noch Parameter-Tuning, keine strukturellen Aenderungen mehr.
Stability: Stable
Stack: Supabase
Verified: Yes

# Zweck

Vollstaendige Abbildung des Supabase-Backends fuer den Food Scanner, Stand 12. April 2026. Entwicklung ist abgeschlossen, Gemini-Function ist der neue Haupt-Pfad. Weitere Arbeit besteht aus Parameter-Tuning (Match-Qualitaet, Retention-Faktoren, Modell-Wechsel), nicht mehr aus struktureller Aenderung.

# 1. Projekt-Rahmen

- **Projekt-ID:** `vviutyisqtimicpfqbmi`
- **Name:** Coralate Data Base
- **Region:** eu-west-1
- **Postgres:** 15.x mit pgvector 0.8.0, pg_cron, pg_net, pgmq
- **Edge Runtime:** Deno auf Supabase Edge Functions (V8 Isolates)

# 2. Edge Functions

## 2.1 `food-scanner-gemini` (Haupt-Pfad, Produktion)

| Attribut | Wert |
| --- | --- |
| Slug | `food-scanner-gemini` |
| ID | `7b7fa0dc-6559-4c33-a152-604c5a48e015` |
| Version | v1 (12.04.2026) |
| Status | ACTIVE |
| Verify JWT | true |
| Response-Type | `text/event-stream` (SSE) |
| Endpoint | `POST /functions/v1/food-scanner-gemini` |

**Pipeline intern:**

1. Keepalive-Short-Circuit fuer `{keepalive: true}` (pg_cron-Pings, keine API-Kosten)
2. Gemini 2.5 Flash-Lite `streamGenerateContent` mit `responseMimeType: application/json`, `thinkingBudget: 0`, `maxOutputTokens: 8192`
3. `@streamparser/json` tokenizer auf `$.ingredients.*` und `$.dish_name`
4. Jede erkannte Zutat sofort via SSE als `event: ingredient` an Client
5. Nach Vision-Ende: Batch-Embeddings via OpenAI `text-embedding-3-small` (LRU-Cache, 500 Eintraege)
6. pgvector-Matches via `match_nutrition` RPC (aktuell Promise.all, `match_nutrition_batch` geplant)
7. Finales Objekt mit allen `full_row` Makros + Mikros als `event: final`

**Env-Variablen (Secrets):**

- `GEMINI_API_KEY` (gesetzt)
- `OPENAI_API_KEY` (fuer Embeddings)
- `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`

**SSE Events:** `start` -> `dish` -> `ingredient` (N-mal) -> `vision_done` -> `embed_done` -> `match_done` -> `final` (oder `error`)

## 2.2 `food-scan-confirm` (User-Confirm Write-Pfad, neu)

| Attribut | Wert |
| --- | --- |
| Slug | `food-scan-confirm` |
| ID | `09992f5a-7ed2-47cf-b3fb-d83ea7f9f696` |
| Status | ACTIVE |
| Verify JWT | true |
| Response-Type | `application/json` |
| Endpoint | `POST /functions/v1/food-scan-confirm` |

**Zweck:** Persistiert User-bestätigten Scan inkl. Bild + Korrekturen. Wird NICHT beim initialen Scan aufgerufen, sondern erst wenn User "Speichern" im Frontend tippt.

**Request-Body:**

```json
{
  "image_base64": "...",           // komprimiertes Bild (800px, q80) vom Frontend
  "mime_type": "image/jpeg",
  "dish_name": "Burger",
  "ingredients": [...],              // finale ingredients mit matches (aus scanner-Response)
  "user_corrections": [...],          // optional, falls User bearbeitet hat
  "user_corrected": true,             // flag ob Korrekturen drin sind
  "model_version": "v7-inferred-context",
  "scan_latency_ms": 4432
}
```

**Was passiert:**

1. JWT verifizieren, user_id extrahieren
2. Bild in Storage `food-scans/{user_id}/{timestamp}_{random}.jpg` uploaden
3. `food_scan_log` row schreiben mit Totals berechnet aus ingredients[].matches[].full_row
4. Response: scan_id, image_url, Makro-Totals

**Latenz:** ~400-600ms (Storage-Upload + DB-Insert). Blockt User-Flow, aber nur beim Speichern.

## 2.3 `food-scanner` (v7, Fallback)

| Attribut | Wert |
| --- | --- |
| Slug | `food-scanner` |
| Version | v7 |
| Status | ACTIVE (Fallback) |
| Response-Type | `application/json` (synchron) |

**Features:** SHA256-Image-Cache in `food_scan_cache`, Tier0 Barcode-Lookup, Tier1 GPT-4o Vision mit Hybrid-Mode (Bognaer Retention-Faktoren, Quality Gate), optional Tier3 Synthese. Input: `image_url` aus Storage, nicht `image_base64`.

**Warum behalten:** (a) Barcode-Pfad fuer verpackte Produkte, (b) Retention-Faktoren die noch in Gemini-Function portiert werden muessen, (c) Notfall-Fallback wenn Gemini ausfaellt.

# 3. Datenbank-Schema

## 3.1 `nutrition_db` (Nutrition-Quelle)

Zentrale Tabelle, ~25.000 Eintraege, aggregiert aus USDA_FND, USDA_SR, BLS, COFID, OFF.

**Felder:** `id`, `source`, `source_id`, `name_en`, `name_original`, `name_original_lang`, `food_group`, `origin_country`, `provenance`, `confidence_code`, `embedding vector(1536)`, plus alle Makros + Mikros:

- Makros: `enerc_kcal`, `procnt_g`, `fat_g`, `choavl_g`, `fibtg_g`
- Mineralstoffe: `ca_mg`, `fe_mg`, `mg_mg`, `k_mg`, `na_mg`, `zn_mg`
- Vitamine: `vitc_mg`, `vitd_ug`, `vite_mg`, `vita_rae_ug`, `thia_mg` (B1), `ribf_mg` (B2), `nia_mg` (B3), `vitb6_mg`, `foldfe_ug`
- Metadaten: `created_at`, `updated_at`, `name_en_source`

**Index:** HNSW auf `embedding` mit `m=16`, `ef_construction=64`. Query via `embedding <=> query_vector`. Speicher ~400 MB gesamt (Tabelle + Index), passt in shared_buffers.

**Bekannte Luecken:** B6, Folat, Vit D, Vit E teilweise NULL (laufende DB-Erweiterung via Cross-DB-Borrowing Skript parallel). Einige Standard-Items fehlen (z.B. "white hamburger bun", "french fries"), was aktuell zu Fehl-Matches fuehrt.

## 3.2 `food_scan_cache`

SHA256-basierter Scan-Cache fuer v7 (nicht von Gemini-Function genutzt). Spart bei wiederholten Bildern den kompletten Vision-Call.

**Felder:** `scan_hash` (PK), `tier_used`, `result jsonb`, `created_at`

**CHECK-Constraint** auf `tier_used`: `tier0_barcode`, `tier1_vision`, `tier1_vision_hybrid`, `tier3_synthesis`

## 3.3 `food_scan_log`

Scan-History der User. Wird nur bei User-Confirm geschrieben, nicht bei jedem Scan.

**Felder:** `id uuid`, `user_id uuid → auth.users CASCADE`, `image_url text`, `image_storage_path text`, `dish_name text`, `ingredients jsonb`, `total_kcal numeric`, `total_protein_g`, `total_carbs_g`, `total_fat_g`, `user_corrected bool`, `user_corrections jsonb`, `model_version text`, `scan_latency_ms int`, `created_at timestamptz`, `confirmed_at timestamptz`.

**Indizes:** `(user_id, created_at DESC)` fuer Timeline, `confirmed_at WHERE NOT NULL` fuer Analytics.

**RLS:** `auth.uid() = user_id` — jeder User sieht nur eigene Scans.

**Nutzung:** History-View in App, Re-Coaching durch Cora ("du hattest gestern Pizza"), Live-Analytics via Dashboards, Retention-Analysen welche Gerichte gescannt werden.

## 3.4 `food_entries`

User-Food-Logs. Pro Entry heute: `kcal` aggregiert, pro Tag: Protein, Carbs, Fat, Fiber (in `food_day_records`). **TODO:** Per-Entry Makro-Spalten (protein_g, carbs_g, fat_g, fiber_g) ergaenzen, damit Historie pro Eintrag auswertbar ist.

## 3.4 `cora_memories` (separater Kontext, nicht Food-Scanner)

Claude-Context-Memories mit GDPR CASCADE auf auth.users, pgvector, LZ4 compressed snapshots. Gehoert zu Cora AI System, nicht zum Food Scanner direkt.

## 3.5 `knowledge_chunks` (Cora, 6 Eintraege)

Knowledge-Base fuer Cora-System. Geplanter Upgrade-Pfad auf pgvector-Similarity ab ~50 Chunks.

# 4. RPCs (Remote Procedure Calls)

## 4.1 `match_nutrition(query_embedding vector, match_count int)` - AKTIV

Top-K Nearest-Neighbor-Suche in nutrition_db via Cosine-Distance. Gibt `id`, `source`, `source_id`, `name_en`, `similarity`, `full_row jsonb` zurueck.

## 4.2 `match_nutrition_multi(jsonb, int)` - DEPRECATED

In v6 gebaut, in v7 zurueckgerollt weil nur ~500ms Ersparnis bei komplexerem Code. Bleibt als Referenz, aktuell nicht genutzt.

## 4.3 `match_nutrition_batch(embeddings vector[], match_count int)` - GEPLANT

Echter CROSS JOIN LATERAL + unnest(WITH ORDINALITY) Batch-Query. Soll Promise.all in Gemini-Function ersetzen. Erwarteter Gewinn 300-600ms. Implementation steht noch aus.

# 5. Cron-Jobs

## 5.1 `food-scanner-keepalive`

- **Job-ID:** 3
- **Schedule:** `*/1 * * * *` (jede Minute, erhöht von `*/2` am 12.04.2026)
- **Status:** active
- **Aktion:** `net.http_post` auf `food-scanner-gemini` mit `{keepalive: true}`
- **Zweck:** Worker-Isolate warm halten, Cold-Starts eliminieren, Embedding-LRU-Cache persistieren

Function hat Short-Circuit fuer den Keepalive-Flag - kein API-Call an Gemini/OpenAI, keine Kosten.

# 6. Storage

## 6.1 Bucket `food-scans`

- **Visibility:** public
- **Policies:** anon INSERT, anon SELECT
- **Zweck:** Bilder fuer v7 (die per `image_url` arbeitet). Gemini-Function nutzt Base64 inline, braucht Bucket nicht zwingend.

# 7. Datenfluss

```
Client (Expo/RN)
  |
  | 1. expo-image-manipulator: resize 800px long-edge, JPEG q80
  | 2. SSE POST /functions/v1/food-scanner-gemini
  |    body: { image_base64, mime_type }
  v
Edge Function (Deno, warm via pg_cron)
  |
  | 3. Gemini 2.5 Flash-Lite streamGenerateContent (SSE von Google)
  |    -> @streamparser/json parst `$.dish_name` + `$.ingredients.*`
  |    -> jede Zutat sofort via SSE zum Client (`event: ingredient`)
  |
  | 4. OpenAI text-embedding-3-small (batch, LRU-Cache)
  |    -> 1536-dim Vektor pro Zutat
  |
  | 5. match_nutrition RPC fuer jeden Vektor (pgvector HNSW)
  |    -> Top-5 matches mit full_row pro Zutat
  |
  | 6. Finales JSON via SSE event: final
  v
Client
  - streamt Zutaten einzeln in UI (fade-in)
  - nach `match_done`: Makros + Mikros aus full_row eintraeufeln
```

# 8. Latenz-Profil (Stand v1, Burger-Test 12.04.2026)

| Phase | Dauer | Anteil |
| --- | --- | --- |
| Gemini Vision Streaming | ~3-4s | 60-70% |
| OpenAI Embedding Batch | ~0.3-0.5s | 8% |
| pgvector Matches (N parallel) | ~1-2s | 20-30% |
| Total end-to-end | ~5-6s | 100% |
| First ingredient (SSE) | ~1-2s | - |

**Vergleich:** v7 (GPT-4o) 8-12s end-to-end, komplett synchron. Gemini-Function 3-4x schneller + perceived latency <2s durch SSE.

# 9. Kosten-Profil

| Komponente | Kosten pro Scan |
| --- | --- |
| Gemini 2.5 Flash-Lite | ~$0.00055 |
| OpenAI Embeddings (batch) | ~$0.0001 |
| Supabase Edge Function Invocation | ~$0.000002 |
| **Total** | **~$0.0007** |

Bei 100 Scans/User/Monat = $0.07/User/Monat. Coralate-Target (<$1/User/Monat fuer AI-Komponenten) wird massiv unterboten.

Zum Vergleich v7 (GPT-4o): ~$0.0045/Scan = $0.45/User/Monat.

# 10. Offene Parameter-Optimierungen

Keine strukturellen Aenderungen mehr, nur Werte-Tuning:

1. **Match-Qualitaet**: `match_nutrition` erweitern um food_group-Filter und source_ranking-Tiebreaker. Verhindert falsche semantische Treffer ("burger bun" -> "Tofu burger").
2. **Retention-Faktoren**: Bognaer-Tabellen aus v7 in Gemini-Function portieren. Grammaturen bei gekochten Zutaten korrigieren.
3. **Prompt-Zwang** auf FNDDS-konforme Begriffe statt freier Bezeichnungen.
4. **`confidence_score`** pro Ingredient ausgeben (cosine x food_group_match x source_rank). Niedrig-Confidence im UI markieren.
5. **`match_nutrition_batch`** RPC implementieren (CROSS JOIN LATERAL). Ersetzt Promise.all.
6. **nutrition_db** weiter befuellen: fehlende Standard-Items und NULL-Mikros (B6, Folat, Vit D, Vit E).
7. **Retention-Korrektur** abhaengig von `preparation`-Feld (gebraten vs gekocht vs roh).

# 11. Monitoring

- **Langfuse:** instrumentiert fuer Cora-Calls, nicht direkt fuer Food-Scanner (optional nachruesten)
- **Supabase Function Logs:** Dashboard > Edge Functions > Logs pro Invocation
- **pg_cron job_run_details:** `SELECT * FROM cron.job_run_details WHERE jobid = 2 ORDER BY start_time DESC LIMIT 10`
- **Edge Function Metrics:** Boot-Time, Wall-Clock-Time, CPU-Time im Supabase Dashboard

# 12. Frontend-Integration

Separates Dokument: [Food Scanner - Frontend Integration Spec fuer Jann (v1)](Food%20Scanner%20%E2%80%94%20Frontend%20Integration%20Spec%20fuer%20Jann%2034091df4938681d1a3d7d6ae63c054bb.md)

Enthaelt Expo/RN Code, Zustand-Store-Pattern, SSE-Handling, UI-States.

# 13. Verwandte Research

[Food Scanner Deep Research - Vision-Modelle, pgvector, Edge-Pipeline (April 2026)](Food%20Scanner%20Deep%20Research%20%E2%80%94%20Vision-Modelle,%20pgvec%2034091df4938681268440c62c1f0cf49c.md)

Konsolidierte Erkenntnisse aus Perplexity + Gemini Deep Research, auf denen die Gemini-Function-Architektur basiert.

# 14. Zustand

**Stabil und produktiv:** Edge Function, Datenbank-Schema, RPCs, Storage, Cron-Jobs, Frontend-Contract. Keine strukturellen Aenderungen geplant, nur Parameter-Tuning. Die Architektur ist der Ausgangspunkt fuer Coralate-Produktion.