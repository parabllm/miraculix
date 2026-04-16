---
name: miraculix-eingang-verarbeiten
description: Triggered whenever Deniz says "eingang verarbeiten", "digest", "inbox sortieren", "sortier das ein", "digest die inbox", or pastes content into the chat with instructions to categorize/sort it. Use this skill to read all unprocessed items in 00-eingang/, classify each one (appointment/task/meeting/context-update/document/unknown), match entities against existing contacts and projects, show a plan to Deniz, wait for OK, then bundle-write to the correct vault locations. This is the main digestion mechanism for voice dumps, transcripts, chat exports and random inputs.
---

# Eingang-Verarbeiten (Digest)

Inbox klassifizieren, einsortieren, bundled schreiben.

## Schritt 1 — Inbox lesen

Alle Files in `00-eingang/unverarbeitet/` mit `status: unverarbeitet`.
Auch: wenn Deniz content in Chat paste'd + "sortier das ein" → als Inbox-Item behandeln.

## Schritt 2 — Pro Item klassifizieren

**a) Termin mit Uhrzeit?** → Google Calendar Event, Kontakte matchen, Projekt zuordnen.
**b) Aufgabe ohne Uhrzeit?** → Task im Vault (Checkbox oder eigenes File).
**c) Meeting-Transkript?** → Meeting-File in `meetings/` des Projekts.
**d) Kontext-Update?** → Bestehendes File updaten, NICHT neues erstellen.
**e) Dokument?** → In `_anhaenge/{bereich}/`, Companion-Markdown.
**f) Unklar?** → In Inbox mit AMBIG_-Prefix.

## Schritt 3 — Entity-Matching

Für jeden Namen / Projektbezug:
1. `03-kontakte/*.md` Aliase prüfen
2. `01-projekte/**/*.md` Aliase prüfen
3. Bei Match → Wikilink + Frontmatter-Relation
4. Bei Unsicherheit → fragen

## Schritt 4 — Plan zeigen

```
**Item 1:** "Morgen Paddle mit Maddox 10:00"
→ Google Calendar Event, morgen 10:00-11:30, [[maddox-yakymenskyy]]

**Item 2:** "HeroSoftware WF4 Webhook-Fix: Domain-Match war das Problem"
→ Log in [[herosoftware/logs/2026-04-16-wf4-fix]]
→ 2. Auftreten — Wissens-Eintrag `02-wissen/n8n/webhook-race-condition.md`?
```

## Schritt 5 — Ausführen

Nach OK: alles gebündelt.
- Vault-Files erstellen/updaten
- Calendar Events (falls MCP)
- Inbox-Items auf `verarbeitet` setzen

## Regeln

- **Nie automatisch.** Erst Plan, dann OK.
- **Ein Voice-Dump = viele Fragmente.** Zerlegen.
- **Duplikat-Check** via Aliase.
- **Kontext-Updates statt neue Files.**
- **Transkripte:** `ist_transkript: true`, Teilnehmer + offene Punkte extrahieren.
- **Unbekannte Personen:** fragen.
- **Nicht-klassifizierbares:** AMBIG_-Prefix, nicht raten.
