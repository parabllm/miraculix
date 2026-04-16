# Cora Backend — Sprint 2 Continuity Doc (Pre-Food-Scanner Bridge)

Created: 11. April 2026 12:58
Doc ID: DOC-45
Doc Type: Architecture
Gelöscht: No
Last Edited: 11. April 2026 12:58
Last Reviewed: 8. April 2026
Lifecycle: Active
Notes: Continuity-Bridge zwischen Cora Backend Sprint 2 und Food Scanner Track. Lesen vor jedem neuen coralate-Chat.
Pattern Tags: Sync, Webhook
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: Supabase
Verified: No

## Scope

Dieses Dokument ist die **Continuity-Bridge** zwischen Chat-Sessions zum coralate Backend. Der nächste Claude-Chat (insbesondere für den parallelen **Food Scanner Track**) muss hier den kompletten Stand, die Architektur-Entscheidungen und den Gedankengang finden — ohne den vorherigen Chat zu kennen.

Zielgruppe: zukünftige Claude-Chats die an coralate weiterarbeiten, primär Food Scanner Integration.

NICHT in diesem Doc: Day-to-day Status (→ Logs DB), atomare Code-Patterns (→ Knowledge DB), offene Tasks (→ Tasks DB).

## Architecture

### Was Cora ist (Mental Model)

Cora ist **kein Chatbot**. Cora ist eine **Correlation Engine** die auf definierte Trigger reagiert (`pre_workout`, `post_workout`, `coaching_chat`, `daily_start`, `daily_summary`, später `post_food_log`, `post_activity`) und strukturierte Coach-Empfehlungen generiert.

Kern-Idee: Statt User mit AI-Chat zu überfluten, verbindet Cora proaktiv Trainings-, Ernährungs- und Recovery-Daten und liefert situativ EINE klare Antwort + maximal EINE Action.

### Output-Schema (Sprint 2 v2 — kompakt)

```json
{
  "message": "1-2 kurze Sätze, das was die App anzeigt",
  "recommendation": { "action_type": "...", "target_ref": null } | null,
  "severity": "info|warning|critical",
  "confidence": 0.0-1.0,
  "internal_notes": "Audit-Notizen, NIE user-facing"
}
```

Der Schema-Switch von `observations[]+actions[]` zu `message+recommendation:single|null` brachte 3× schnellere Latenz (4.4s→1.0s), 2× billigere Calls (0.04ct→0.02ct), UI-ready ohne Post-Processing, bessere Coaching-Qualität durch erzwungene Priorisierung.

### Tech Stack (immutable)

