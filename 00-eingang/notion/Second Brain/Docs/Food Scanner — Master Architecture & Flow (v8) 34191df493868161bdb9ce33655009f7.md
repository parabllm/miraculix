# Food Scanner — Master Architecture & Flow (v8)

Created: 13. April 2026 15:21
Doc ID: DOC-62
Doc Type: Architecture
Gelöscht: No
Last Edited: 13. April 2026 15:51
Last Reviewed: 13. April 2026
Lifecycle: Active
Notes: Master-Doc nach Pipeline-Validierung 13.04.2026. Ersetzt DOC-51, DOC-52, DOC-53, DOC-54, DOC-55, DOC-56, DOC-58, DOC-59, DOC-61. Research-Docs DOC-57 und DOC-60 bleiben aktiv. Pipeline End-to-End validiert mit Test-Skript inkl. SSE Streaming, Cache, User Correction.
Pattern Tags: Auth, Enrichment, OCR
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: React Native, Supabase
Verified: No

# Food Scanner — Master Architecture & Flow (v8)

> **Stand:** 13.04.2026 — Pipeline End-to-End validiert. Status: Production-Ready für Frontend-Integration.
> 

> 
> 

> Dieses Doc ist die einzige Quelle für den kompletten Food-Scanner-Flow. Vorherige Docs (DOC-51 bis DOC-59, DOC-61) sind deprecated. Research-Docs DOC-57 und DOC-60 bleiben aktiv als Referenz.
> 

## Inhaltsverzeichnis

1. Executive Summary
2. End-to-End Flow
3. Storage Layer
4. Auth Pattern (ES256 + verify_jwt=false)
5. Edge Function `food-scanner`
6. PG Vector Matching (nutrition_db)
7. Edge Function `food-scan-confirm`
8. Cache-Strategie
9. Schema: `food_scan_log`
10. Test-Pipeline Skript
11. UI-Konzept für Jann
12. Open Issues & Roadmap
13. Migrations & Deployment Reference
14. Verwandte Docs

---

## 1. Executive Summary

Der Food Scanner ist die Tracking-Säule von coralate. Nutzer:innen scannen Essen via Foto oder Barcode, das System erkennt Gericht und Zutaten, matched gegen 25.558 Lebensmittel in der Nutrition-DB, liefert Kalorien und Mikronährstoffe, User bestätigt oder korrigiert, Eintrag landet als `confirmed` im Nutzer-Log.

### Architektur in einem Satz

Client lädt Bild in Supabase Storage hoch. Edge Function `food-scanner` analysiert via Gemini 2.5 Flash Lite und streamt Ingredients per SSE zurück. Embeddings (OpenAI text-embedding-3-small) werden gegen `nutrition_db.embedding` (pgvector HNSW) gematched. Edge Function `food-scan-confirm` persistiert finale, optional korrigierte Ergebnisse.

### Was funktioniert (validiert 13.04.2026)

- Login mit ES256 JWT (Supabase Auth, modernes asymmetrisches Setup)
- Storage Upload mit User-scoped RLS
- Image Scan läuft auch mit großen Bildern über 100 KB nach base64-Bugfix in v13
- SSE Streaming mit progressiven Events: `start` → `dish` → `ingredient[]` → `vision_done` → `embed_done` → `match_done` → `final`
- Cache mit 6-8-fachem Speedup bei identischem Bild (5s auf 0.6s)
- User-Korrektur wird als `user_corrected: true` gespeichert
- Confirmation persistiert finale Totals
- Barcode-Tier über Open Food Facts API (kein Vision-Call, instant)

### Stack auf einen Blick

- **Frontend:** React Native + Expo
- **Image Resize:** expo-image-manipulator (App) / sharp (Test-Skript), 800px JPEG q=0.85
- **Storage:** Supabase Storage Bucket `food-scans`, privat, 5 MB Limit
- **Auth:** Supabase Auth (ES256 asymmetric)
- **Backend:** Supabase Edge Functions (Deno) → `food-scanner`, `food-scan-confirm`
- **Vision LLM:** Gemini 2.5 Flash Lite
- **Embeddings:** OpenAI text-embedding-3-small (1536-dim)
- **Vector Index:** pgvector HNSW mit Cosine Similarity
- **Database:** Supabase Postgres (`food_scan_log`, `nutrition_db`)
- **Barcode-Tier:** Open Food Facts API v2

---

## 2. End-to-End Flow

### Schrittweiser Ablauf

1. User tippt Foto auf oder scannt Barcode in der App
2. Frontend resized das Bild auf 800px Breite, JPEG Quality 0.85 (ergibt ~80-130 KB)
3. Upload zu Supabase Storage unter `food-scans/{user_id}/{timestamp}_{uuid}.jpg`
4. POST an `/functions/v1/food-scanner` mit `{ storage_path }` oder `{ barcode }`
5. Edge Function `food-scanner`:
    - Validiert JWT via `auth.getUser()`
    - Berechnet SHA256 vom Bild als `scan_hash`
    - Cache-Lookup in `food_scan_log` — bei HIT: instant `final` Event, bei MISS: weiter zu Vision-Pipeline
    - INSERT `food_scan_log` mit `status='processing'`
    - Streamt zu Gemini 2.5 Flash Lite, parsed progressiv Ingredients
    - Sendet SSE-Events (dish, ingredient, vision_done)
    - Embedding aller Ingredients via OpenAI Batch-Call
    - Parallele `match_nutrition` RPC-Calls
    - Berechnet Totals (kcal, P, C, F, plus 16 Mikronährstoffe)
    - UPDATE `food_scan_log` mit `status='pending_confirmation'`
    - Sendet `final` SSE-Event mit komplettem Ergebnis
