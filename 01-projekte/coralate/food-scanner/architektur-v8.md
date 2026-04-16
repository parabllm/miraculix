---
typ: aufgabe
name: "Food Scanner Architektur v8 (Master)"
projekt: "[[food-scanner]]"
status: erledigt
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[jann-allenberger]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Kompletter Food-Scanner-Flow, Stand 2026-04-13, Pipeline End-to-End validiert, Production-Ready für Frontend-Integration durch Jann. Dies ist die einzige kanonische Quelle - ersetzt alle vorherigen Architektur-Docs.

## Executive Summary

User scannt Essen via Foto oder Barcode. System erkennt Gericht und Zutaten, matched gegen 25.558 Lebensmittel in Nutrition-DB, liefert Kalorien und Mikronährstoffe. User bestätigt oder korrigiert. Eintrag landet als `confirmed` im Nutzer-Log.

**In einem Satz:** Client lädt Bild in Supabase Storage. Edge Function `food-scanner` analysiert via Gemini 2.5 Flash Lite und streamt Ingredients per SSE zurück. Embeddings (OpenAI text-embedding-3-small) werden gegen `nutrition_db.embedding` (pgvector HNSW) gematched. Edge Function `food-scan-confirm` persistiert finale, optional korrigierte Ergebnisse.

**Validiert 2026-04-13:**
- Login mit ES256 JWT (Supabase Auth, modernes asymmetrisches Setup)
- Storage Upload mit User-scoped RLS
- Image Scan auch mit großen Bildern über 100 KB (base64-Bugfix in v13)
- SSE Streaming mit progressiven Events: `start` → `dish` → `ingredient[]` → `vision_done` → `embed_done` → `match_done` → `final`
- Cache mit 6-8-fachem Speedup bei identischem Bild (5s → 0.6s)
- User-Korrektur als `user_corrected: true` gespeichert
- Barcode-Tier über Open Food Facts API (instant)

## Stack auf einen Blick

- **Frontend:** React Native + Expo
- **Image Resize:** expo-image-manipulator (App) / sharp (Test-Skript), 800px JPEG q=0.85
- **Storage:** Supabase Storage Bucket `food-scans`, privat, 5 MB Limit
- **Auth:** Supabase Auth (ES256 asymmetric)
- **Backend:** Supabase Edge Functions (Deno) → `food-scanner` (v13), `food-scan-confirm` (v5)
- **Vision LLM:** Gemini 2.5 Flash Lite
- **Embeddings:** OpenAI text-embedding-3-small (1536-dim)
- **Vector Index:** pgvector HNSW mit Cosine Similarity
- **Database:** Supabase Postgres (`food_scan_log`, `nutrition_db`)
- **Barcode-Tier:** Open Food Facts API v2

## End-to-End Flow

1. User tippt Foto auf oder scannt Barcode
2. Frontend resized Bild auf 800px Breite, JPEG Quality 0.85 (~80-130 KB)
3. Upload nach `food-scans/{user_id}/{timestamp}_{uuid}.jpg`
4. POST an `/functions/v1/food-scanner` mit `{ storage_path }` oder `{ barcode }`
5. Edge Function `food-scanner`:
   - Validiert JWT via `auth.getUser()`
   - Berechnet SHA256 vom Bild als `scan_hash`
   - Cache-Lookup - bei HIT: instant `final` Event, bei MISS: weiter
   - INSERT `food_scan_log` mit `status='processing'`
   - Streamt zu Gemini 2.5 Flash Lite, parsed progressiv Ingredients
   - Sendet SSE-Events (dish, ingredient, vision_done)
   - Embedding aller Ingredients via OpenAI Batch-Call
   - Parallele `match_nutrition` RPC-Calls
   - Berechnet Totals (kcal, P, C, F + 16 Mikronährstoffe)
   - UPDATE `food_scan_log` mit `status='pending_confirmation'`
   - Sendet `final` SSE-Event
6. App zeigt UI-Liste, User reviewt und editiert optional
7. POST an `/functions/v1/food-scan-confirm` mit `{ scan_id, user_corrected, user_corrections? }`
8. Edge Function `food-scan-confirm`:
   - Validiert JWT
   - Prüft Ownership (`scan.user_id === jwt.user_id`)
   - Bei `user_corrected: true`: Recalculate Totals
   - UPDATE `food_scan_log` mit `status='confirmed'`, `confirmed_at=now()`
