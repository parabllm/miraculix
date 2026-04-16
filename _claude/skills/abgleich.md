---
name: miraculix-abgleich
description: Triggered whenever Deniz says "abgleich X", "reconcile X", "update X", "X aktualisieren", "prüf mal X", or similar — where X is a project name (coralate, herosoftware, bellavie, hays, thalor etc). Use this skill to read the project file, recent logs and tasks, identify new inputs since last reconcile, find contradictions, propose surgical updates with vertrauen-level and source, wait for Deniz's approval per update, then bundle-write and git-commit. Central mechanism against information drift.
---

# Abgleich (Reconcile)

Projekt mit neuen Inputs abgleichen. Zentraler Drift-Schutz.

## Schritt 1 — Scope

Welches Projekt? Lies:
- `01-projekte/{projekt}/{slug}.md`
- Alle Sub-Projekt-Files
- Letzte 5-10 Logs
- Offene Aufgaben
- Verknüpfte Wissens-Einträge

## Schritt 2 — Neue Inputs

Seit `zuletzt_abgeglichen`:
- Inbox-Items mit `vermutetes_projekt: {projekt}`
- Neue Meetings, Logs
- Was Deniz gerade im Chat sagt

## Schritt 3 — Widersprüche finden

Pro neuer Info: widerspricht existierender? veraltet? Duplikate?

## Schritt 4 — Update-Plan

```
**Update 1:** coralate.md "Cora nutzt Gemini 2.0"
→ "Cora nutzt Gemini 2.5 (Stand 2026-04-16, Quelle: Meeting Jann)"
Vertrauen: extrahiert
Begründung: Meeting-Note 2026-04-14

**Update 2:** aufgaben/backend-refactor.md `offen`
→ `erledigt`
Vertrauen: abgeleitet
Begründung: Log 2026-04-15 sagt "abgeschlossen"

**Widerspruch:** SDK 54 vs SDK 55 — welche Version aktuell?
```

## Schritt 5 — Deniz entscheidet

Pro Update: OK / Nein / Anders.

## Schritt 6 — Ausführen

Bundled schreiben. Git-Commit:
`abgleich: coralate (3 updates, 1 widerspruch aufgelöst)`

## Schritt 7 — Metadaten

- `{slug}.md` Frontmatter: `zuletzt_abgeglichen: YYYY-MM-DD`
- Betroffene Wissens-Einträge: `zuletzt_verifiziert: YYYY-MM-DD`

## Regeln

- **Nie automatisch überschreiben.** Plan, OK, dann schreiben.
- **Jedes Update: Begründung + Quelle.** Kein "ich denke" ohne Beleg.
- **Datierung erzwingen.** "Stand [Datum]".
- **Wissens-Einträge mit-prüfen** wenn Projekt-Update einen betrifft.
- **Kein Schneeballeffekt.** Updates in anderen Projekten nur als Vorschlag.