6. App zeigt UI-Liste, User reviewt und editiert optional
7. POST an `/functions/v1/food-scan-confirm` mit `{ scan_id, user_corrected, user_corrections? }`
8. Edge Function `food-scan-confirm`:
    - Validiert JWT
    - Prüft Ownership (scan.user_id === jwt.user_id)
    - Bei `user_corrected: true`: Recalculate Totals
    - UPDATE `food_scan_log` mit `status='confirmed'`, `confirmed_at=now()`
9. App zeigt Final-Bestätigung, refresht Daily Macros

### Gemessene Latenzen (13.04.2026)

- **Storage Upload** (~80 KB): 200-400ms
- **Vision-Call + Streaming:** 1.5-2.5s
- **Embedding Batch:** 0.5-0.8s
- **Vector Match:** 0.6-1.0s
- **Cold Total:** 3.5-5.5s
- **Cache-Hit Total:** 600-900ms
- **Confirm Call:** 100-300ms

---

## 3. Storage Layer

### Bucket Konfiguration

- Name: `food-scans`
- Public: false
- File Size Limit: 5 MB (5.242.880 bytes)
- Allowed MIME Types: `image/jpeg`, `image/png`

### Path-Convention

Pfad-Schema: `food-scans/{user_id}/{timestamp}_{uuid_8chars}.jpg`

Beispiel: `food-scans/f440d7e4-1dd1-429e-9b23-e131ab3e3807/1776084050861_6c15f841.jpg`

Der User-ID-Ordner ist der Sicherheitsanker — RLS erkennt User-Zugehörigkeit über den ersten Path-Segment.

### RLS Policies

```sql
CREATE POLICY food_scans_user_insert ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'food-scans'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY food_scans_user_select ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'food-scans'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY food_scans_user_delete ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'food-scans'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

### Frontend Upload-Snippet

```tsx
import { manipulateAsync, SaveFormat } from 'expo-image-manipulator';
import { supabase } from './supabaseClient';

async function uploadFoodImage(uri: string, userId: string): Promise<string> {
  const manipulated = await manipulateAsync(
    uri,
    [{ resize: { width: 800 } }],
    { compress: 0.85, format: SaveFormat.JPEG }
  );

  const response = await fetch(manipulated.uri);
  const blob = await response.blob();

  const path = `${userId}/${Date.now()}_${crypto.randomUUID().slice(0, 8)}.jpg`;
  const { error } = await supabase.storage
    .from('food-scans')
    .upload(path, blob, { contentType: 'image/jpeg', upsert: false });

  if (error) throw error;
  return path;
}
```

### Warum Storage-First statt Bild-im-Body

- Bild ist persistent, später im Account-Verlauf oder in Cora-Memory-Pipeline nutzbar
- Edge Function bleibt klein (nur `storage_path` als String, kein Multipart-Body-Parsing)
- RLS greift schon auf Storage-Ebene, nicht erst in der Function
- Re-Tries möglich — wenn Edge Function failed, Bild ist noch da
- Saubere Trennung von Storage und Compute

---

## 4. Auth Pattern (KRITISCH)

### Problem: ES256 vs Edge Function Gateway

Dieses Supabase-Projekt nutzt das moderne asymmetrische JWT-Setup (ES256 mit JWKS). User-JWTs sind ES256-signiert. Storage akzeptiert sie (HTTP 200). Das Edge-Function-Gateway lehnt sie aber mit `verify_jwt=true` als "Invalid JWT" ab (HTTP 401) — das Gateway kann das asymmetrische Format aktuell nicht validieren.

Beweis via JWKS-Endpoint:

```bash
curl https://vviutyisqtimicpfqbmi.supabase.co/auth/v1/.well-known/jwks.json
# Returns: {"keys":[{"alg":"ES256","crv":"P-256","kid":"92ea5fa9-...","kty":"EC",...}]}
```

### Lösung: verify_jwt=false plus Body-Auth

Beide Edge Functions sind mit `verify_jwt=false` deployed und validieren JWT im Function-Body über `auth.getUser()` als erste Aktion:

```tsx
const authHeader = req.headers.get('Authorization');
if (!authHeader?.startsWith('Bearer ')) {
  return errorResponse('unauthorized', 'Missing Bearer token', 401);
}
const userJwt = authHeader.slice('Bearer '.length);

const userClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  global: { headers: { Authorization: `Bearer ${userJwt}` } },
  auth: { persistSession: false }
});

const { data: userResult, error: userErr } = await userClient.auth.getUser(userJwt);
if (userErr || !userResult?.user) {
  return errorResponse('unauthorized', 'Invalid JWT', 401);
}
const userId = userResult.user.id;
```

### Ist das sicher

Ja, identische Sicherheit zu `verify_jwt=true`, nur an anderer Stelle validiert:

- `auth.getUser()` ruft den Auth-Server, der den JWT kryptografisch gegen den private Key prüft
- Bei ungültigem JWT wirft die Function 401 — genau wie das Gateway es täte
- Storage-Path-Check stellt sicher dass User nur eigene Bilder anfasst
- RLS auf `food_scan_log` verhindert Cross-User-Daten

### Code-Review-Checkliste für neue Edge Functions

Vor jedem Deployment prüfen:

- Ist `auth.getUser()` die erste nicht-triviale Aktion in der Function
- Gibt es einen Unit-Test der erwartet dass die Function ohne JWT 401 wirft
- Werden alle DB-Writes durch den User-Client gemacht (nicht Service-Role wo vermeidbar)
- Wenn Service-Role genutzt wird: gibt es einen expliziten Ownership-Check (z.B. `scan.user_id === userId`)

### Frontend-Keys

- **Anon-Key (Publishable):** `sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW`
    - Im Header `apikey:` mitschicken
    - NICHT der Legacy-Anon-Key (HS256) — der passt nicht zum modernen Setup
- **JWT (User-Token):** nach erfolgreichem Login via `/auth/v1/token`, ES256-signiert, im Header `Authorization: Bearer <jwt>`

---

## 5. Edge Function `food-scanner`

- **Slug:** `food-scanner`
- **Version:** v13 (Stand 13.04.2026)
- **verify_jwt:** false (Auth im Body via `auth.getUser()`)
- **Endpoint:** `POST https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scanner`

### Aufgabe

Nimmt entweder einen Storage-Path (Bild-Scan) oder einen Barcode entgegen. Liefert bei Bild-Scan einen Server-Sent-Events Stream mit progressiven Events. Liefert bei Barcode-Scan ein einzelnes JSON-Objekt.

### Request-Shape für Bild-Scan

```
POST /functions/v1/food-scanner
apikey: sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW
Authorization: Bearer <USER_JWT>
Content-Type: application/json
Accept: text/event-stream