9. App zeigt Final-Bestätigung, refresht Daily Macros

## Gemessene Latenzen (2026-04-13)

- Storage Upload (~80 KB): 200-400ms
- Vision-Call + Streaming: 1.5-2.5s
- Embedding Batch: 0.5-0.8s
- Vector Match: 0.6-1.0s
- **Cold Total: 3.5-5.5s**
- **Cache-Hit Total: 600-900ms**
- Confirm Call: 100-300ms

## Storage Layer

### Bucket `food-scans`

- Public: false
- File Size Limit: 5 MB
- Allowed MIME Types: `image/jpeg`, `image/png`
- Path-Schema: `food-scans/{user_id}/{timestamp}_{uuid_8chars}.jpg`

User-ID-Ordner ist der Sicherheitsanker - RLS erkennt Zugehörigkeit über `storage.foldername(name)[1]`.

### RLS Policies

```sql
CREATE POLICY food_scans_user_insert ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'food-scans'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Analog für SELECT und DELETE
```

### Warum Storage-First statt Bild-im-Body

- Bild ist persistent, später in Account-Verlauf oder Cora-Memory-Pipeline nutzbar
- Edge Function bleibt klein (nur `storage_path` als String, kein Multipart-Body)
- RLS greift schon auf Storage-Ebene
- Re-Tries möglich - wenn Edge Function fehlschlägt, Bild ist noch da
- Saubere Trennung Storage vs. Compute

## Auth Pattern (KRITISCH)

### Problem: ES256 vs Edge Function Gateway

Projekt nutzt modernes asymmetrisches JWT-Setup (ES256 mit JWKS). User-JWTs sind ES256-signiert. Storage akzeptiert sie (HTTP 200). Edge-Function-Gateway lehnt sie mit `verify_jwt=true` ab (HTTP 401) - das Gateway kann das asymmetrische Format aktuell nicht validieren.

### Lösung: verify_jwt=false + Body-Auth

Beide Edge Functions deployed mit `verify_jwt=false`. JWT wird im Function-Body über `auth.getUser()` als erste Aktion validiert:

```ts
const authHeader = req.headers.get('Authorization');
if (!authHeader?.startsWith('Bearer ')) {
  return errorResponse('unauthorized', 'Missing Bearer token', 401);
}
const userJwt = authHeader.slice('Bearer '.length);

const userClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  global: { headers: { Authorization: `Bearer ${userJwt}` } },
  auth: { persistSession: false }
});

const { data, error } = await userClient.auth.getUser(userJwt);
if (error || !data?.user) return errorResponse('unauthorized', 'Invalid JWT', 401);
const userId = data.user.id;
```

Identische Sicherheit zu `verify_jwt=true`, nur an anderer Stelle validiert. `auth.getUser()` ruft den Auth-Server der JWT kryptografisch gegen Private Key prüft. Storage-Path-Check + RLS sichern ab.

### Frontend-Keys

- **Anon-Key (Publishable):** `sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW` (NICHT Legacy HS256)
- **JWT:** nach Login via `/auth/v1/token`, ES256-signiert, im `Authorization: Bearer <jwt>` Header

## Edge Function `food-scanner` (v13)

- **Slug:** `food-scanner`, `verify_jwt: false`
- **Endpoint:** `POST https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scanner`

### SSE-Event-Sequenz

- `start` → `{ scan_id, ts, model, version, cached? }` - sofort nach JWT + Cache-Check
- `dish` → `{ dish_name, ts }` - sobald Vision Gerichtsnamen extrahiert
- `ingredient` → `{ index, ingredient, ts }` - pro erkannte Zutat einzeln
- `vision_done` → `{ ingredient_count, ts }`
- `embed_done` → `{ ts }`
- `match_done` → `{ ts }`
- `final` → `{ scan_id, dish_name, ingredients[], totals, tier_used, model, version, latency_ms, cached }`
- `error` → `{ scan_id, message, ts }`

Bei Cache-HIT nur `start` und `final` mit `cached: true`.

### Gemini-Konfiguration (NICHT ändern ohne Test)

```ts
{
  model: 'gemini-2.5-flash-lite',
  generationConfig: {
    temperature: 0.1,
    maxOutputTokens: 8192,
    responseMimeType: 'application/json',
    thinkingConfig: { thinkingBudget: 0 }
  }
}
```

