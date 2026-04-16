# Cora Backend — Fortlaufende Doku Sprint 2

> **Continuity Bridge:** Diese Doku ist für den nächsten Chat (Food Scanner). Lies sie komplett bevor du an coralate weiterarbeitest.
> 

**Stand:** 7. April 2026 | **Sprint:** 2 DONE

## 1. Was ist Cora?

Cora ist KEIN Chatbot. Cora ist eine **Correlation Engine** die auf definierte Trigger reagiert (`pre_workout`, `post_workout`, `coaching_chat`, `daily_start`, `daily_summary`, später `post_food_log`, `post_activity`) und strukturierte Coach-Empfehlungen generiert.

**Output-Schema (Sprint 2 v2 - kompakt):**

```json
{
  "message": "1-2 kurze Sätze, das was die App anzeigt",
  "recommendation": { "action_type": "...", "target_ref": null } | null,
  "severity": "info|warning|critical",
  "confidence": 0.0-1.0,
  "internal_notes": "Audit-Notizen, NIE user-facing"
}
```

**Wichtigster Insight:** Schema-Switch von `observations[]+actions[]` zu `message+recommendation:single|null` brachte 3× schnellere Latenz (4.4s→1.0s), 2× billigere Calls (0.04ct→0.02ct) und bessere Coaching-Qualität durch erzwungene Priorisierung.

## 2. Tech Stack

- **Frontend:** React Native + Expo (Jann)
- **Backend:** Supabase Postgres 17.6.1, Project `vviutyisqtimicpfqbmi`, eu-west-1
- **LLM:** Gemini 2.5 Flash via **Vertex AI europe-west4** (DSGVO Pflicht!)
- **Edge Function:** Deno, JWT-protected, `cora-engine`
- **Auth zu GCP:** Service Account `cora-engine@project-52a91dbf-9fe7-4b17-86f` + Web Crypto JWT
- **Queue:** pgmq native
- **GCP Project:** `project-52a91dbf-9fe7-4b17-86f` (Free Trial €254)
- **Secret in Supabase:** `GCP_SERVICE_ACCOUNT_JSON`

## 3. Datenmodell

Cora-eigene Tabellen (Janns `profiles` und `workouts` werden NIE angefasst):

- `cora_profiles`, `user_facts`, `goals`, `goal_milestones`
- `action_types` (Lookup für 19 erlaubte action_type Werte)
- **`ai_suggestions`** — zentrale Tabelle, jede Cora-Antwort, mit context_snapshot LZ4, Token-Counts, Cost, Latency
- `suggestion_events`, `suggestion_outcomes` — User-Feedback
- `chat_sessions`, `chat_messages`
- `cora_memories` (HNSW vector(768)) + `cora_memory_stats` — Sprint 3
- `knowledge_chunks` — aktuell 6, Ziel 50 mit pgvector
- `prompt_versions`, `consent_revocation_log`

**Postgres Functions (Sprint 2):**

- `get_cora_user_context(user_id, workout_id?, as_of_time?)` — DER Context-Loader, time-travel-fähig
- `insert_or_get_suggestion(...)` — Idempotency via INSERT ON CONFLICT
- `pgmq_send_memory_job(...)` — Memory Worker Dispatch

**Migrations Sprint 2:** 1.25 (Functions), 1.26 (facts_used UUID→TEXT fix), 1.27 (temporal correctness), 1.29 (as_of_time param)

## 4. Edge Function Pipeline (8 Steps)

URL: `https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/cora-engine` | Version 4

1. Request Validation
2. Idempotency Check
3. fetchUserContext
4. GDPR Consent Check
5. fetchKnowledgeChunks + fetchActivePrompt (parallel)
6. Token Budget Audit + truncateKnowledge
7. assembleUserPrompt + Vertex AI generateContent
8. updateSuggestionWithResponse + dispatchMemoryExtractionJob

**Patches im Code (P1-P15):** maxOutputTokens 8192, thinkingBudget 0, Vertex AI EU, LZ4 Compression, Hash→Confidence→Embedding Dedup, pgmq dead-letter queue.

## 5. Test-Ergebnisse (Lars Mock-User)

**User-ID:** `e56adbbd-1a99-4abc-af9e-95d53017574a` | 20 Workouts Jan-März 2026, dann 26d Bali-Pause

**Test pre_workout 7. April (Comeback):**

- message: "Du hattest 26 Tage Pause. Fang heute leichter an, ca. 70% deiner letzten Gewichte."
- severity: warning, recommendation: adjust_weight
- 1299ms, 0.0223 ct

**Test pre_workout 2. Februar 18:00 (Time-Travel):**

- message: "Du hattest 3 Tage Pause – perfekt erholt. Gib heute Vollgas!"
- severity: info, recommendation: null
- 1001ms, 0.0204 ct

Sprint 2 Total Cost: ~0.19 Cent. Production-tauglich.

## 6. Architektur-Entscheidungen (kritisch für nächste Chats)

1. **Context-Building ist die Engineering-Challenge**, nicht Modell-Wahl.
2. **Schema definiert Verhalten stärker als Prompt.** Verbose Schemas erzwingen verbose Outputs.
3. **Knowledge Stuffing > RAG** bis ~50 Chunks.
4. **`thinkingBudget: 0`** ist Pflicht für structured outputs (siehe googleapis/python-genai #782).
5. **Output Tokens dominieren Cost** ($2.50/M vs $0.30/M input). Optimiere Output, nicht Input.
6. **Idempotency via INSERT ON CONFLICT.** Client generiert key.
7. **GDPR Hard Constraint:** Vertex AI EU (NICHT [ai.google.dev](http://ai.google.dev)),