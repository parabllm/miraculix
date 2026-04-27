---
name: miraculix-transkript-verarbeiten
description: Triggered when Deniz says "transkript verarbeiten", "triag transkript", "ordne transkript ein", or when called from miraculix-eingang-verarbeiten or miraculix-audio-verarbeiten. Reads transcripts in 00-eingang/transkripte/, summarizes for Deniz, asks where to file each, finds and updates the relevant meeting note with key insights, optionally cross-checks meeting note vs transcript for task-status changes and new topics. After processing, moves transcript from 00-eingang/transkripte/ to _anhaenge/transkripte/ (gitignored).
---

# Transkript-Verarbeiten

Transkripte aus Eingang zusammenfassen, einsortieren und Meeting-Notes aktualisieren.

## Trigger

- Deniz sagt "transkript verarbeiten", "triag transkript", "ordne transkript ein"
- Aufruf aus `miraculix-audio-verarbeiten` nach Transkription
- Aufruf aus `miraculix-eingang-verarbeiten` wenn Transkripte in `00-eingang/transkripte/` gefunden wurden

## Voraussetzungen

- `00-eingang/transkripte/` existiert
- `_anhaenge/transkripte/` existiert (hat `.gitkeep`)

## Schritte

### Schritt 1 - Transkripte prüfen

Liste alle Files in `00-eingang/transkripte/` mit Frontmatter `status: unverarbeitet`.

Falls keine unverarbeiteten Transkripte:
> Keine Transkripte zu verarbeiten.

Skill beendet.

Falls vorhanden: zeige Liste mit Slug und Datum.

```
[Transkripte zur Verarbeitung]
1. kalani-call-2026-04-25.md (28:14, 2 Sprecher, en)
2. standup-herosoftware-2026-04-25.md (12:03, 3 Sprecher, de)
```

### Schritt 2 - Pro Transkript: Zusammenfassung

Lese Transkript-File komplett.

Erstelle 5-10 Bullet-Zusammenfassung mit Fokus auf:
- Wer hat mit wem gesprochen (Speaker-Mapping wenn erkennbar, sonst generisch lassen)
- Hauptthemen des Gesprächs
- Entscheidungen die getroffen wurden
- Offene Punkte und erkennbare Tasks

Zeige Bullets an Deniz. Beispiel:

```
[Zusammenfassung] kalani-call-2026-04-25

- Gespraech: 2 Sprecher, ca. 28 Min, Englisch
- Thema: USA-Expansion Strategie fuer BellaVie
- Entscheidung: USA-Shipments ueber Reshipper, kein Direktversand
- Entscheidung: Bulk-Pricing erst ab Q3 einführen
- Task: Kalani schickt Reshipper-Vergleich bis Freitag
- Task: Deniz prüft Zoll-Anforderungen für Florida
- Offene Frage: Lager-Visit im Mai realistisch?
```

Speaker-Mapping ist nicht Pflicht. Kernerkenntnisse lassen sich auch ohne explizites Mapping (speaker_0 = Deniz, speaker_1 = Kalani) destillieren, weil Deniz beim Lesen erkennt was er gesagt hat.

### Schritt 3 - Zieldatei abfragen

Frage Deniz:

> Wo soll das hin? Existierende Meeting-Note (Pfad oder Name nennen) oder neue Datei anlegen? Welches Projekt?

Wenn Deniz Meeting-Note nennt:
- Suche im Vault nach dem Namen (primär im Projekt-Ordner, sekundär global)
- Bei mehreren Treffern: Liste anzeigen, Deniz wählen lassen
- Bei keinem Treffer: nochmal nach exaktem Pfad fragen

Bestätigung einholen:

> Ist das die richtige Datei: `[[pfad/zur/meeting-note.md]]`?

Erst nach OK weitermachen.

### Schritt 4 - Meeting-Note erweitern

Vor dem Schreiben: Lade `_claude/skills/schreibstil.md` und scanne den Text gegen die 10 Regeln.

Füge folgende Sektion an die Meeting-Note an (am Ende, als neuer Abschnitt):