**Warum `thinkingBudget: 0`:** Gemini 2.5 Flash Lite hat Thinking-Mode der Output-Tokens silent verbraucht. Ohne diesen Parameter werden 50-80% der Tokens für Thinking benutzt, JSON wird abgeschnitten, Parser-Errors.

### Vision-Prompt (gekürzt)

- Analyze the PRIMARY PLATE only
- Return STRICT JSON mit `dish_name` und `ingredients[]`
- Naming: base food as in nutrition database, concrete not category, decompose if nutritionally relevant, skip garnishes under 5g
- Inferred Ingredients: invisible items (cooking oil, butter, dressing, eggs in batter) mit realistic grams hinzufügen
- Output: 3-13 ingredients max, kein Prosa außerhalb JSON

### Embedding-Strategie

Visible Ingredients: `preparation + name`. Inferred: nur `name`. Alle in einem Batch-Call:

```ts
const embedTexts = visionIngredients.map(ing =>
  ing.visibility === 'inferred'
    ? ing.name.toLowerCase()
    : `${ing.preparation || ''} ${ing.name}`.trim().toLowerCase()
);
```

Model: `text-embedding-3-small` (1536-dim).

### Match-Logik

Parallele `match_nutrition` RPC-Calls, einer pro Ingredient. TOP-5 intern, TOP-3 ans Frontend für Debug. Best Match für `per_ingredient_nutrients`.

### Critical Bugfix: base64 chunked encoding (v13)

**Bug bis v12:** `btoa(String.fromCharCode(...new Uint8Array(bytes)))` crashte mit "Maximum call stack size exceeded" bei Bildern ab 100 KB. Grund: Spread-Operator erzeugt zu viele Funktions-Argumente.

**Fix in v13:**
```ts
function arrayBufferToBase64(bytes: ArrayBuffer): string {
  const uint8 = new Uint8Array(bytes);
  const chunkSize = 8192;
  let binary = '';
  for (let i = 0; i < uint8.length; i += chunkSize) {
    binary += String.fromCharCode.apply(null, Array.from(uint8.subarray(i, i + chunkSize)));
  }
  return btoa(binary);
}
```

### Barcode-Tier

Bei `{ barcode }`: Cache-Lookup mit `scan_hash = 'bc_' + barcode` → bei MISS Open Food Facts API → Nutriments auf 20-Spalten-Schema mappen → scale auf `serving_quantity` → Return JSON (kein Stream).

### Keepalive (Cold-Start-Mitigation)

`POST { keepalive: true }` → `{ ok: true, warm: true }`. App kann periodisch warm halten.

## PG Vector Matching (nutrition_db)

### Datenbestand: 25.558 Einträge aus 7 Quellen

- USDA_SR: 7.793 (US Department of Agriculture Standard Reference)
- BLS: 7.140 (Bundeslebensmittelschlüssel, DE)
- CIQUAL: 3.341 (ANSES, FR)
- COFID: 2.886 (UK Composition of Foods)
- NEVO: 2.328 (NL)
- OFF: 2.000 (Open Food Facts, Marken - noch keine `name_en`)
- USDA_FND: 135 (Foundation Foods, neue Methodologie)

Alle haben: `name_original`, `name_en` (sofern verfügbar), 20 Nutrient-Spalten, `embedding` (1536-dim auf `name_en` via OpenAI), `food_group`, `food_group_normalized`.

### 20-Spalten Nutrient Schema (pro 100g)

- **Energie:** `enerc_kcal`
- **Makros:** `procnt_g`, `fat_g`, `choavl_g`, `fibtg_g`
- **Mineralien:** `na_mg`, `k_mg`, `ca_mg`, `fe_mg`, `mg_mg`, `zn_mg`
- **Vitamine:** `vita_rae_ug` (A), `vitd_ug` (D), `vite_mg` (E), `vitc_mg` (C), `thia_mg` (B1), `ribf_mg` (B2), `nia_mg` (B3), `vitb6_mg`, `foldfe_ug` (Folat DFE)

### Indexes

```sql
CREATE INDEX nutrition_db_embedding_idx
  ON public.nutrition_db USING hnsw (embedding vector_cosine_ops);

CREATE UNIQUE INDEX nutrition_db_source_uid
  ON public.nutrition_db USING btree (source, source_id);

CREATE INDEX nutrition_db_food_group_idx ON public.nutrition_db USING btree (food_group);
CREATE INDEX idx_nutrition_food_group_normalized ON public.nutrition_db USING btree (food_group_normalized);
```