{ "storage_path": "f440d7e4-.../1776084050861_6c15f841.jpg" }
```

### Request-Shape für Barcode-Scan

```
POST /functions/v1/food-scanner
apikey: sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW
Authorization: Bearer <USER_JWT>
Content-Type: application/json

{ "barcode": "4003239123456" }
```

### Request-Shape für Keepalive

Für Cold-Start-Mitigation kann die App periodisch einen Keepalive schicken:

```json
POST /functions/v1/food-scanner
{ "keepalive": true }

Response: { "ok": true, "warm": true }
```

### SSE-Event-Sequenz

- `start` → `{ scan_id, ts, model, version, cached? }` — sofort nach JWT-Validierung und Cache-Check
- `dish` → `{ dish_name, ts }` — sobald Vision den Gerichtsnamen extrahiert
- `ingredient` → `{ index, ingredient: { name, grams, preparation, visibility }, ts }` — für jede erkannte Zutat einzeln
- `vision_done` → `{ ingredient_count, ts }` — Vision-Stream komplett geparst
- `embed_done` → `{ ts }` — alle Ingredients embedded
- `match_done` → `{ ts }` — alle Vector-Matches abgerufen
- `final` → `{ scan_id, dish_name, ingredients[], totals, tier_used, model, version, latency_ms, cached }` — komplettes Ergebnis, persistiert in DB
- `error` → `{ scan_id, message, ts }` — bei Fehler in der Pipeline

Bei Cache-HIT werden nur `start` und `final` Events gesendet mit `cached: true` im Payload.

### Vision-Prompt

Der Prompt (gekürzt) instruiert Gemini:

- Analyze the PRIMARY PLATE only
- Return STRICT JSON mit `dish_name` und `ingredients[]`
- Naming: base food as in nutrition database, concrete not category, decompose if nutritionally relevant, skip garnishes under 5g
- Inferred Ingredients: add invisible items (cooking oil, butter, dressing, eggs in batter) with realistic grams
- Output: 3-13 ingredients max, no prose outside JSON

### Gemini-Konfiguration (NICHT ändern ohne Test)

```tsx
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

**Warum `thinkingBudget: 0`:** Gemini 2.5 Flash Lite hat einen Thinking-Mode, der Output-Tokens silent verbraucht. Ohne `thinkingBudget: 0` werden 50-80% der Tokens für Thinking benutzt, das eigentliche JSON wird abgeschnitten, und du bekommst Parser-Errors.

### Embedding-Strategie

Visible Ingredients kriegen Preparation + Name als Embed-Text. Inferred Ingredients kriegen nur Name. Alle werden in einem einzigen Batch-Call an OpenAI geschickt:

```tsx
const embedTexts = visionIngredients.map(ing =>
  ing.visibility === 'inferred'
    ? ing.name.toLowerCase()
    : `${ing.preparation || ''} ${ing.name}`.trim().toLowerCase()
);

const response = await fetch('https://api.openai.com/v1/embeddings', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${OPENAI_API_KEY}` },
  body: JSON.stringify({
    model: 'text-embedding-3-small',
    input: embedTexts
  })
});
```

### Match-Logik

Parallele `match_nutrition` RPC-Calls, einer pro Ingredient:

```tsx
const matchResults = await Promise.all(
  embeddings.map(emb =>
    serviceClient.rpc('match_nutrition', {
      query_embedding: emb,
      match_count: 5
    }).then(r => r.data ?? [])
  )
);
```

TOP-5 wird intern geholt, TOP-3 gehen ans Frontend für Debug-Anzeige. Der beste Match wird genutzt für `per_ingredient_nutrients`.

### Critical Bugfix: base64 chunked encoding (v13)

**Bug bis v12:** `btoa(String.fromCharCode(...new Uint8Array(bytes)))` crasht mit "Maximum call stack size exceeded" bei Bildern ab 100 KB. Grund: der Spread-Operator erzeugt zu viele Funktions-Argumente für `String.fromCharCode`.

**Fix in v13:**

```tsx
function arrayBufferToBase64(bytes: ArrayBuffer): string {
  const uint8 = new Uint8Array(bytes);
  const chunkSize = 8192;
  let binary = '';
  for (let i = 0; i < uint8.length; i += chunkSize) {
    binary += String.fromCharCode.apply(
      null,
      Array.from(uint8.subarray(i, i + chunkSize))
    );
  }
  return btoa(binary);
}
```

### Barcode-Tier Flow

Bei `{ barcode: "..." }` Request:

1. Cache-Lookup mit `scan_hash = 'bc_' + barcode`
2. Bei MISS: Open Food Facts API Call an `https://world.openfoodfacts.org/api/v2/product/{barcode}.json`
3. OFF-Nutriments mappen auf 20-Spalten-Schema:
    - Makros: enerc_kcal, procnt_g, fat_g, choavl_g, fibtg_g (alle in g)
    - Mineralien: na_mg, k_mg, ca_mg, fe_mg, mg_mg, zn_mg (OFF liefert in g, mal 1000 für mg)
    - Vitamine: vita_rae_ug, vitd_ug, vite_mg, vitc_mg, thia_mg, ribf_mg, nia_mg, vitb6_mg, foldfe_ug
