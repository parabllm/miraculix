---
name: miraculix-eingang-verarbeiten
description: |-
  Triggered whenever Deniz says "eingang verarbeiten", "digest", "inbox sortieren", "sortier das ein", "digest die inbox", or pastes content into the chat with instructions to categorize/sort it.

  Scans 00-vault-mcp-eingang/ (Mobile-Artefakte) FIRST, then all four subfolders of 00-eingang/ (audio/, transkripte/, chat-exports/, unverarbeitet/). MCP-Artefakte werden via Merge-Logik in echten Vault eingebaut. Standard-Eingang routet Audio zu miraculix-audio-verarbeiten, Transkripte zu miraculix-transkript-verarbeiten, Rest durch Triage.

  Shows a plan before executing.
---
# Eingang-Verarbeiten (Digest)

Zwei Eingänge in Reihenfolge: MCP-Eingang (Mobile-Artefakte) zuerst, dann klassischer 00-eingang/.

## Schritt 0 - Eingang-Status

Scanne beide Eingänge und reporte was vorhanden ist:

```
[Eingang-Status]
- 00-vault-mcp-eingang/:    2 Artefakte (von Mobile)
- 00-eingang/audio/:         1 File (kalani-call-2026-04-25.m4a)
- 00-eingang/transkripte/:   0 Files
- 00-eingang/chat-exports/:  2 Files
- 00-eingang/unverarbeitet/: 5 Files
```

Ignoriere `.gitkeep`, `README.md`, `.stfolder/` Files. Zähle nur tatsächliche Inhalte.

## Routing

Je nach Inhalt:

| Quelle | Aktion |
|---|---|
| `00-vault-mcp-eingang/` mit Artefakten | MCP-Merge-Logik (siehe Sektion "MCP-Eingang Merge" unten) |
| `00-eingang/audio/` | Skill `miraculix-audio-verarbeiten` aufrufen |
| `00-eingang/transkripte/` mit `status: unverarbeitet` | Skill `miraculix-transkript-verarbeiten` aufrufen |
| `00-eingang/chat-exports/` | Bestehende Triage-Logik (Schritt 1-5 unten) |
| `00-eingang/unverarbeitet/` | Bestehende Triage-Logik (Schritt 1-5 unten) |

**Reihenfolge** wenn mehrere Eingänge nicht leer:
1. MCP-Eingang zuerst (Artefakte sind strukturierter und können neue Wikilinks erzeugen, die andere Items brauchen)
2. Audio (erzeugt Transkripte)
3. Transkripte
4. Standard-Items (chat-exports + unverarbeitet)

Plan zeigen, OK abwarten, dann ausführen.

Falls beide Eingänge leer:

> Eingang ist leer. Nichts zu verarbeiten.

---

## MCP-Eingang Merge (Mobile-Artefakte einbauen)

Im Ordner `00-vault-mcp-eingang/` liegen Artefakte die Mobile-Claude erzeugt hat. Sie haben einen Verarbeitungs-Header mit Ziel-Pfad, Aktion, Hashes. Aufgabe von PC-Claude: validieren, Dry-Run zeigen, mergen, archivieren.

Volle Spec: `02-wissen/vault-mcp-architektur.md`. Diese Sektion ist die operative Kurzform.

### M.1 - Artefakt-Liste durchgehen

Listet alle `.md`-Files in `00-vault-mcp-eingang/` außer `README.md`. Sortiert nach mtime aufsteigend (älteste zuerst).

Pro Artefakt einzeln verarbeiten - nicht batchen.

### M.2 - Artefakt parsen

```
Header (YAML zwischen den ersten beiden ---)
Body (alles darunter, eventuell mit "<!-- ALLES UNTER ... -->" Marker)
```

Header-Pflichtfelder prüfen:
- `typ: vault-mcp-artefakt`
- `erstellt`, `quelle_geraet`, `quelle_konversation`
- `ziel_pfad`, `ziel_aktion` (`neue-datei` | `ergaenzung` | `ersetzen-sektion`)
- `idempotenz_key`
- `body_sha256`
- `status: bereit-zum-mergen`

Bei `ergaenzung` und `ersetzen-sektion` zusätzlich: `basis_mtime`, `basis_sha256`, `ziel_sektion`, `ziel_heading_ebene`.

Wenn Pflichtfelder fehlen: Artefakt überspringen, Bericht für Deniz, nicht mergen.

### M.3 - Plausibilitäts-Check

Pro Artefakt 13 Checks:

1. Header vollständig (siehe M.2)
2. Body-Hash neu berechnen, gegen `body_sha256` matchen
3. `ziel_pfad` ist relativ, normalisiert, in erlaubter Write-Zone (nicht `_api/`, nicht `.git/`, nicht `.claude/`, nicht `_meta/`, nicht `CLAUDE.md`, nicht `_migration/`, nicht `00-vault-mcp-eingang/`)
4. Bei `neue-datei`: Zielpfad existiert noch NICHT
5. Bei `ergaenzung`/`ersetzen-sektion`: Zielpfad existiert
6. Bei existierendem Ziel: aktuellen Datei-Hash bilden, gegen `basis_sha256` matchen (Race-Condition-Check)
7. Ziel-Sektion existiert genau einmal in Zieldatei (bei `ergaenzung`/`ersetzen-sektion`)
8. Wikilinks im Body zeigen auf existierende Dateien
9. Keine leeren oder kaputten Wikilinks
10. Keine em-dashes oder en-dashes im Body
11. UTF-8 ohne BOM
12. Body verletzt keine Vault-Schreibregeln (siehe `02-wissen/vault-schreibregeln.md`, `02-wissen/vault-schreibkonventionen.md`)
13. Bei Verlinkungs-Anweisungen: Quell-Files existieren, Sektionen existieren

Bei jedem Fehlschlag: Merge stoppen, Detail melden, nicht raten.

### M.4 - Dry-Run zeigen

Pro Artefakt vor dem Merge:

```
[MCP-Artefakt 1/2]
File:     2026-04-29-1530-pulse-status-update-ergaenzung.md
Aktion:   ergaenzung
Ziel:     01-projekte/pulsepeptides/pulsepeptides.md
Sektion:  "Aktuelle Kommunikation" (Heading-Ebene 2)
Position: ende-der-sektion
Risiken:  keine
Diff:
  + ### 2026-04-29 Mandak Updated Calculation
  +
  + Mandak meldet sich nach Mail-Versand 28.04. Will Donnerstag Termin
  + fuer Pricing-Review. Updated Calculation kommt vorher.

OK zum Mergen?
```

Bei Risiken (Race Condition, fehlende Wikilinks, doppelte Sektionen) - Detail mit Vorschlag wie gelöst werden kann. Nicht automatisch entscheiden.

### M.5 - Merge ausführen

Nach OK:

- **`neue-datei`**: Datei am `ziel_pfad` anlegen. Verarbeitungs-Header entfernen, nur Body als File-Inhalt schreiben. Wenn `verlinkungen_einbauen` gesetzt: zusätzlich die genannten Quell-Files updaten (jeweils als eigene `ergaenzung` behandeln).
- **`ergaenzung`**: Body in `ziel_sektion` der Zieldatei einfügen, `einfuege_position` beachten (default `ende-der-sektion`).
- **`ersetzen-sektion`**: Vor dem Schreiben Backup der Zieldatei nach `_claude/scripts/vault-mcp-merge-backups/YYYY-MM-DD/`. Dann Sektion komplett ersetzen mit Body-Inhalt.

Schreib-Methode: nach `02-wissen/vault-schreibregeln.md`. Filesystem-MCP `edit_file` oder PowerShell `WriteAllBytes`. Hex-Verify nach jedem Write Pflicht (erste 8 Bytes `2D 2D 2D 0A` plus YAML-Key, NICHT `2D 2D 2D 0A 0A 23 23` Pattern A).

### M.6 - Artefakt archivieren

Nach erfolgreichem Merge:

- Artefakt-Datei verschieben nach `05-archiv/vault-mcp-eingang-verarbeitet/YYYY-MM/{filename}`.
- Ordner-Struktur bei Bedarf anlegen.
- Dateiname behalten (nicht umbenennen).
- Kurzer Bericht: "Artefakt X gemerged in Y, archiviert in Z."

### M.7 - Konfliktfälle

| Konflikt | Aktion |
|---|---|
| `basis_sha256` matcht nicht | Merge stoppen, Artefakt + aktuellen Zielzustand zeigen, Deniz entscheidet (übernehmen / verwerfen / manuell mergen) |
| Wikilink-Target fehlt | Merge stoppen, fehlende Targets listen, Vorschlag (Link entfernen / Target ändern / neue Datei zuerst anlegen) |
| Ziel-Sektion mehrfach in Zieldatei | Merge stoppen, Kandidaten mit Kontext zeigen, nicht raten |
| Header korrupt / Pflichtfeld fehlt | Artefakt überspringen, in Bericht melden |
| Artefakt > 7 Tage alt | Warnung im Bericht, trotzdem anbieten zu mergen |

### M.8 - Roter Faden

- Nie auto-mergen. Immer Dry-Run plus OK.
- Backup vor `ersetzen-sektion` und Multi-File-Verlinkungen.
- Verarbeitungs-Header wird beim Merge entfernt - landet nicht in der echten Vault-Datei.
- Wenn ein Artefakt nicht mergebar ist: liegen lassen, Bericht, weiter zum nächsten.

---

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
