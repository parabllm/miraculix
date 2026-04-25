---
typ: sub-projekt
name: "Cora AI"
aliase: ["Cora", "Cora AI", "Cora Engine", "cora-engine"]
ueber_projekt: "[[coralate]]"
bereich: produkt
umfang: offen
status: in_arbeit
lieferdatum: ""
kapazitaets_last: hoch
kontakte: ["[[jann-allenberger]]", "[[lars-blum]]"]
tech_stack: ["supabase", "edge-functions", "postgres", "pgvector", "pgmq", "pg-cron", "vertex-ai", "gemini"]
erstellt: 2026-04-18
notizen: "AI-Schicht von Coralate. Positionierung zwischen Korrelations-Engine (Vault) und Fitness-Coach (DB) aktuell nicht konsolidiert. Siehe Diskrepanzen-Doku."
quelle: extrahiert
vertrauen: extrahiert
---

## Kontext

AI-Schicht von Coralate. Liest User-Daten (Workouts, Ernährung, Aktivität, Profil, Facts) und produziert strukturierte Outputs für die App. Backend via Supabase Edge Function `cora-engine`, LLM via Vertex AI Gemini 2.5 Flash in `europe-west4`.

**Zwei parallele Wahrheiten aktuell:**
- Vault-Positionierung: Korrelations-Engine, 3 Modi, 4 Action-Typen, kein Coach, harte SaMD-Abgrenzung.
- DB-Stand: Fitness-Coach, 6 Trigger, 19 Action-Typen, 5 Coach-Prompts.

Konsolidierung steht aus. Siehe [[diskrepanzen]] und [[meeting-2026-04-18-cora-ausrichtung]].

## Architektur (Vault-Soll)

- Deployment: Supabase Edge Function `cora-engine` JWT-protected
- LLM: Vertex AI Gemini 2.5 Flash, region `europe-west4` (GDPR Residency)
- Supabase Project: `vviutyisqtimicpfqbmi` (eu-west-1, Postgres 17)
- Extensions: pgvector (HNSW Memory-Embeddings), pgmq (Queues), pg_cron (Scheduled Jobs)

## Drei Modi (Vault-Lock)

1. **Proaktiv (Narrator).** Cora erscheint ohne User-Frage wenn Signal + Ziel klar sind. Kurzer Hinweis plus einer von 4 Action-Buttons.
2. **Card Q&A.** User öffnet Korrelationskarte, chatet mit Cora strikt zu dieser Karte.
3. **Home-Chat mit RAG.** Freier Chat mit Auto-Retrieval aus whitelisted Datenkategorien.

## Vier Action-Button-Typen (Vault-Lock)

| Typ | Wann |
|---|---|
| GEWICHT_ANPASSEN | Performance hoch, Ziel Kraft oder Masse |
| VOLUMEN_ANPASSEN | Performance niedrig oder Volumen zu hoch |
| FOOD_SCREEN_OEFFNEN | Kaloriendefizit zu groß für Ziel |
| VARIATION_VORSCHLAGEN | Stagnation bei Übung ab 3 Wochen |

## DB-Stand (Ist)

- 5 aktive Coach-Prompts in `prompt_versions`
- 19 aktive Action-Types in `action_types` über 9 Kategorien
- 6 Einträge in `ai_suggestions` vom 7. April, Prototyp-Stand
- 0 Einträge in `cora_memories`, `chat_sessions`, `chat_messages`
- 6 Knowledge-Chunks von Lars in `knowledge_chunks`

## SaMD-Position (Vault-Soll, nicht verhandelbar)

- Keine Symptominterpretation, keine Diagnosen, keine medizinischen Ratschläge
- Proaktive Empfehlungen nur im Fitness-Performance-Bereich, ziel-gebunden
- "Coralate Performance Index" ist Fitness-Wert, nicht Gesundheits- oder Erholungswert
- User bestätigt jede Aktion aktiv
- Disclaimer sichtbar im Interface

Formulierungsregel: Datenbeobachtung + Zielbezug + offene Möglichkeit. Nie Anweisung, nie Diagnose. Verbotene Wörter: "du musst", "du solltest", "kritisch", "um X zu vermeiden".

## Aktueller Stand

2026-04-18: Bestandsaufnahme Vault vs. DB, Diskrepanzen dokumentiert, Meeting mit Lars und Jann angesetzt. Drei Options auf dem Tisch: Vault-Weg, DB-Weg, Mittelweg. Entscheidung steht aus.

Vor der Entscheidung kein weiterer Backend-Build. Food-Scanner läuft parallel und ist nicht betroffen.

## Detail-Docs

- [[cora-ai-architektur]] Architektur-Spezifikation der drei Modi, SaMD, Pipeline
- [[scope-jann-proposal]] Jann's Scope-Vorschlag vom 12. April (pausiert, future scope)
- [[diskrepanzen]] Abgleich Vault gegen Live-DB, Handlungsbedarf
- [[knowledge-chunks-guide]] Anleitung für Lars zum Schreiben und Verwalten von Knowledge-Chunks
- [[meeting-2026-04-18-cora-ausrichtung]] Agenda und Notizen zum Klärungs-Meeting

## Logs

Siehe `logs/` Unterordner. Aktuell:

- `2026-04-07-cora-backend-build.md` Backend-Hauptbuild

## Offene Aufgaben

- Positionierung entscheiden (A Vault, B DB, C Mittelweg)
- Prompts konsolidieren
- Action-Types konsolidieren
- Modi und Trigger zusammenführen
- Frontend-Kontrakt mit Jann klären

## Kontakte

- [[jann-allenberger]] Frontend, Scope-Vorschläge
- [[lars-blum]] Fitness-Domain, Knowledge-Autor