4. Scale auf `serving_quantity` (default 100g wenn nicht definiert)
5. UPDATE `food_scan_log` mit `status='pending_confirmation'`, `tier_used='tier0_barcode'`
6. Return als JSON (kein Stream)

---

## 6. PG Vector Matching (nutrition_db)

### Datenbestand

`nutrition_db` Tabelle hat **25.558 Einträge** aus 7 Quellen:

- **USDA_SR:** 7.793 Einträge (US Department of Agriculture Standard Reference)
- **BLS:** 7.140 Einträge (Bundeslebensmittelschlüssel, deutsche Nährwerttabelle)
- **CIQUAL:** 3.341 Einträge (französische Nährwertdatenbank ANSES)
- **COFID:** 2.886 Einträge (UK Composition of Foods)
- **NEVO:** 2.328 Einträge (niederländische Nährwertdatenbank)
- **OFF:** 2.000 Einträge (Open Food Facts, markenbasierte Produkte — haben noch keine `name_en`)
- **USDA_FND:** 135 Einträge (USDA Foundation Foods, neue Mess-Methodologie)

Alle Einträge haben: `name_original` (Originalsprache), `name_en` (sofern verfügbar), 20 Nutrient-Spalten, `embedding` (1536-dim vector auf `name_en` via OpenAI), `food_group` und `food_group_normalized`.

### 20-Spalten Nutrient Schema (einheitlich über alle Quellen)

Werte sind alle pro 100g:

- **Energie:** `enerc_kcal` (kcal)
- **Makros:** `procnt_g`, `fat_g`, `choavl_g` (available carbs), `fibtg_g` (fiber)
- **Mineralien:** `na_mg`, `k_mg`, `ca_mg`, `fe_mg`, `mg_mg`, `zn_mg`
- **Vitamine:** `vita_rae_ug` (A), `vitd_ug` (D), `vite_mg` (E), `vitc_mg` (C), `thia_mg` (B1), `ribf_mg` (B2), `nia_mg` (B3), `vitb6_mg`, `foldfe_ug` (Folat DFE)

### Indexes

```sql
-- HNSW Vector Index mit Cosine Similarity
CREATE INDEX nutrition_db_embedding_idx
  ON public.nutrition_db USING hnsw (embedding vector_cosine_ops);

-- Btree für direct lookups
CREATE UNIQUE INDEX nutrition_db_source_uid
  ON public.nutrition_db USING btree (source, source_id);

CREATE INDEX nutrition_db_food_group_idx
  ON public.nutrition_db USING btree (food_group);

CREATE INDEX idx_nutrition_food_group_normalized
  ON public.nutrition_db USING btree (food_group_normalized);
```

### match_nutrition RPC

```sql
CREATE OR REPLACE FUNCTION public.match_nutrition(
  query_embedding vector,
  match_count integer DEFAULT 50
)
RETURNS TABLE(
  id bigint,
  source text,
  source_id text,
  name_en text,
  name_original text,
  food_group text,
  origin_country text,
  similarity double precision,
  full_row jsonb
)
LANGUAGE sql STABLE
SET search_path TO 'public'
AS $$
  SELECT
    n.id, n.source, n.source_id, n.name_en, n.name_original,
    n.food_group, n.origin_country,
    1 - (n.embedding <=> query_embedding) AS similarity,
    to_jsonb(n) AS full_row
  FROM public.nutrition_db n
  WHERE n.embedding IS NOT NULL
  ORDER BY n.embedding <=> query_embedding
  LIMIT match_count;
$$;
```

Der Cosine Distance Operator `<=>` liefert 0 (identisch) bis 2 (entgegengesetzt). `1 - distance` ergibt similarity 0-1 (höher = besser).

### Match-Beispiel

Vision erkennt `"avocado" (sliced, 40g)`. Embed-Text wird `"sliced avocado"` (visible → prep + name). OpenAI Embedding (1536-dim). `match_nutrition(embedding, 5)` returnt:

1. USDA_SR / 173573 / "Avocado, raw" / similarity 0.92
2. BLS / F503100 / "Avocado roh" / similarity 0.89
3. CIQUAL / 17005 / "Avocat, frais" / similarity 0.87
4. NEVO / 415 / "Avocado, vers" / similarity 0.85
5. USDA_SR / 173568 / "Avocado oil" / similarity 0.74  ← Fallstrick

Best-Match (rank 1) wird genommen, Werte auf 40g skaliert.

### Bekannte Limitations

- **Avocado vs Avocado-Oil Problem:** Embeddings sind semantisch nah, nährwerttechnisch grundverschieden (160 kcal vs 884 kcal pro 100g). Fix → Multi-Layer Matching mit `food_group_normalized` Filter (Roadmap, siehe DOC-60)
- **OFF-Einträge ohne `name_en`:** Embeddings liegen auf `name_original` (französisch/deutsch). Funktioniert akzeptabel durch OpenAI multilingual, aber nicht optimal
- **`food_group_normalized` ist nullable:** Backfill für 25.558 Einträge in Roadmap

---

