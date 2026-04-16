# Food Scanner Deep Research — Vision-Modelle, pgvector, Edge-Pipeline (April 2026)

Created: 12. April 2026 18:03
Doc ID: DOC-57
Doc Type: Research
Gelöscht: No
Last Edited: 12. April 2026 18:03
Last Reviewed: 12. April 2026
Lifecycle: Active
Notes: Konsolidierte Research aus Perplexity + Gemini Deep Research, April 2026. Drei Dokumente: Vision-Modelle, pgvector-Optimierung, Edge-Pipeline-Architektur. Actionable Findings für v8 Planning.
Pattern Tags: Enrichment
Stability: Stable
Stack: Supabase
Verified: Yes

# Scope

Konsolidierung zweier paralleler Deep-Research-Läufe (Perplexity und Gemini) zu den drei Optimierungs-Prompts, die nach v7 formuliert wurden. Drei Kern-Themen: Vision-Modell-Alternativen, pgvector-Latenz auf Supabase, Architektur-Alternativen für Multi-Vector-Pipelines. Befunde tagesaktuell per April 2026.

# 1. Vision-Modell-Landschaft April 2026

## Quick-Ranking (1000 Input / 200 Output Token, 800px JPEG)

| Modell | TTFT P50 | TTFT P95 | Output TPS | $ / 1k Calls | Bemerkung |
| --- | --- | --- | --- | --- | --- |
| GPT-4o (Baseline) | 0.81s | 2.10s | 131 | $4.50 | aktueller Stand |
| GPT-4.1-mini | 0.45s | 1.20s | >150 | $0.72 | Empfohlen wenn OpenAI-Stack bleibt |
| Claude 4.6 Haiku | 0.60s | 1.50s | >120 | $2.00 | Schema-Cache für 24h nach erstem Call |
| Gemini 3 Flash | 0.25s | 0.80s | 80 | $1.10 |  |
| **Gemini 3.1 Flash-Lite** | **0.15s** | **0.40s** | 115 | $0.55 | **Top Managed** |
| **Qwen3.5-VL-2B (DeepInfra)** | **0.36s** | 0.75s | 347 | **$0.04** | **Top Self-Serverless** |

## Kritische Warnungen

- **GPT-5 / GPT-5-mini Reasoning-Modelle** kategorisch ausschließen. P95 kann auf 362 Sekunden eskalieren wegen obligatorischer Chain-of-Thought-Tokens. Latenz-Spreizung P50→P95 Faktor 6.7.
- **GPT-4o-mini** ist **langsamer** als GPT-4o für unseren 200-Token-Output (56 TPS vs. 131 TPS). Nur Kosten-Vorteil, kein Latenz-Vorteil. Kein guter Tausch.
- **Claude** für Vision solide, aber nicht schneller bei vergleichbarer Qualität. Partial-JSON-Streaming via input_json_delta Events pro Tool-Call, erfordert saubere Akkumulation pro Index.

## Food-Recognition-Qualität

- GPT-4o: 88% Food-Recognition-Accuracy, robust bei >80% Occlusion
- Gemini 2.5 Flash: leicht bessere Volumen/Massen-Schätzung (7.3% vs 7.6% Fehler), gelegentliche Refusals bei Volumen-Schätzung
- Claude Sonnet 4: hinter GPT-4o und Gemini Flash bei Food-Tasks
- Qwen QVQ-MAX: Vorteile bei ostasiatischer Küche, 60% bei starker Occlusion (schwächer)

## Empfehlung

**Primär:** Migration auf **Gemini 3.1 Flash-Lite** als Haupt-Modell. TTFT 150ms, kompatible Structured-Output-API via `responseMimeType: application/json` + `responseJsonSchema`.

**Alternativ für Cost-Maximum:** **Qwen3.5-VL-2B** auf DeepInfra. OpenAI-kompatible REST-API, Wechsel in wenigen Code-Zeilen, 100x günstiger. Kompromiss: Food-Qualität minimal unter GPT-4o/Gemini, aber für typische Teller ausreichend.

**Fallback-Strategie:** Bei unklaren Fällen (niedriger Konfidenz oder Refusals) Escalation auf GPT-4o oder Gemini Pro. So kombinieren wir Speed von Flash-Lite mit Robustheit von Full-Size-Modellen.

# 2. pgvector auf Supabase: Latenz-Bottleneck-Analyse