### match_nutrition RPC

```sql
CREATE OR REPLACE FUNCTION public.match_nutrition(
  query_embedding vector, match_count integer DEFAULT 50
)
RETURNS TABLE(id bigint, source text, source_id text, name_en text, name_original text,
              food_group text, origin_country text, similarity double precision, full_row jsonb)
LANGUAGE sql STABLE
SET search_path TO 'public'
AS $$
  SELECT n.id, n.source, n.source_id, n.name_en, n.name_original,
         n.food_group, n.origin_country,
         1 - (n.embedding <=> query_embedding) AS similarity,
         to_jsonb(n) AS full_row
  FROM public.nutrition_db n
  WHERE n.embedding IS NOT NULL
  ORDER BY n.embedding <=> query_embedding
  LIMIT match_count;
$$;
```

Cosine-Distance `<=>` liefert 0 (identisch) bis 2 (entgegengesetzt). `1 - distance` ergibt similarity 0-1.

### Bekannte Limitations

- **Avocado vs Avocado-Oil-Problem:** Embeddings semantisch nah, nährwerttechnisch grundverschieden (160 kcal vs 884 kcal/100g). Fix → Multi-Layer Matching mit `food_group_normalized` Filter (siehe [[roadmap]]).
- **OFF-Einträge ohne `name_en`:** Embeddings auf `name_original` (FR/DE). Funktioniert via multilingual Model, aber nicht optimal.
- **`food_group_normalized` nullable:** Backfill für 25.558 Einträge in Roadmap.

## Edge Function `food-scan-confirm` (v5)

- **Slug:** `food-scan-confirm`, `verify_jwt: false`

### Request-Shape mit Korrekturen

```json
{
  "scan_id": "uuid",
  "user_corrected": true,
  "user_corrections": [
    {
      "name": "avocado",
      "grams": 80,
      "preparation": "sliced",
      "visibility": "visible",
      "matches": [{ "...": "unverändert" }],
      "per_ingredient_nutrients": { "...": "NEU berechnet für 80g" },
      "matched_source": "USDA_SR/173573"
    }
  ]
}
```

**Wichtig:** `user_corrections` muss KOMPLETTE Liste sein, nicht nur geänderte Items. Frontend verantwortlich für `per_ingredient_nutrients` Recalc bei Grams-Änderung.

### Server-side Recalculation

```ts
function recomputeTotals(ingredients) {
  let kcal = 0, p = 0, c = 0, f = 0;
  for (const ing of ingredients) {
    const n = ing.per_ingredient_nutrients || {};
    kcal += Number(n.enerc_kcal || 0);
    p += Number(n.procnt_g || 0);
    c += Number(n.choavl_g || 0);
    f += Number(n.fat_g || 0);
  }
  return {
    total_kcal: Math.round(kcal),
    total_protein_g: Number(p.toFixed(1)),
    total_carbs_g: Number(c.toFixed(1)),
    total_fat_g: Number(f.toFixed(1))
  };
}
```

### Sicherheits-Checks

1. JWT gültig (`auth.getUser()` erfolgreich)
2. Scan existiert in DB
3. Scan gehört zum aufrufenden User (`scan.user_id === userId`) → sonst 403
4. Scan nicht im Status `failed` → sonst 409

## Cache-Strategie

### Designentscheidung

**Keine separate Cache-Tabelle.** `food_scan_log` ist beides: User-Historie UND Cache-Layer.

### Begründung

- Cache-Lifecycle = User-Log-Lifecycle (Account-Löschung → Cache weg via CASCADE)
- Eine RLS-Policy weniger Komplexität
- Cache-Hits sind immer User-eigene Scans (kein Cross-User-Sharing, Privacy-Plus)
- Vision-Calls teuer (5+ Sekunden, Gemini-Kosten) - jeder Cache-Hit spart

### Cache-Lookup

```ts
const { data: cached } = await serviceClient
  .from('food_scan_log')
  .select('id, dish_name, ingredients, total_kcal, ...')
  .eq('user_id', userId)
  .eq('scan_hash', scanHash)
  .in('status', ['pending_confirmation', 'confirmed'])
  .order('created_at', { ascending: false })
  .limit(1)
  .maybeSingle();
```