## 7. Edge Function `food-scan-confirm`

- **Slug:** `food-scan-confirm`
- **Version:** v5
- **verify_jwt:** false (Auth im Body via `auth.getUser()`)
- **Endpoint:** `POST https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scan-confirm`

### Aufgabe

Nimmt `scan_id` entgegen und bestätigt einen Scan im Status `pending_confirmation`. Bei `user_corrected: true` werden User-Korrekturen übernommen und Totals neu berechnet.

### Request-Shape ohne Korrekturen

```json
{
  "scan_id": "uuid",
  "user_corrected": false
}
```

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

**Wichtig für Frontend:** `user_corrections` muss die KOMPLETTE Liste sein, nicht nur die geänderten Items. Frontend ist verantwortlich für `per_ingredient_nutrients` Recalc bei Grams-Änderung (siehe Sektion 11).

### Response-Shape

```json
{
  "scan_id": "uuid",
  "dish_name": "Open-faced sandwich with poached eggs",
  "totals": {
    "kcal": 715,
    "protein_g": 33.1,
    "carbs_g": 38.2,
    "fat_g": 49.5
  },
  "user_corrected": true,
  "confirmed_at": "2026-04-13T13:01:22.212Z"
}
```

### Server-side Recalculation

```tsx
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

### Sicherheits-Checks in Reihenfolge

1. JWT gültig (`auth.getUser()` erfolgreich)
2. Scan existiert in DB
3. Scan gehört zum aufrufenden User (`scan.user_id === userId`) → sonst 403
4. Scan ist nicht im Status `failed` → sonst 409

---

## 8. Cache-Strategie

### Designentscheidung

Keine separate Cache-Tabelle. `food_scan_log` ist beides: User-Historie UND Cache-Layer. Eine Tabelle, zwei Funktionen.

### Begründung

- Cache-Lifecycle = User-Log-Lifecycle. Wenn User Account löscht, ist Cache automatisch weg via CASCADE
- Eine RLS-Policy weniger Komplexität für Frontend-Entwickler
- Cache-Hits sind immer User-eigene Scans (kein Cross-User-Sharing, Privacy-Plus)
- Vision-Calls sind teuer (5+ Sekunden, Gemini-Kosten) — jeder Cache-Hit spart

### Cache-Lookup Logik

```tsx
const { data: cached } = await serviceClient
  .from('food_scan_log')
  .select('id, dish_name, ingredients, total_kcal, total_protein_g, total_carbs_g, total_fat_g, tier_used')
  .eq('user_id', userId)
  .eq('scan_hash', scanHash)
  .in('status', ['pending_confirmation', 'confirmed'])
  .order('created_at', { ascending: false })
  .limit(1)
  .maybeSingle();
```

Bedingungen für Cache-HIT:

- Gleicher User
- Gleicher SHA256-Hash vom Bild
- Status NICHT `failed` und NICHT `processing`

### Bei Cache-HIT

Ein neuer `food_scan_log`-Eintrag wird INSERTet mit kopierten Daten vom Cache-Original. Der neue Eintrag hat den frischen Storage-Path (Bild ist ja frisch hochgeladen), aber den gleichen Hash, gleiche Ingredients, gleiche Totals. Status startet direkt bei `pending_confirmation` — User muss trotzdem bestätigen.

SSE-Stream sendet nur `start` (cached=true) und `final` (cached=true) — keine Zwischen-Events.

### Hash-Berechnung

```tsx
async function sha256Hex(bytes: ArrayBuffer): Promise<string> {
  const hash = await crypto.subtle.digest('SHA-256', bytes);
  return Array.from(new Uint8Array(hash))
    .map(x => x.toString(16).padStart(2, '0'))
    .join('');
}
```

Für Barcodes: `scan_hash = 'bc_' + barcode` (kein SHA nötig, Barcode ist schon eindeutig).

### Gemessene Performance

- Run 1 (cold): 5.158ms
- Run 2 (cache): 903ms
- Run 3 (cache): 608ms
- Speedup: 6-8-fach

### Edge Cases

- **Failed Scans** werden im Cache NICHT berücksichtigt. Nochmal scannen → voller Pipeline-Run. Gewollt, weil Fail oft transient.
- **Inkonsistenz durch neue Vision-Interpretation:** kann nicht passieren, Cache-Lookup ist deterministisch über SHA256. Byte-identisches Bild → gleicher Hash → gleicher Cache-Eintrag.

---

## 9. Schema: food_scan_log

Zentrale Tabelle für alle Scan-Operationen.

### DDL

```sql
CREATE TABLE public.food_scan_log (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid REFERENCES auth.users(id),

  -- Input
  image_url           text,                    -- Legacy, nicht mehr genutzt
  image_storage_path  text,                    -- z.B. 'user_id/ts_uuid.jpg'
  barcode             text,                    -- für Barcode-Scans
  scan_hash           text,                    -- SHA256 vom Bild ODER 'bc_<barcode>'

  -- Output
  dish_name           text,
  ingredients         jsonb,                   -- Array von EnrichedIngredient[]
  total_kcal          numeric,
  total_protein_g     numeric,
  total_carbs_g       numeric,
  total_fat_g         numeric,

  -- User Correction
  user_corrected      boolean DEFAULT false,
  user_corrections    jsonb,

  -- Lifecycle
  status              text DEFAULT 'processing'
                      CHECK (status IN ('processing', 'pending_confirmation', 'confirmed', 'failed')),
  tier_used           text
                      CHECK (tier_used IS NULL OR tier_used IN ('tier0_barcode', 'tier1_vision', 'tier1_vision_hybrid')),

  -- Telemetry
  model_version       text,
  scan_latency_ms     integer,
  error_message       text,
  failed_at           timestamptz,

  -- Audit
  created_at          timestamptz DEFAULT now(),
  confirmed_at        timestamptz
);
```

### Status-State-Machine

- `processing` — initial INSERT, während Vision-Call läuft
    - bei Fehler → `failed` (Endstatus, mit `error_message` und `failed_at`)
    - bei Erfolg → `pending_confirmation`
- `pending_confirmation` — Vision fertig, wartet auf User
    - bei User-Confirm → `confirmed` (Endstatus, mit `confirmed_at`)
- `confirmed` — Endstatus, zählt in Daily Macros

### Indexes

```sql
-- Cache-Lookup (hauptsächlicher Hot Path)
CREATE INDEX food_scan_log_scan_hash_idx
  ON public.food_scan_log USING btree (scan_hash)
  WHERE (scan_hash IS NOT NULL);