## Die 3s RPC-Zeit: Wo sie wirklich herkommt

Bei 25.000 Rows × 1536-dim ist die eigentliche HNSW-Suche **unter 10ms pro Query**. Die beobachteten 300-500ms pro RPC kommen fast komplett aus:

1. **PostgREST HTTP-Overhead**: ~5-15ms pro Request (Benchmark: direkte DB P95 2ms vs PostgREST P95 10ms)
2. **Edge Function Boot / Scheduling**: 40-100ms warm, 500-2000ms cold
3. **Netzwerk Client↔Edge↔PostgREST**: 10-50ms je Hop
4. **Supavisor Connection-Pooler Queuing**: Das große Problem bei 8 parallelen Promise.all - Requests werden seriell abgearbeitet wenn Pool kurz ausgelastet, Latenz skaliert linear statt konstant
5. **HTTP/2-Multiplexing-Verlust** in Deno-Edge: bei hoher Asynchronität werden Multiplexing-Vorteile durch Plattform-Throttling zunichtegemacht

## Maßgeblichster Hebel: CROSS JOIN LATERAL + unnest(WITH ORDINALITY)

Beide Research-Quellen kommen unabhängig zum selben Schluss: 8 parallele RPCs zu **einem** Batched Query konsolidieren. Der Overhead collapsed von 8x auf 1x.

```sql
CREATE OR REPLACE FUNCTION match_nutrition_batch(
  query_embeddings jsonb,
  match_count int DEFAULT 20
) RETURNS TABLE (query_idx int, id bigint, source text, source_id text, similarity float, full_row jsonb)
LANGUAGE sql STABLE PARALLEL SAFE AS $$
  SELECT (q.idx - 1)::int AS query_idx, m.id, m.source, m.source_id, m.similarity, m.full_row
  FROM (
    SELECT idx, (arr::text)::vector(1536) AS emb
    FROM jsonb_array_elements(query_embeddings) WITH ORDINALITY AS u(arr, idx)
  ) q
  CROSS JOIN LATERAL (
    SELECT n.id, n.source, n.source_id,
           1 - (n.embedding <=> q.emb) AS similarity,
           to_jsonb(n) AS full_row
    FROM nutrition_db n
    ORDER BY n.embedding <=> q.emb
    LIMIT match_count
  ) m;
$$;
```

Wir hatten diesen Patch in v6 **bereits gebaut** und wieder rückgängig gemacht (brachte nur ~500ms). Grund war vermutlich: wir haben die anderen Bottlenecks (Edge Boot, Pooling) nicht parallel addressiert. **In Kombination mit weiteren Maßnahmen (s.u.) ist der Hebel größer.**

## HNSW-Parameter (25k Rows, 1536-dim)

- **m=16, ef_construction=64** behalten (Defaults). Erhöhung bringt nichts, macht Index nur größer und Build langsamer.
- **`SET LOCAL hnsw.ef_search = 80`** innerhalb Transaktion vor dem SELECT. Global setzen ist ein **Anti-Pattern** in gepoolten Umgebungen (kontaminiert andere Clients).
- **NICHT** auf 400+ hochdrehen — triggert Query-Planner-Flip-Flop auf Sequential Scan (365ms statt 6ms).

## pgvector 0.8.0 Iterative Scans

Ab 0.8.0 (in Supabase 2026 aktiv): `SET LOCAL hnsw.iterative_scan = 'relaxed_order'` löst Overfiltering-Problem bei kombinierten Filter+Vector-Queries. Unser Use-Case hat das aktuell nicht direkt, aber für später (RLS + User-spezifisches Filtering) kritisch.

## pg_prewarm

25k Vektoren × 1536-dim = ~400 MB (Tabelle + Index). Passt locker in RAM. **`SELECT pg_prewarm('nutrition_db_embedding_idx');`** beim DB-Start lädt Index in shared_buffers. Garantiert einstellige Millisekunden-Latenz.

## postgres.js direct vs supabase-js

Kontra-intuitives Finding: supabase-js (PostgREST) ist oft **schneller** als direkte postgres.js-Verbindung bei einfachen Queries (561ms vs 771ms), weil HTTP/2 Keep-Alive und TLS-Reuse bei direkten TCP-Verbindungen fehlen. **prepare: false** ist zwingend bei Supavisor Transaction Mode. Für unseren Use-Case: supabase-js bleibt, Batching via RPC ist der eigentliche Hebel.