### Bei Cache-HIT

Neuer `food_scan_log`-Eintrag INSERTet mit kopierten Daten. Neuer Eintrag hat frischen Storage-Path, aber gleichen Hash, gleiche Ingredients, gleiche Totals. Status startet bei `pending_confirmation` - User muss trotzdem bestätigen.

### Performance

- Run 1 (cold): 5.158ms
- Run 2 (cache): 903ms
- Run 3 (cache): 608ms
- **Speedup: 6-8-fach**

## Schema: food_scan_log

```sql
CREATE TABLE public.food_scan_log (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid REFERENCES auth.users(id),

  image_url           text,                    -- Legacy
  image_storage_path  text,                    -- 'user_id/ts_uuid.jpg'
  barcode             text,
  scan_hash           text,                    -- SHA256 vom Bild ODER 'bc_<barcode>'

  dish_name           text,
  ingredients         jsonb,                   -- Array von EnrichedIngredient[]
  total_kcal          numeric,
  total_protein_g     numeric,
  total_carbs_g       numeric,
  total_fat_g         numeric,

  user_corrected      boolean DEFAULT false,
  user_corrections    jsonb,

  status              text DEFAULT 'processing'
                      CHECK (status IN ('processing', 'pending_confirmation', 'confirmed', 'failed')),
  tier_used           text
                      CHECK (tier_used IS NULL OR tier_used IN ('tier0_barcode', 'tier1_vision', 'tier1_vision_hybrid')),

  model_version       text,
  scan_latency_ms     integer,
  error_message       text,
  failed_at           timestamptz,

  created_at          timestamptz DEFAULT now(),
  confirmed_at        timestamptz
);
```

### Status-State-Machine

- `processing` → initial INSERT während Vision-Call
  - Fehler → `failed` (Endstatus)
  - Erfolg → `pending_confirmation`
- `pending_confirmation` → Vision fertig, wartet auf User
  - User-Confirm → `confirmed` (Endstatus, zählt in Daily Macros)

### EnrichedIngredient JSON-Shape

```ts
interface EnrichedIngredient {
  name: string;                     // "avocado"
  grams: number;
  preparation?: string;             // "sliced"
  visibility: 'visible' | 'inferred';
  matches: NutritionMatch[];        // Top-3 Kandidaten
  matched_source: string | null;    // "USDA_SR/173573"
  per_ingredient_nutrients: {       // skaliert auf grams
    enerc_kcal, procnt_g, fat_g, choavl_g, fibtg_g,
    na_mg, k_mg, ca_mg, fe_mg, mg_mg, zn_mg,
    vita_rae_ug, vitd_ug, vite_mg, vitc_mg,
    thia_mg, ribf_mg, nia_mg, vitb6_mg, foldfe_ug
  };
}
```

## Deployment Reference

### Aktuelle Versionen (2026-04-13)

- `food-scanner` Edge Function: **v13** (verify_jwt=false, base64 chunked encoding)
- `food-scan-confirm` Edge Function: **v5**
- `nutrition_db`: 25.558 Einträge mit HNSW Embedding Index
- Storage Bucket `food-scans`: privat, 5 MB Limit, JPEG/PNG

### Wichtige Konstanten

- **SUPABASE_URL:** `https://vviutyisqtimicpfqbmi.supabase.co`
- **Region:** eu-west-1 (Projekt "Coralate Data Base")
- **Plan:** Pro
- **Anon Publishable Key:** `sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW`
- **Test User:** `deniz.oezbek@coralate.de` (UID `f440d7e4-1dd1-429e-9b23-e131ab3e3807`)

### Edge Functions Deployment

Via Supabase MCP `deploy_edge_function` mit Parameter `verify_jwt: false`.

### Wichtige Migrations

- `food_scans_storage_secure` - Bucket auf privat, alte anon-Policies entfernt
- `food_scan_log_pipeline_fields` - status, scan_hash, barcode, tier_used, error_message, failed_at
- `drop_unused_food_scan_cache` (2026-04-13) - alte Cache-Tabelle entfernt, food_scan_log ist SSOT

## Verwandtes

- [[frontend-integration]] - React-Native-spezifische Integration für Jann
- [[prompt-log]] - Vision-Prompt-Versionierung
- [[roadmap]] - Multi-Layer Matching, Nutrient-DB-Erweiterungen