-- User-Historie
CREATE INDEX food_scan_log_user_status_created_idx
  ON public.food_scan_log USING btree (user_id, status, created_at DESC);

CREATE INDEX idx_scan_log_user_created
  ON public.food_scan_log USING btree (user_id, created_at DESC);

-- Barcode-Lookup
CREATE INDEX food_scan_log_barcode_idx
  ON public.food_scan_log USING btree (barcode)
  WHERE (barcode IS NOT NULL);

-- Confirmed-Scans Reports
CREATE INDEX idx_scan_log_confirmed
  ON public.food_scan_log USING btree (confirmed_at)
  WHERE (confirmed_at IS NOT NULL);
```

### RLS Policies

```sql
CREATE POLICY food_scan_log_user_select ON public.food_scan_log
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY food_scan_log_user_insert ON public.food_scan_log
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY food_scan_log_user_update ON public.food_scan_log
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY users_own_scans ON public.food_scan_log
  FOR ALL
  USING (auth.uid() = user_id);
```

### EnrichedIngredient JSON-Shape

Im `ingredients` jsonb-Feld liegen Objekte dieser Form:

```tsx
interface EnrichedIngredient {
  // Vision Output
  name: string;                     // "avocado"
  grams: number;                    // 40
  preparation?: string;             // "sliced"
  visibility: 'visible' | 'inferred';

  // Match Result
  matches: NutritionMatch[];        // Top-3 Kandidaten
  matched_source: string | null;    // "USDA_SR/173573"

  // Computed (skaliert auf grams)
  per_ingredient_nutrients: {
    enerc_kcal: number;
    procnt_g: number;
    fat_g: number;
    choavl_g: number;
    fibtg_g: number;
    na_mg: number; k_mg: number; ca_mg: number;
    fe_mg: number; mg_mg: number; zn_mg: number;
    vita_rae_ug: number; vitd_ug: number;
    vite_mg: number; vitc_mg: number;
    thia_mg: number; ribf_mg: number; nia_mg: number;
    vitb6_mg: number; foldfe_ug: number;
  };
}

interface NutritionMatch {
  id: number;                       // nutrition_db.id
  source: string;                   // 'USDA_SR' | 'BLS' | ...
  source_id: string;
  name_en: string;
  similarity: number;               // 0-1, höher = besser
  per_100g: Record<string, number>; // 20 Nutrients (für Recalc)
}
```

---

## 10. Test-Pipeline Skript

`test-pipeline.mjs` simuliert die App vollständig: Login → Upload → Scan (mit SSE-Streaming und UI-Anzeige) → interaktive User-Korrektur → Confirmation → DB-Verifikation. Es ist die Referenz für den Frontend-Flow.

### Setup

Ordnerstruktur unter `~/Desktop/coralate-test/`:

- `pictures/` — Test-Bilder (.jpg oder .png)
- `test-pipeline.mjs` — das Skript
- `package.json` — für sharp Dependency
- `node_modules/`

Install:

```bash
cd ~/Desktop/coralate-test
npm init -y
npm install sharp
```

### CLI-Modi

- `node test-pipeline.mjs` — Standard: erstes Bild aus `pictures/`, Scan, Auto-Confirm
- `node test-pipeline.mjs --cache` — 2x selbes Bild scannen, 2. ist Cache-Hit
- `node test-pipeline.mjs --correct` — Scan plus interaktive Korrektur im Terminal
- `node test-pipeline.mjs --barcode 4003239123456` — Open Food Facts Lookup
- `node test-pipeline.mjs --db` — am Ende DB-State anzeigen
- `node test-pipeline.mjs --image ./pictures/x.jpg` — spezifisches Bild
- `node test-pipeline.mjs --skip-resize` — Original hochladen (ohne Resize)
- `node test-pipeline.mjs --no-confirm` — nur scannen, nicht bestätigen

Flags kombinierbar: `node test-pipeline.mjs --correct --db`

### Pipeline-Phasen im Skript

1. **Login:** POST an `/auth/v1/token?grant_type=password` → JWT
2. **Bild vorbereiten:** sharp resize auf 800px, JPEG q=0.85
3. **Storage Upload:** PUT an `/storage/v1/object/food-scans/{path}`
4. **Scan starten:** POST an `/functions/v1/food-scanner`, SSE-Stream parsen
5. **(Optional) Korrektur:** interaktiver Terminal-Editor
6. **Confirm:** POST an `/functions/v1/food-scan-confirm`
7. **(Optional) DB-Check:** GET `/rest/v1/food_scan_log?or=(id.eq.X,...)` mit Anzeige aller Spalten

### UI-Simulation im Terminal

Das Skript imitiert das App-UI mit ANSI-Farben:

- Blauer Header "coralate App — Scan läuft"
- Skeleton-Card während Bild analysiert wird
- Dish-Header sobald Vision den Namen liefert
- Ingredient-Cards poppen einzeln rein wie SSE-Events ankommen
- Unterscheidung visible (Auge) vs inferred (Auge-mit-Sprechblase)
- Phase-Indikatoren (Vision fertig, Embeddings, DB-Matches)
- Grüner Totals-Footer mit kcal/P/C/F
- Cyan Cache-Badge bei Cache-Hit

### Korrektur-Flow Kommandos

Im `--correct` Modus erscheint nach dem Scan folgendes Menü:

- `[Nummer]` — Grams für diese Zutat ändern (z.B. 1 → dann 80 → enter)
- `d[N]` — Zutat löschen (z.B. `d3` löscht Zutat 3)
- `s` — Speichern und Confirm schicken
- `a` — Abbrechen (akzeptiert Original ohne Edit)

Flow: User tippt Nummer → Skript fragt "Neue Grams für X (aktuell Yg):" → User tippt neue Zahl → `per_ingredient_nutrients` werden clientseitig recalced → Liste wird neu angezeigt mit aktualisierten kcal.

### Kritische Codestellen

SSE-Stream Parsing (exakt das Pattern das Jann in React Native nutzen muss):

```tsx
const reader = response.body.getReader();
const decoder = new TextDecoder();
let buf = '', currentEvent = null;

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  buf += decoder.decode(value, { stream: true });
  const lines = buf.split('\n');
  buf = lines.pop() ?? '';
  for (const line of lines) {
    if (line.startsWith('event: ')) {
      currentEvent = line.slice(7).trim();
    } else if (line.startsWith('data: ') && currentEvent) {
      const data = JSON.parse(line.slice(6));
      handleEvent(currentEvent, data);
      currentEvent = null;
    }
  }
}
```

Clientseitiger Recalc bei Grams-Änderung:

```tsx
if (ing.matches?.[0]?.per_100g) {
  const factor = newGrams / 100;
  const recalc = {};
  for (const [k, v] of Object.entries(ing.matches[0].per_100g)) {
    recalc[k] = Number((Number(v) * factor).toFixed(3));
  }
  ing.per_ingredient_nutrients = recalc;
}
ing.grams = newGrams;
```

### Test-Account

- Email: `deniz.oezbek@coralate.de`
- Passwort: `Geko132#`
- User-UUID: `f440d7e4-1dd1-429e-9b23-e131ab3e3807`