## Embedded sqlite-vec im Edge?

**Ausgeschlossen** wegen 256MB Memory Limit der Deno-Isolates. Unsere 150-200MB Vektordaten würden OOM-Kills triggern.

## Redis/Upstash als Cache-Layer

Bei 25k Rows Overkill. Zusätzlicher Netzwerk-Hop, Synchronisations-Problem, zweite DB. Erst ab hohem Durchsatz + Cache-Hit-Patterns sinnvoll.

# 3. Edge-Pipeline & Architektur-Alternativen

## Supabase Edge Functions Cold-Start-Realität

- **Offiziell**: 42ms avg, 86ms P95 (seit Persistent-Storage-Update 2025)
- **Real**: 500-2000ms bei heavy dependencies, 400-600ms repeated requests
- **Mitigation**: pg_cron + pg_net Keep-Alive alle 1-3 Minuten. Kühlt Function warm. **Muss implementiert werden.**
- **Keine Provisioned Concurrency** bei Supabase verfügbar
- **Concurrent Request Limit**: ~200 simultane Requests triggern InvalidWorkerCreation-Errors

## Reduktions-Maßnahmen

1. **Monolithische SDKs raus** aus der Edge Function. Kein @openai/sdk, kein großer ORM. Native fetch + kleine Libs. Schrumpft AST, beschleunigt V8 Isolate Instantiation.
2. **x-region Header** setzen damit Function nahe der DB ausgeführt wird statt nahe dem User. Spart transkontinentale Hops bei DB-Calls.
3. **S3-Mounted Persistent Storage** für statische Referenz-Embeddings oder Lookup-Tabellen. Deno.readFile('/s3/...') statt Netzwerk.

## Streaming: Partial JSON via SSE

Schlüssel-Finding für perceived latency: **erste Zutat nach 1.5-2s sichtbar** selbst bei 10s Gesamtzeit.

- **Provider-Support**: OpenAI Structured Outputs streamen gestreamt parseable JSON, Gemini `generateContentStream` mit `responseJsonSchema`, Anthropic `input_json_delta` Events pro Tool-Call.
- **Deno-Lib**: `@streamparser/json` token-basierter Lexer. Callback onValue wird ausgelöst sobald ein komplettes Ingredient-Objekt im Array erkannt wird.
- **Transport**: SSE (`Content-Type: text/event-stream`) via `ReadableStream` in Deno. CPU-Usage zählt nur active CPU time, idle streams billig.
- **Client-UX**: User sieht erste erkannte Zutat nach ~1.5s, restliche streamen nach. Gefühlt von 10s auf 2s.

## Speculative Execution / PASTE-Pattern

Aus akademischer Forschung (Pattern-Aware Speculative Tool Execution) für Agenten-Workflows. Für uns sehr direkt anwendbar:

1. **Parallel Classify + Extract**: Beim Upload **zwei** parallele Vision-Calls:
    - Small Classifier (Qwen3.5-0.8B, ~370ms TTFT): Top-3 Dish-Kategorien
    - Main Extractor (Gemini Flash-Lite): volle Zutaten-JSON
2. **Prefetch während Main-Call läuft**: Basierend auf Top-3 Kategorien vom Classifier bereits Embeddings + pgvector-Queries auslösen und in Memory cachen.
3. **Merge-Phase**: Wenn Haupt-Extraction fertig, gegen Prefetch-Cache matchen. Hit = Metadaten direkt injizieren, Miss = Fallback auf synchronen DB-Call.

Gewinn: 1.5-2 Sekunden, weil DB-Abfrage nicht mehr im kritischen Pfad liegt.

## Embedding-Cache

300-800ms pro OpenAI-Embedding-Call. "chicken breast grilled" wird 1000x geembeddet. **LRU-Cache auf Edge-Instance** oder persistent als SQLite-File im S3-Mount. Cache-Hit = 0ms.

## On-Device First-Pass (langfristig)

MobileNetV2 / Core ML klassifiziert Food in **38-100ms on-device**. Samsung Health macht komplette Food-Recognition on-device. Meal Snap erreicht sub-1.5s Total-Latenz.

