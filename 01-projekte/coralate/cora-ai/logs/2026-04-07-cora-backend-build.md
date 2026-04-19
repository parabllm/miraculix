---
typ: log
projekt: "[[cora-ai]]"
datum: 2026-04-07
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["supabase", "edge-functions", "pgvector"]
---

Cora-Backend-Hauptbuild. Chat "Cora Backedn" (132 Messages, **1.17M chars** - der größte Coralate-Chat). Fortlaufende Doku Sprint 2 ging daraus hervor.

## Scope

Backend-Fundament für Cora AI:
- `cora_memories`, `cora_facts`, `cora_call_queue`, `ai_suggestions`, `knowledge_chunks` Tabellen
- RAG-Pipeline für Home-Chat-Modus
- Edge Functions als Orchestration-Layer

## Meta-Einsichten

- "Continuity Doc"-Pattern etabliert: jeder lange Chat endet mit Handover-Prompt-File für Nachfolge-Chat (Token-Budget-Limit)
- Pattern wiederholt in Food-Scanner-Chats

## Verwandte Chats

- "Continuity Doc und Projekt-Einstieg" (2026-04-11, 112 Messages, 596k) - Continuity-Doc-Pattern formalisiert
- "Cost-Architektur und RAG-Optimierung für Health-Apps" (2026-04-07, 2 Messages, 2k) - Short-Research
- "Kritischer Deep-Dive in 28 Prüfpunkte" (2026-04-07, 4 Messages, 4k) - Review
- "Missing backend plan document for review" (2026-04-07, 4 Messages, 5k) - Missing-Doc-Fix

## Quelle

Claude-Chat "Cora Backedn" 2026-04-07. Original `Cora Backend - Fortlaufende Doku Sprint 2` Notion-Page resultierte daraus.
