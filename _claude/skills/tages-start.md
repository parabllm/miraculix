---
name: miraculix-tages-start
description: Triggered whenever Deniz says "tages-start", "was steht an", "guten morgen", "daily start", "wie siehts aus heute" or similar variations asking for a morning briefing. Use this skill to create a Daily Note in the Obsidian vault, gather all relevant data (Google Calendar events, open tasks from vault, last session log, inbox count), present a structured morning briefing to Deniz, and then ask for his capacity and focus projects for the day. This is Deniz's primary morning ritual — always use this skill when he asks what's on for the day.
---

# Tages-Start

Morning Briefing für Deniz. Erstellt Daily Note, sammelt Daten, fragt Kapazität.

---

## Schritt 1 — Daily Note erstellen

Prüfe ob `04-tagebuch/{jahr}/{monat}/{datum}.md` existiert.

Wenn nein, erstelle mit Template:

```yaml
---
typ: tagebuch
datum: YYYY-MM-DD
kapazitaet_energie: null
kapazitaet_zeit: null
kapazitaets_notiz: ""
fokus_projekte: []
---

# YYYY-MM-DD — [Wochentag]

## Kalender heute

## Offene Aufgaben

## Session-Notizen

## Tages-Review
```

---

## Schritt 2 — Daten sammeln

**Parallel:**
- Google Calendar (falls MCP verfügbar): Events für heute
- Google Tasks (falls MCP verfügbar): Tasks mit Due heute
- Vault: offene Aufgaben aus `01-projekte/` (Files mit `status: offen` oder offene Checkboxen in `{slug}.md`)
- Vault: letzten Log-Eintrag finden (neuestes File in allen `logs/` Ordnern)
- Vault: `00-eingang/unverarbeitet/` → Anzahl unverarbeiteter Items

---

## Schritt 3 — Präsentieren

Scanbares Format, nicht über-strukturieren:

```
Heute ist [Wochentag], [Datum].

**Kalender:**
- [Uhrzeit] [Event]
- ...

**Offene Aufgaben:** [Anzahl gesamt]
- [Projekt]: [Task 1], [Task 2]
- [Projekt]: [Task 3]
(max 10, priorisiert nach Fälligkeit)

**Letzte Session:** [Datum] — [Projekt]: [was gemacht]

**Eingang:** [X] unverarbeitete Items
```

---

## Schritt 4 — Fragen

Zwei separate Kapazitäts-Fragen, nacheinander:

1. "Wie ist deine Energie heute? (1-10, kognitive Fitness)"
2. "Wie viel Zeit-Kapazität hast du? (1-10, Luft für neue Themen)"
3. "Neue Themen oder was geändert seit letztem Mal?"
4. "Was willst du heute angehen?"

**Energie-Skala:**
- 1-2: erschöpft, krank, emotional belastet
- 3-4: unterdurchschnittlich, wenig Fokus-Bandbreite
- 5-6: normal
- 7-8: fit, gut drauf
- 9-10: Peak

**Zeit-Skala:**
- 1-2: Kalender brechend voll, keine Minute frei
- 3-4: getaktet, nur kleine Lücken
- 5-6: gemischt
- 7-8: viel Luft
- 9-10: frei

---

## Schritt 5 — Verarbeiten

Nach Antworten:
- Beide Kapazitäts-Werte plus Notiz in Daily Note Frontmatter schreiben
- Fokus-Projekte in Daily Note setzen
- Priorisierte Tasks in Google Tasks eintragen (falls MCP verfügbar)
- Time-Blocks in Calendar erstellen wenn Deniz das will

---

## Regeln

- Nicht zu viel quatschen. Sachlich, scanbar.
- **Energie niedrig (< 5):** nur niedrig-kapazitäts-Tasks vorschlagen (Admin, Dump, Sortieren)
- **Zeit niedrig (< 5):** keine neuen Themen vorschlagen. Bei laufenden Projekten unterstützen.
- **Beides hoch (≥ 7):** Deep-Work-Sessions anbieten.
- **Beides niedrig (< 5):** Pause empfehlen, maximal Admin.
- Inbox voll (5+ Items) → aktiv darauf hinweisen: "Du hast X unverarbeitete Sachen in der Inbox."
- Letzter Log älter als 3 Tage → hinweisen.
- Thesis-Deadline (2026-06-15) immer im Hinterkopf. Bei Energie ≥ 7 **und** Zeit ≥ 5 aktiv Thesis-Progress vorschlagen wenn nicht explizit anderes Fokus-Projekt genannt.
