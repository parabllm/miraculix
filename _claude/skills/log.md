---
name: miraculix-log
description: Triggered whenever Deniz says "log", "fortschritt speichern", "pack das in logs", "speicher den stand", "abschluss", or at the end of a working session. Use this skill to capture session learnings — write log entries to the relevant project(s), update task statuses, update project current state if changed, and critically check for cross-project patterns that occurred 2+ times and propose knowledge destillation. This is how raw work becomes documented work.
---

# Log (Session-Abschluss)

Session-Erkenntnisse speichern. Logs + Tasks + ggf. Destillation.

## Schritt 1 — Scope

Welche Projekte waren Thema? Aus Gesprächsverlauf ableiten. Bei Unklarheit fragen.

## Schritt 2 — Log-Einträge erstellen

Pro Projekt in `01-projekte/{projekt}/logs/{YYYY-MM-DD}-{titel}.md`:

```yaml
---
typ: log
projekt: "[[{slug}]]"
datum: 2026-04-16
art: fortschritt
vertrauen: extrahiert
quelle: chat_session
---
```

Body:
- Problem / Ziel
- Was wurde gemacht
- Entscheidungen
- Learnings / Patterns
- Offene Fragen / nächste Schritte

**Destilliert, nicht Chat-Rohtext.** 30 Sekunden scanbar.

## Schritt 3 — Task-Status

- Erledigt → Checkbox abhaken / `status: erledigt`
- Neue Tasks → hinzufügen
- Blockiert → `status: blockiert` + Grund

## Schritt 4 — Projekt-Stand (falls nötig)

Wenn substantiell geändert: `{slug}.md` `## Aktueller Stand` updaten.
Nicht bei jedem kleinen Fortschritt — nur bei echter Stand-Änderung.

## Schritt 5 — Wissens-Destillation prüfen

**Kritisch.** Bevor committen, prüfe:
- Pattern aus dieser Session in anderen Projekten schon aufgetaucht?
- Keyword-Suche in Logs anderer Projekte

Bei Match (2+) → Vorschlag siehe `miraculix-wissens-destillation` Skill.

## Schritt 6 — Plan zeigen

```
**Geplante Änderungen:**
- [ ] Log: herosoftware/logs/2026-04-16-wf4-webhook-fix.md
- [ ] Task abhaken: "WF4 Webhook debuggen"
- [ ] Neue Task: "WF4 in Produktion monitoren"
- [ ] Wissens-Vorschlag: 02-wissen/n8n/webhook-race-condition.md (2. Auftreten)

OK?
```

Nach OK:
- Gebündelt schreiben
- Git-Commit: `log: {projekt} {was}`

## Regeln

- **Logs sind append-only.** Nie editieren, nur neue.
- **Destillieren, nicht Chat kopieren.**
- **Commit-Message aussagekräftig.** Nicht "log", sondern "log: {projekt} {titel}".
- **Bei kurzer Session:** 1-Zeilen-Log reicht. Nicht zwanghaft ausführlich.
- **Bei großen Meilensteinen:** auch `## Abgeschlossene Meilensteine` in `{slug}.md` ergänzen.
