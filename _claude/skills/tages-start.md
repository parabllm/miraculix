# Tages-Start Skill

**Trigger:** "tages-start", "was steht an", "guten morgen", "daily start"

---

## Ablauf

### Schritt 1 — Daily Note erstellen
Prüfe ob `04-tagebuch/{jahr}/{monat}/{datum}.md` existiert. Wenn nein, erstelle mit leerem Template.

### Schritt 2 — Daten sammeln
- Google Calendar: alle Events für heute (via MCP)
- Google Tasks: alle Tasks mit Due heute
- Vault: offene Aufgaben aus `01-projekte/`
- Vault: letzten Log-Eintrag finden
- Vault: `00-eingang/` → Anzahl unverarbeiteter Items

### Schritt 3 — Präsentieren

```
Heute ist [Wochentag], [Datum].

**Kalender:**
- [Uhrzeit] [Event]

**Offene Aufgaben:** [Anzahl]
- [Projekt]: [Task 1], [Task 2]
(max 10, priorisiert nach Fälligkeit)

**Letzte Session:** [Datum] — [Projekt]: [was gemacht]

**Eingang:** [X] unverarbeitete Items
```

### Schritt 4 — Fragen (einzeln)
1. "Wie ist deine Kapazität heute? (1-10)"
2. "Neue Themen oder was geändert?"
3. "Was willst du heute angehen?"

### Schritt 5 — Verarbeiten
- Kapazität in Daily Note
- Priorisierte Tasks in Google Tasks
- Time-Blocks in Calendar wenn gewünscht
- Fokus-Projekte in Daily Note

---

## Regeln

- Nicht zu viel quatschen. Sachlich.
- Kapazität unter 5 → nur niedrig-kapazitäts-Tasks vorschlagen.
- Inbox voll (5+ Items) → aktiv hinweisen.
- Letzter Log älter als 3 Tage → hinweisen.
