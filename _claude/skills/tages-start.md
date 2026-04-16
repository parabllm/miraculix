---
name: miraculix-tages-start
description: Triggered whenever Deniz says "tages-start", "was steht an", "guten morgen", "daily start", "wie siehts aus heute" or similar variations asking for a morning briefing. Use this skill to create a Daily Note in the Obsidian vault, gather all relevant data (Google Calendar events, open tasks from vault, last session log, inbox count), present a structured morning briefing to Deniz, and then ask for his capacity and focus projects for the day. This is Deniz's primary morning ritual — always use this skill when he asks what's on for the day.
---

# Tages-Start

Morning Briefing für Deniz. Erstellt Daily Note, sammelt Daten, fragt Kapazität.

## Schritt 1 — Daily Note erstellen

Prüfe ob `04-tagebuch/{jahr}/{monat}/{datum}.md` existiert. Wenn nein, erstelle mit Template.

## Schritt 2 — Daten sammeln

Parallel:
- Google Calendar (falls MCP): Events für heute
- Google Tasks (falls MCP): Tasks mit Due heute
- Vault: offene Aufgaben aus `01-projekte/`
- Vault: letzten Log-Eintrag finden
- Vault: `00-eingang/unverarbeitet/` — Anzahl

## Schritt 3 — Präsentieren

Scanbar:

```
Heute ist [Wochentag], [Datum].

**Kalender:**
- [Uhrzeit] [Event]

**Offene Aufgaben:** [Anzahl gesamt]
- [Projekt]: [Task 1], [Task 2]
(max 10, priorisiert nach Fälligkeit)

**Letzte Session:** [Datum] — [Projekt]: [was gemacht]

**Eingang:** [X] unverarbeitete Items
```

## Schritt 4 — Fragen (einzeln)

1. "Wie ist deine Kapazität heute? (1-10)"
2. "Neue Themen oder was geändert?"
3. "Was willst du heute angehen?"

## Schritt 5 — Verarbeiten

- Kapazität in Daily Note Frontmatter
- Fokus-Projekte setzen
- Priorisierte Tasks in Google Tasks (falls MCP)

## Regeln

- Sachlich, scanbar.
- Kapazität unter 5 → nur niedrig-kapazitäts-Tasks.
- Inbox voll (5+) → aktiv hinweisen.
- Letzter Log älter als 3 Tage → hinweisen.
- Thesis-Deadline (2026-06-15) bei Kapazität ≥ 7 aktiv als Fokus vorschlagen.