```markdown
## Kernerkenntnisse aus Transkript

- Datum: YYYY-MM-DD
- Audio: [[_anhaenge/audio-files/{slug}.mp3]]
- Roh-Transkript: [[_anhaenge/transkripte/{slug}.md]]

### Erkenntnisse

- {erkenntnis 1}
- {erkenntnis 2}
- {erkenntnis 3}
[weitere nach Bedarf]
```

Regeln für die Erkenntnisse:
- Aktiv statt passiv
- Keine Promo-Sprache, keine Wichtigkeits-Inflation
- Entscheidungen klar als Entscheidungen kennzeichnen
- Tasks mit Verantwortlichem wenn erkennbar

### Schritt 5 - Cross-Check (optional)

Frage Deniz:

> Cross-Check machen: Meeting-Note vs Transkript vergleichen auf abgehakte Tasks, neue Themen, neue Entscheidungen?

Bei Nein: weiter zu Schritt 6.

Bei Ja:
- Lade `_claude/skills/schreibstil.md`
- Lade Meeting-Note komplett
- Lade Projekt-Hauptfile (`{projekt}/{slug}.md`)
- Lade letzten 1-2 Logs aus `{projekt}/logs/` für Kontext

Vergleiche Transkript mit Meeting-Note auf drei Punkte:
1. Tasks in Meeting-Note: welche im Transkript als erledigt erwähnt?
2. Neue Themen: was im Transkript besprochen aber nicht vorab in Note notiert?
3. Neue Entscheidungen: was im Transkript entschieden aber nicht dokumentiert?

Reporte Diff strukturiert:

```
[Diff] Meeting-Note vs Transkript:
- Tasks abhakbar (2): "Reshipper-Vergleich", "Zoll-Anforderungen Florida"
- Neue Themen (1): "Lager-Visit Mai"
- Neue Entscheidungen (1): "USA-Shipments via Reshipper, kein Direktversand"
```

Pro Diff-Punkt fragen: "Übernehmen, ignorieren oder anders einsortieren?"

Bei Übernahme: Plan zeigen (welche Files geändert werden), OK abwarten, dann schreiben.

### Schritt 6 - Transkript archivieren

Plan zeigen vor der Multi-File-Operation:

```
[Plan]
1. Meeting-Note erweitern: {pfad}
2. Transkript verschieben: 00-eingang/transkripte/{slug}.md -> _anhaenge/transkripte/{slug}.md
3. Frontmatter im archivierten Transkript updaten: status: verarbeitet, verarbeitet_am: YYYY-MM-DD
```

Nach OK ausführen:
1. Verschiebe `00-eingang/transkripte/{slug}.md` nach `_anhaenge/transkripte/{slug}.md` (move, kein copy)
2. Setze im verschobenen File Frontmatter `status: verarbeitet` und `verarbeitet_am: YYYY-MM-DD`

Bestätige an Deniz:

```
[Verarbeitet]
- Meeting-Note aktualisiert: {pfad}
- Transkript archiviert: _anhaenge/transkripte/{slug}.md
```

## Regeln

- Plan zeigen vor jeder Multi-File-Operation. Meeting-Note Update plus Transkript-Move = Multi-File.
- Schreibstil-Skill bei jedem Schreiben in Vault-Files laden und Regeln anwenden.
- Kein Auto-Chain, immer Deniz fragen.
- Bei Unsicherheit über Meeting-Note-Zuordnung: fragen statt raten.
- Speaker-Mapping ist nicht Pflicht für Kernerkenntnisse.
- Transkripte nie löschen, nur verschieben nach `_anhaenge/transkripte/`.
- Wenn keine passende Meeting-Note existiert: fragen ob neue erstellt werden soll, Pfad von Deniz erfragen.

## Vault-Writes

Vor jedem .md-Write Pflicht-Lektuere:
- [[vault-schreibkonventionen]] - WAS rein (Encoding, Umlaute, Naming, Gedankenstriche)
- [[vault-schreibregeln]] - WIE schreiben (Tools, Rollback, Bug-Patterns)

Kernregeln:
- NIE Desktop Commander `write_file` oder `edit_block` fuer .md mit YAML-Frontmatter
- Hex-Verify Pflicht nach jedem Write (erste 8 Bytes muessen `2D 2D 2D 0A` plus YAML-Key sein)