**Für uns Phase-2:** On-device coarse classifier in Expo (expo-tensorflow-lite oder react-native-fast-tflite). Output: Top-N candidate labels + quality score. An Edge Function: shorter prompt, weniger OpenAI-Work nötig.

# 4. Konkurrenz-Latenzen (Reality Check)

- **MyFitnessPal Meal Scan**: 8.4s median, 71.2% accuracy, ±18% portion error
- **Bitesnap**: 8-14s, cloud-only
- **Lose It! Snap It**: nicht publiziert, vermutlich cloud-CNN basiert
- **Cal AI, Vora**: 5-10s laut Marketing
- **DeepFoodCam (research)**: 66ms on iPad Pro, on-device
- **Meal Snap (on-device VLM)**: **<1.5s total**, 92% accuracy

Unsere 10s sind im Rahmen der Cloud-only Konkurrenz. State-of-the-art ist aber bereits sub-2s on-device. Gap zu schließen über Migration auf Flash-Lite + Streaming + Speculative Execution (realistic <5s) oder langfristig on-device first-pass (realistic <2s).

# 5. Konsolidierter Action-Plan (Priorisiert)

## P1 (sofort, 1 Tag Arbeit)

1. **Vision-Modell Migration**: Gemini 3.1 Flash-Lite als neues Default. Fallback auf Gemini 3 Flash bei Quality-Gate-Fail. OpenAI nur als Last-Resort.
2. **SSE-Streaming aktivieren** mit @streamparser/json. Erste Zutat <2s perceived.
3. **pg_cron Keep-Alive** für Edge Function alle 2 Minuten. Eliminiert Cold-Starts.
4. **Embedding-Cache** implementieren (LRU auf Edge-Instance Level, Hash auf Ingredient-String).

**Erwartete Latenz**: 10s → **~4-5s total**, **<2s perceived**.

## P2 (Sprint 2, 2-3 Tage)

1. **match_nutrition_batch** RPC aktivieren **plus** alle anderen P1-Maßnahmen gleichzeitig. Dann greift der Batched Query spürbar.
2. **Speculative Execution**: Parallel Qwen3.5-0.8B-Classifier + Main Vision + Prefetch Embeddings.
3. **x-region Header** setzen um Function nahe DB zu routen.

**Erwartete Latenz**: <3.5s total, <1.5s perceived.

## P3 (Phase 2, Woche+)

1. **On-device Classifier** in Expo (MobileNetV2 / TFLite). Top-3 Candidates + quality score an Edge. Verkürzt Prompt.
2. **pg_prewarm** via Cron automatisiert. HNSW-Index immer warm im RAM.
3. **Persistent-Storage-Cache** für häufige Ingredient-Embeddings als SQLite/JSON auf S3-Mount.

**Erwartete Latenz**: <2s total, <800ms perceived. Competitive mit Meal Snap.

# 6. Kosten-Projektion

| Szenario | $ / Scan | 100 Scans/User/Monat |
| --- | --- | --- |
| Aktuell (GPT-4o) | $0.0045 | $0.45 |
| P1 (Gemini Flash-Lite) | $0.0006 | $0.06 |
| P1 + Qwen (DeepInfra) | $0.00004 | $0.004 |

Kostensenkung Faktor 7-100x möglich, Coralate-Target <$1/User/Monat weit übererfüllt.

# 7. Was wir damit NICHT lösen

- **Sweet-Corn-Granularitätsproblem**: Vision-Modell-Wechsel löst das nicht zwangsläufig. Braucht spezifische Prompting-Instruktion ("Re-examine small distinct items") oder On-Device Detection-Layer.
- **OFF-Record 00004800 Bratwurst**: Datenqualität-Bug im Import, nicht Architektur.
- **B6-NULLs**: Läuft parallel via Cross-DB-Borrowing.

# Quellen

- Perplexity Research (3 Durchläufe, April 2026): Vision-Modelle / pgvector / Edge-Pipeline
- Gemini Deep Research PDF: Vision-Modell-Latenzoptimierung (April 2026)
- Gemini Deep Research PDF: pgvector Multi-Vector-Query Optimierung (April 2026)

Referenzen in den Original-Quellen belegt: DeepInfra-Benchmarks, [ArtificialAnalysis.ai](http://ArtificialAnalysis.ai), Supabase Docs, pgvector Release Notes 0.8.0, OpenAI Structured Outputs Docs, Google AI Developers Docs, Anthropic API Docs.