---

name: miraculix-eingang-verarbeiten description: |- Triggered whenever Deniz says "eingang verarbeiten", "digest", "inbox sortieren", "sortier das ein", "digest die inbox", or pastes content into the chat with instructions to categorize/sort it.

Scans all four subfolders of 00-eingang/ (audio/, transkripte/, chat-exports/, unverarbeitet/), reports what is where, routes audio to miraculix-audio-verarbeiten, transcripts to miraculix-transkript-verarbeiten, and standard items through the existing triage logic.

## Shows a plan before executing. Processing order: audio first (generates transcripts), then transcripts, then standard items.

# Eingang-Verarbeiten (Digest)

Alle vier Eingang-Subfolders scannen, routen und verarbeiten.

## Schritt 0 - Eingang-Status

Scanne alle vier Subfolders und reporte was vorhanden ist:

```
[Eingang-Status]
- audio/:        1 File (kalani-call-2026-04-25.m4a)
- transkripte/:  0 Files
- chat-exports/: 2 Files
- unverarbeitet/: 5 Files
```

Ignoriere `.gitkeep` Files. Zähle nur tatsächliche Inhalte.

## Routing

Je nach Inhalt:

SubfolderInhalt vorhandenAktion`audio/`JaSkill `miraculix-audio-verarbeiten` aufrufen`transkripte/`Ja, mit `status: unverarbeitet`Skill `miraculix-transkript-verarbeiten` aufrufen`chat-exports/`JaBestehende Triage-Logik (Schritt 1-5 unten)`unverarbeitet/`JaBestehende Triage-Logik (Schritt 1-5 unten)

Reihenfolge wenn mehrere Subfolders nicht leer: Audio zuerst (erzeugt Transkripte), dann Transkripte, dann Standard-Items. Begründung: Audio-Processing liefert neue Transkripte die im selben Durchlauf noch verarbeitet werden können wenn Deniz das will.

Plan zeigen, OK abwarten, dann ausführen.

Falls alle Subfolders leer:

> Eingang ist leer. Nichts zu verarbeiten.

## Schritt 1 - Inbox lesen (Standard-Items)

Alle Files in `00-eingang/unverarbeitet/` mit `status: unverarbeitet`. Auch: wenn Deniz content in Chat paste'd + "sortier das ein" → als Inbox-Item behandeln. Chat-Exports aus `00-eingang/chat-exports/` werden hier mitverarbeitet.

## Schritt 2 - Pro Item klassifizieren

**a) Termin mit Uhrzeit?** → Google Calendar Event, Kontakte matchen, Projekt zuordnen. **b) Aufgabe ohne Uhrzeit?** → Task im Vault (Checkbox oder eigenes File). **c) Meeting-Transkript?** → Meeting-File in `meetings/` des Projekts. **d) Kontext-Update?** → Bestehendes File updaten, NICHT neues erstellen. **e) Dokument?** → In `_anhaenge/{bereich}/`, Companion-Markdown. **f) Unklar?** → In Inbox mit AMBIG\_-Prefix.

## Schritt 3 - Entity-Matching

Für jeden Namen / Projektbezug:

1. `03-kontakte/*.md` Aliase prüfen
2. `01-projekte/**/*.md` Aliase prüfen
3. Bei Match → Wikilink + Frontmatter-Relation
4. Bei Unsicherheit → fragen

## Schritt 4 - Plan zeigen

```
**Item 1:** "Morgen Paddle mit Maddox 10:00"
→ Google Calendar Event, morgen 10:00-11:30, [[maddox-yakymenskyy]]

**Item 2:** "HeroSoftware WF4 Webhook-Fix: Domain-Match war das Problem"
→ Log in [[herosoftware/logs/2026-04-16-wf4-fix]]
→ 2. Auftreten - Wissens-Eintrag `02-wissen/n8n/webhook-race-condition.md`?
```

## Schritt 5 - Ausführen

Nach OK: alles gebündelt.

- Vault-Files erstellen/updaten
- Calendar Events (falls MCP)
- Inbox-Items auf `verarbeitet` setzen
- **Dokumente (PDF, PPTX, XLSX etc.):** physisch nach `_anhaenge/{bereich}/` verschieben, danach aus `unverarbeitet/` löscht sich die Quelle damit selbst

## Regeln

- **Nie automatisch.** Erst Plan, dann OK.
- **Ein Voice-Dump = viele Fragmente.** Zerlegen.
- **Duplikat-Check** via Aliase.
- **Kontext-Updates statt neue Files.**
- **Transkripte:** `ist_transkript: true`, Teilnehmer + offene Punkte extrahieren.
- **Unbekannte Personen:** fragen.
- **Nicht-klassifizierbares:** AMBIG\_-Prefix, nicht raten.

## Vault-Writes

Vor jedem .md-Write Pflicht-Lektuere:

- [[vault-schreibkonventionen]] - WAS rein (Encoding, Umlaute, Naming, Gedankenstriche)
- [[vault-schreibregeln]] - WIE schreiben (Tools, Rollback, Bug-Patterns)

Kernregeln:

- NIE Desktop Commander `write_file` oder `edit_block` fuer .md mit YAML-Frontmatter
- Hex-Verify Pflicht nach jedem Write (erste 8 Bytes muessen `2D 2D 2D 0A` plus YAML-Key sein)