- **Frontend:** React Native + Expo (Jann Allenberger)
- **Backend:** Supabase Postgres 17.6.1, Project `vviutyisqtimicpfqbmi`, region eu-west-1
- **LLM:** Gemini 2.5 Flash via **Vertex AI europe-west4** (DSGVO-Pflicht, NICHT [ai.google.dev](http://ai.google.dev))
- **Edge Function:** Deno, JWT-protected, slug `cora-engine`
- **Auth zu GCP:** Service Account `cora-engine@project-52a91dbf-9fe7-4b17-86f` + Web Crypto JWT, OAuth2 Token Exchange
- **Queue:** pgmq native
- **GCP Project:** `project-52a91dbf-9fe7-4b17-86f` (Free Trial €254)
- **Secret in Supabase:** `GCP_SERVICE_ACCOUNT_JSON`

### Datenmodell (Cora-Tabellen)

Janns `profiles` und `workouts` werden NIE angefasst. Cora-eigene Tabellen:

- `cora_profiles`, `user_facts`, `goals`, `goal_milestones`
- `action_types` — Lookup für 19 erlaubte action_type Werte
- **`ai_suggestions`** — zentrale Tabelle, jede Cora-Antwort, mit context_snapshot LZ4-compressed, Token-Counts, Cost, Latency, Audit-Trail
- `suggestion_events`, `suggestion_outcomes` — User-Feedback
- `chat_sessions`, `chat_messages` — für coaching_chat
- `cora_memories` (HNSW vector(768)) + `cora_memory_stats` — Sprint 3 Memory Layer
- `knowledge_chunks` — aktuell 6 Chunks, Ziel ~50 mit pgvector RAG
- `prompt_versions`, `consent_revocation_log`

### Postgres Functions

- `get_cora_user_context(user_id, workout_id?, as_of_time?)` — DER zentrale Context-Loader, time-travel-fähig via `as_of_time`
- `insert_or_get_suggestion(...)` — Idempotency via INSERT ON CONFLICT
- `pgmq_send_memory_job(...)` — Memory Worker Dispatch

### Edge Function 8-Step Pipeline

URL: `https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/cora-engine`

1. Request Validation
2. Idempotency Check (`insert_or_get_suggestion`)
3. `fetchUserContext` (`get_cora_user_context`)
4. GDPR Consent Check (`consent_ai_processing`)
5. `fetchKnowledgeChunks` + `fetchActivePrompt` (parallel)
6. Token Budget Audit + `truncateKnowledge`
7. `assembleUserPrompt` + Vertex AI `generateContent`
8. `updateSuggestionWithResponse` + `dispatchMemoryExtractionJob`

Patches im Code: `maxOutputTokens: 8192`, `thinkingBudget: 0`, Vertex AI EU, LZ4 Compression, Hash→Confidence→Embedding Dedup, pgmq dead-letter queue.

## Constitution (Hard Rules)

1. **Janns Tabellen sind tabu.** Cora schreibt NIE in `profiles` oder `workouts`.
2. **GDPR Hard Constraint:** Vertex AI MUSS in EU-Region laufen. [ai.google.dev](http://ai.google.dev) verboten.
3. **`thinkingBudget: 0` ist Pflicht** für structured outputs (siehe googleapis/python-genai #782, #1039).
4. **Schema definiert Verhalten stärker als Prompt.** Verbose Schemas erzwingen verbose Outputs.
5. **Output Tokens dominieren Cost** ($2.50/M vs $0.30/M input). Optimiere Output, nicht Input.
6. **Idempotency via `idempotency_key`.** Client generiert, Server cached.
7. **Knowledge Stuffing > RAG bis ~50 Chunks.** Erst dann pgvector similarity search.
8. **Context-Building ist die Engineering-Challenge**, nicht Modell-Wahl.

## Current Implementation

### Status Sprint 2: DONE (7. April 2026)

Migrations Sprint 2: 1.25 (Functions), 1.26 (`facts_used` UUID→TEXT fix), 1.27 (temporal correctness), 1.29 (`as_of_time` Parameter). Edge Function Version 4 mit `as_of_time` support deployed.

### Test-Ergebnisse (Lars Mock-User)

User-ID: `e56adbbd-1a99-4abc-af9e-95d53017574a` | 20 Workouts Jan 14 – März 13, 2026, dann 26-Tage-Bali-Pause.

**Test pre_workout 7. April (Comeback nach Bali):**

- message: "Du hattest 26 Tage Pause. Fang heute leichter an, ca. 70% deiner letzten Gewichte."
- severity: warning, recommendation: adjust_weight
- 1299ms, 0.0223 cent

**Test pre_workout 2. Februar 18:00 (Time-Travel via `as_of_time`):**

- message: "Du hattest 3 Tage Pause – perfekt erholt. Gib heute Vollgas!"
- severity: info, recommendation: null
- 1001ms, 0.0204 cent

Sprint 2 Total Cost: ~0,19 Cent. Pipeline ist Production-tauglich.

### Connection zum Food Scanner (kritisch für nächsten Chat)

Food Scanner ist der **parallele Track** zu Cora Backend.

**Geplanter Flow:**

```
User macht Foto in App
  → React Native Upload
  → n8n Workflow (self-hosted, Hetzner VPS n8n.thalor.de)
  → Vision AI (Gemini Vision oder GPT-4o)
  → Ingredient-Erkennung
  → Mapping gegen Ingredient-Library (TBD)
  → Strukturierte Macros zurück
  → Supabase: food_entries Insert (user-auth-tied)
```

**Berührungspunkte mit Cora Backend:**

1. **`food_entries` Tabelle existiert bereits** (Sprint 1). Hat aktuell nur `kcal` auf entry-level. **Tech Debt:** Protein/Carbs/Fat/Fiber müssen als per-entry columns ergänzt werden — aktuell nur day-aggregates in `food_day_records`.
2. **Trigger `post_food_log` ist im System reserviert** (Phase 2 Placeholder im Edge-Function-Code). Sobald Food Scanner Daten liefert → Cora kann analysieren.
3. **Auth Context:** Food Scanner muss mit gleichem `user_id` arbeiten wie Cora — Supabase Auth ist Single Source of Truth.
4. **n8n vs Edge Function:** Food Scanner läuft bewusst über n8n (Vision AI Routing flexibler), Cora Backend ist Edge Function (Latenz-kritisch).
5. **DSGVO:** Vision AI MUSS in EU-Region laufen. Falls Gemini Vision → Vertex AI europe-west4. Falls GPT-4o → OpenAI EU-Endpoint.

## Edge Cases

- **Pre/Post Workout ohne workout_id:** `pre_workout` läuft ohne `workout_id`, fällt in Live-State-Modus. `post_workout` braucht zwingend `workout_id`.
- **Time-Travel-Tests:** `as_of_time` Parameter überschreibt sowohl `now()` als auch `workout_id` Logik. Aggregates werden relativ zum analysierten Zeitpunkt berechnet.
- **Idempotency Cache-Hit:** Bei doppeltem `idempotency_key` wird die existierende Suggestion zurückgegeben mit `cached: true`.
- **GDPR Consent fehlt:** Pipeline aborted bei Step 4, schreibt error-Suggestion mit `consent_required`.

## Open Questions

- Welcher Vision AI Provider für Food Scanner? (Gemini Vision EU vs GPT-4o EU)
- Wo lebt die Ingredient-Library? (Supabase Table vs externe API)
- Wann wird `food_entries` Schema-Erweiterung gemacht? (vor oder parallel zum Food Scanner Build)
- Wann startet Memory Worker (pgmq Consumer)? (Sprint 3 fix)
- Wann Schema-Label-Cleanup `_30d` → `_lifetime`? (Tech Debt aus Sprint 2)

## Tech Debt für Sprint 3

- `_30d` Field-Labels in `get_cora_user_context` umbenennen zu `_lifetime`
- Memory Worker (pgmq Consumer) deployen
- Hash → Confidence → Embedding Dedup-Logik (P7)
- Importance-Escalation UPDATE statt NOOP (P7+P8)
- Langfuse Tracing einbauen
- `food_entries` Schema erweitern (per-entry Macros)
- Alten kompromittierten GCP Service Account Key in Console löschen
- GCP Budget Alert einrichten
- Knowledge Base von 6 → 20+ Chunks erweitern (mit Lars)