---

## 11. UI-Konzept für Jann

### Screens und Flow

Food Tab → Plus Button → Action Sheet mit 4 Optionen:

- Foto aufnehmen → Camera → ScanResultScreen (Live-Streaming)
- Aus Galerie → ImagePicker → ScanResultScreen (Live-Streaming)
- Barcode scannen → BarcodeScanner → ScanResultScreen (instant)
- Manuell → ManualEntryScreen (out of scope hier)

### ScanResultScreen State Machine

1. `UPLOADING` — Spinner plus "Wird hochgeladen..."
2. `SCANNING` — Skeleton-Cards plus "Bild wird analysiert..."
3. `DISH_DETECTED` — Header zeigt dish_name (animiert)
4. `INGREDIENTS_LIVE` — Cards poppen einzeln rein wie SSE-Events ankommen
5. `MATCHED` — Cards bekommen kcal-Werte (nach `match_done` Event)
6. `REVIEW` — Buttons unten: [Bestätigen] und [Bearbeiten]
7. `EDITING` — Inline-Editor pro Card (Grams ändern, löschen, hinzufügen)
8. `CONFIRMED` — Success-Animation, zurück zu Food Tab mit aktualisierten Daily Macros

### Komponenten

**ScanResultScreen:**

- Top: Bild-Vorschau (klein, Tap-to-Expand)
- Mitte: Dish-Name (groß, editierbar im Edit-Mode)
- Liste: IngredientCard × N
- Footer: MacrosFooter (sticky)
- Buttons unten: [Bestätigen] [Bearbeiten] / im Edit [Speichern] [Abbrechen]

**IngredientCard:**

- Icon für visible vs inferred
- Name (groß, editierbar im Edit-Mode)
- Preparation (klein darunter)
- Grams (rechts, editierbar)
- kcal (klein, recalced live)
- Match-Source (ganz klein, Debug)
- Löschen-Button (nur im Edit-Mode)

**MacrosFooter:**

- Sticky am unteren Bildschirmrand
- Live-Update bei Grams-Änderung

### Streaming-Integration

```tsx
import { fetch } from 'expo/fetch'; // unterstützt ReadableStream

async function startScan(
  storagePath: string,
  jwt: string,
  onEvent: (e: { type: string; data: any }) => void
) {
  const response = await fetch(
    'https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scanner',
    {
      method: 'POST',
      headers: {
        'apikey': 'sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW',
        'Authorization': `Bearer ${jwt}`,
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream'
      },
      body: JSON.stringify({ storage_path: storagePath })
    }
  );

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buf = '', currentEvent = null;

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buf += decoder.decode(value, { stream: true });
    const lines = buf.split('\n');
    buf = lines.pop() ?? '';
    for (const line of lines) {
      if (line.startsWith('event: ')) {
        currentEvent = line.slice(7).trim();
      } else if (line.startsWith('data: ') && currentEvent) {
        try {
          const data = JSON.parse(line.slice(6));
          onEvent({ type: currentEvent, data });
        } catch {}
        currentEvent = null;
      }
    }
  }
}
```

### Confirm-Call

