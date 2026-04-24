---
typ: wissen
name: "Continuity Doc Pattern - Chat-Übergabe bei Token-Limit"
aliase: ["Handover Prompt", "Continuity Doc", "Chat Handover"]
domain: ["claude", "workflow", "context-management"]
kategorie: pattern
vertrauen: bestätigt
quellen:
  - "[[01-projekte/coralate/logs/2026-04-07-cora-backend-build]]"
  - "[[01-projekte/coralate/food-scanner/logs/2026-04-13-pipeline-production-ready-doc62]]"
  - "[[01-projekte/coralate/food-scanner/logs/2026-04-13-session-abschluss-doc62-auth-geloest]]"
projekte: ["[[coralate]]", "[[food-scanner]]"]
zuletzt_verifiziert: 2026-04-16
widerspricht: null
erstellt: 2026-04-16
---

## Problem

Claude-Chats haben Token-Budget. Komplexe Multi-Session-Projekte (Cora Backend, Food Scanner) überschreiten das Budget regelmäßig. Ohne Strukturierter Übergabe verliert der nächste Chat den Kontext und stellt dieselben Fragen neu.

## Lösung

**Am Ende jedes signifikanten Chats wird ein Handover-Prompt als eigenständiges Markdown-File erzeugt.** Dieser Prompt ist so geschrieben, dass ein frischer Claude-Chat damit sofort loslegen kann ohne zusätzliche Klärung.

## Struktur eines Handover-Prompts

1. **Wer ich bin** - Deniz' Rolle, Tonfall, Arbeitsweise
2. **Was das Projekt ist** - Projekt-Kontext, Team, Stack (kurz)
3. **Was im letzten Chat passiert ist** - kompletter Session-Recap (Entscheidungen, Implementierungen)
4. **Zentrale Referenz-Dokumente** - z.B. Master-Doc-URLs / Page-IDs (DOC-62 bei Food Scanner)
5. **Weiterer Kontext** - DB-IDs, relevante Docs, Supabase-Projekt-IDs
6. **Zugangsdaten** - Secret-Namen (NICHT die Secrets selbst)
7. **Was als Nächstes ansteht** - priorisiert
8. **Arbeitsweise-Reminder** - "Plan-and-Execute strikt", "nichts raten", etc.
9. **Erste Aktion für neuen Chat** - explizit: "Starte mit Fetch von DOC-62 und frage nach heutigem Fokus"

## Wo angewendet

- [[coralate]] - Cora Backend Chat (2026-04-07) mit 1.17M chars Handover in "Continuity Doc und Projekt-Einstieg" (2026-04-11)
- [[food-scanner]] - DOC-62 als Master-Doc + `HANDOVER_NEXT_CHAT.md` als Prompt-File (Session 2026-04-13)

## Meta-Regel

Wenn ein Chat länger als ~300k chars wird: Handover-Prompt am Ende zwingend. Nicht versuchen "noch eine Runde" zu pressen - Qualität degradiert mit Token-Verbrauch.