```tsx
async function confirmScan(
  scanId: string,
  jwt: string,
  corrections: EnrichedIngredient[] | null
) {
  const userCorrected = corrections !== null;
  const response = await fetch(
    'https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scan-confirm',
    {
      method: 'POST',
      headers: {
        'apikey': 'sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW',
        'Authorization': `Bearer ${jwt}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        scan_id: scanId,
        user_corrected: userCorrected,
        user_corrections: corrections
      })
    }
  );
  return response.json();
}
```

### Recalc bei Grams-Änderung

Frontend MUSS `per_ingredient_nutrients` neu berechnen bevor Confirm-Call rausgeht:

```tsx
function recalcNutrients(
  ing: EnrichedIngredient,
  newGrams: number
): EnrichedIngredient {
  if (!ing.matches?.[0]?.per_100g) return ing;
  const factor = newGrams / 100;
  const newNutrients: Record<string, number> = {};
  for (const [k, v] of Object.entries(ing.matches[0].per_100g)) {
    newNutrients[k] = Number((Number(v) * factor).toFixed(3));
  }
  return {
    ...ing,
    grams: newGrams,
    per_ingredient_nutrients: newNutrients
  };
}
```

### Error Handling

- **HTTP 401:** JWT expired → Refresh Token holen, retry
- **HTTP 403:** Storage Path enthält andere User-ID → Bug, an Backend melden
- **HTTP 404:** Scan nicht gefunden beim Confirm → Cache stale, neu scannen
- **HTTP 409:** Scan ist bereits failed → User-Hinweis "Scan fehlgeschlagen, bitte neu scannen"
- **SSE event=error:** Vision Pipeline failed → Error UI mit Retry-Button
- **Network Loss mid-stream:** Stream-Reader wirft Error → Polling-Fallback auf `/rest/v1/food_scan_log?id=eq.X&select=*` bis Status nicht mehr `processing`

---

## 12. Open Issues & Roadmap

### Must-have vor App-Launch

- Multi-Layer Matching für Avocado-vs-Avocado-Oil-Problem (food_group_normalized Filter im match_nutrition RPC). Siehe DOC-60.
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
- Foto-Persistierung und Deletion-Policy (DSGVO Art. 17 — Bilder löschen nach X Tagen oder bei Account-Löschung)
- Multi-Plate-Recognition (mehrere Teller auf einem Bild)
- User-Confidence-Loop: wenn User oft korrigiert, lernt das System seine Präferenzen

### Bekannte Bugs

- Inferred Ingredients sind oft konservativ. Vision schätzt z.B. 10g Öl beim Anbraten, real sind's oft 20-30g. Fix → kalibrierter Vision-Prompt v2
- OFF-Daten haben keine name_en. 2.000 Einträge können nicht sauber semantisch gefunden werden. Fix → Translation-Pipeline für OFF
- Edge Function Cold Start: erster Scan nach 10min Inaktivität braucht 1-2s extra. Mitigation → keepalive-Endpoint von App periodisch aufrufen

---

## 13. Migrations & Deployment Reference

### Aktuelle Versionen (13.04.2026)

- `food-scanner` Edge Function: **v13** (verify_jwt=false, base64 chunked encoding)
- `food-scan-confirm` Edge Function: **v5** (verify_jwt=false)
- `food_scan_log` Tabelle: aktuelles Schema (siehe Sektion 9)
- `nutrition_db` Tabelle: 25.558 Einträge mit HNSW Embedding Index
- Storage Bucket `food-scans`: privat, 5 MB Limit, JPEG/PNG

### Wichtige Supabase Migrations

- `food_scans_storage_secure` — Bucket auf privat, alte anon-Policies entfernt
- `food_scan_log_pipeline_fields` — status, scan_hash, barcode, tier_used, error_message, failed_at hinzugefügt
- `drop_unused_food_scan_cache` (13.04.2026) — alte Cache-Tabelle entfernt, food_scan_log ist Source-of-Truth

### Deployment

Edge Functions werden via Supabase MCP `deploy_edge_function` deployed, mit Parameter `verify_jwt: false` (siehe Auth-Pattern in Sektion 4).

### Wichtige Konstanten

- **SUPABASE_URL:** `https://vviutyisqtimicpfqbmi.supabase.co`
- **Region:** eu-west-1 (Projekt "Coralate Data Base")
- **Plan:** Pro
- **Anon Publishable Key:** `sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW`
- **Test User:** `deniz.oezbek@coralate.de` (UID `f440d7e4-1dd1-429e-9b23-e131ab3e3807`)

---

## 14. Verwandte Docs

Diese bleiben `Lifecycle: Active` weil sie Research/Referenz sind:

- **DOC-57** Food Scanner Deep Research — Vision-Modelle, pgvector, Edge-Pipeline (April 2026). Research Findings die zur aktuellen Architektur geführt haben.
- **DOC-60** Food Scanner Retrieval — Taxonomy Research Findings (20 Categories). Grundlage für food_group_normalized Roadmap.

Deprecated (Lifecycle: Deprecated), ersetzt durch dieses Master-Doc:

- DOC-51 Food Scanner Handover — STEP 1+2 Done
- DOC-52 Food Scanner Status — STEP 3 Done
- DOC-53 Food Scanner v2 Architecture — Post-Jann Adjustments
- DOC-54 Edge Function Build — Handover-Prompt
- DOC-55 Food Scanner Pipeline Status — Stand v7
- DOC-56 Food Scanner Pipeline Status v7 — Live, Latenz-Roadmap
- DOC-58 Food Scanner — Frontend Integration Spec für Jann (v1)
- DOC-59 Food Scanner Backend — Supabase Doku (Stand 12.04.2026)
- DOC-61 Food Scanner — Prompt Version Log

---

*Letzte Aktualisierung: 13.04.2026. Pipeline End-to-End validiert. Production-Ready für Frontend-Integration durch Jann.*