---
typ: cleanup-report
datum: 2026-04-24
phase: 1
---

# Phase 1 Cleanup Report

## Statistik (Stand: FINAL)

| Metrik | Wert |
|---|---|
| Gescannte Dateien (gesamt) | 253 |
| Davon mit Änderungen | ~170 |
| Umlaut-Ersetzungen (Prosa) | ~350 |
| Gedankenstrich-Ersetzungen | ~110 |
| CEMEA-Korrekturen | 1 (Simea→CEMEA in hays.md) |
| Schema-Enum-Korrekturen | 78 (bestaetigt→bestätigt etc.) |
| Ungeklärte Fälle | 3 |
| Konsistenz-Funde | 7 |

**Batch 1** (Commit `7d3abf3`): `04-tagebuch/`, `03-kontakte/` — 4 geändert
**Batch 2** (Commit `f591681`): HdWM, HeroSoftware, Slack-Files — 20 geändert
**Batch 3** (Commit `b1edb95`): CEMEA-Fix hays.md, PulsePeptides, Slack-Rest — 10 geändert
**Batch 4** (Commit `cffc4bb`): Coralate, Bachelor, Pulse, Thalor, HDwM-Rest, Skills — 63 geändert
**Schema** (Commit `d0ea3ca`): `vertrauen: bestätigt`, `status: abgelöst`, `quelle: gespräch_*` — 26 geändert

**Geänderte Files Batch 1:**
- `04-tagebuch/2026/04/2026-04-17.md` - 3 Umlaut
- `04-tagebuch/2026/04/2026-04-21.md` - 17 Umlaut
- `03-kontakte/calvin-blick.md` - 13 Umlaut
- `03-kontakte/martin-herd.md` - 8 Umlaut

**Geänderte Files Batch 2:**
- `hdwm/semester-5/meeting-kaufmann-2026-04-21.md` - 4 Dash + 10 Umlaut
- `hdwm/semester-5/email-kaufmann-ki-vorwurf.md` - 2 Dash + 5 Umlaut
- `hdwm/semester-5/international-sales-seminararbeit.md` - 1 Dash + 4 Umlaut
- `hdwm/semester-5/international-sales-turnitin-bericht.md` - 3 Dash + 2 Umlaut
- `hdwm/semester-5/international-sales.md` - 3 Dash
- `hdwm/semester-6/innovationsmanagement.md` - 1 Dash
- `hdwm/semester-6/it-systeme.md` - 1 Dash (En-Dash)
- `hdwm/semester-6/semester-6.md` - 6 Dash
- `hdwm/semester-5/semester-5.md` - 3 Dash
- `thalor/herosoftware/logs/2026-04-21-martin-call.md` - ~25 Umlaut
- `thalor/herosoftware/digitalocean-droplet.md` - 7 Umlaut
- `thalor/herosoftware/herosoftware.md` - 8 Umlaut
- `thalor/herosoftware/hetzner-setup.md` - 4 Umlaut
- `bachelor-thesis/logs/2026-04-17-call-christine-thesis.md` - 1 Dash
- `persönlich/kommunikation-referenzen/slack/*.md` (6 Files) - je 2-5 Dash

---

## Ungeklärte Fälle zum Klären

### Umlaut-Zweifel

| Datei | Zeile | Wort | Kontext | Überlegung |
|---|---|---|---|---|
| `03-kontakte/calvin-blick.md` | 19 | `lauft → läuft` | "auch wenn operativ primär Robin läuft" | `au` → `äu` ist kein Standard-ASCII-Muster (nicht ae/oe/ue). Im Kontext mit primaer (gleicher Satz, klar ASCII) war es eindeutig — habe es geändert. **Falls falsch: rückgängig machen.** |

### Simea in hays.md — KORRIGIERT (nach Rückfrage)

`hays.md` Z.23: `Simea` war eine Halluzination für CEMEA. Wurde korrigiert zu `CEMEA (Anfragen laufen über die Region)`.

Alle anderen SEMEA/Simea/Semea-Vorkommen im Vault: keine weiteren gefunden.

### Frontmatter-Enum-Werte (bewusst NICHT geändert)

Diese Werte enthalten ae-Muster, sind aber unquotierte Schema-Enums — laut Regel außerhalb des Scope:

- `vertrauen: bestaetigt` — in 23 Kontakte-Files. Schema-definierter Enum-Wert. **Frage: soll `bestaetigt` → `bestätigt` in diesen Werten geändert werden?** Das würde Obsidian-Queries und andere Schema-Consumer brechen, wenn sie den Wert als String matchen. Empfehlung: NEIN, nur nach expliziter Entscheidung.

- `quelle: gespraech_2026-04-22` — in `eris-osmani-wiedmeier.md`. Unquotierter Identifier-Wert. Nicht geändert.

---

## Konsistenz-Funde

### Gebrochene Wikilinks

| Datei | Link | Problem |
|---|---|---|
| `04-tagebuch/2026/04/2026-04-22.md` Z.29 | `[[2026-04-23-kalani-lager-besuch]]` | File existiert nicht. Nur `05-archiv/2026-04-22-kalani-lager-besuch-VERSCHOBEN.md` vorhanden. |
| `04-tagebuch/2026/04/2026-04-23.md` Z.16 | `[[2026-04-23-kalani-lager-besuch]]` | Gleiche Lücke. |

### Duplikat-Section

| Datei | Problem |
|---|---|
| `04-tagebuch/2026/04/2026-04-17.md` | Zeilen 58 und 60: `## Tages-Review` doppelt vorhanden. Inhalt in Zeilen 62-85 (der zweite Block). |

### Frontmatter-Inkonsistenz

| Datei | Problem |
|---|---|
| `04-tagebuch/2026/04/2026-04-16.md` | Hat `kapazitaet: 8` (altes Schema-Feld). Ab 17.04 gilt `kapazitaet_energie` + `kapazitaet_zeit`. |
| `04-tagebuch/2026/04/2026-04-22.md` | Hat `kapazitaet: 7` (altes Schema). |
| `04-tagebuch/2026/04/2026-04-23.md` | Hat `kapazitaet: null` (altes Schema). |
| `04-tagebuch/2026/04/2026-04-24.md` | Hat `kapazitaet: 1` (altes Schema). |

4 von 8 Tagebuch-Files nutzen noch das alte `kapazitaet`-Feld. 4 nutzen `kapazitaet_energie` + `kapazitaet_zeit`. Die Tagebücher ab 17.04 sind migriert, die davor/parallel nicht.

---

## Ungeklärte Fälle — Manuelles Review nötig

### Intentionale Em-Dashes (bewusst NICHT ersetzt)

| Datei | Zeile | Inhalt | Grund |
|---|---|---|---|
| `_claude/skills/schreibstil.md` | 3 (frontmatter desc) | `responses — only to text` | Unquotierter YAML-Wert |
| `_claude/skills/schreibstil.md` | 23 | `n8n — und das ist das Problem` | Intentionales Falsch-Beispiel in Schreibstil-Guide |
| `_claude/skills/schreibstil.md` | 127 | `Em-Dash (—) und En-Dash (–)` | Benennt die Zeichen direkt (Meta-Referenz) |
| `_claude/skills/schreibstil.md` | 130 | `Mitarbeiterführung — Stäudner` | Intentionales Falsch-Beispiel |
| `02-wissen/n8n/debug-fix-patterns.md` | 71 | `Entfernt Sonderzeichen ™ ® © \| · — _` | `—` ist Teil der Liste zu entfernender Sonderzeichen (inhaltlich korrekt) |
| `01-projekte/pulsepeptides/firmenstruktur.md` | 64 | Code-Block-Inhalt | Im Geldfluss-Diagramm-Codeblock, korrekt geschützt |
| `01-projekte/pulsepeptides/pulsebot-workflows.md` | 87 | Code-Block-Inhalt | Im Workflow-Diagramm-Codeblock, korrekt geschützt |
| `_claude/skills/tages-start.md` | 28, 68 | Template-Inhalte | In YAML/Template-Codeblöcken, korrekt geschützt |
| `01-projekte/hdwm/semester-5/meeting-kaufmann-2026-04-21.md` | 8 | `ort: HdWM Mannheim — Hauptgebäude` | Unquotierter Frontmatter-Wert |

**Empfehlung für schreibstil.md:** Die intentionalen Em-Dash-Beispiele könnten durch Blockquote oder Code-Schreibweise ersetzt werden (`—` statt echtem Zeichen), wenn du Konsistenz willst. Kein zwingender Handlungsbedarf.

### ß/ss-Fälle die in Prose-Sweep nicht gecatcht wurden

Keiner identifiziert. Die Umlaut-Sweep-Patterns deckten alle bekannten ae/oe/ue/ss→ß-Muster ab.

## Konsistenz-Funde

### Gebrochene Wikilinks

| Datei | Link | Status |
|---|---|---|
| `04-tagebuch/2026/04/2026-04-22.md` Z.29 | `[[2026-04-23-kalani-lager-besuch]]` | File nicht vorhanden. Nur `05-archiv/2026-04-22-kalani-lager-besuch-VERSCHOBEN.md` existiert. |
| `04-tagebuch/2026/04/2026-04-23.md` Z.16 | `[[2026-04-23-kalani-lager-besuch]]` | Gleiche Lücke. |

### Frontmatter-Inkonsistenz kapazitaet-Schema

| Datei | Problem |
|---|---|
| `04-tagebuch/2026/04/2026-04-16.md` | `kapazitaet: 8` (altes Schema) |
| `04-tagebuch/2026/04/2026-04-22.md` | `kapazitaet: 7` (altes Schema) |
| `04-tagebuch/2026/04/2026-04-23.md` | `kapazitaet: null` (altes Schema) |
| `04-tagebuch/2026/04/2026-04-24.md` | `kapazitaet: 1` (altes Schema) |

4 von 8 Tagebuch-Files nutzen noch das alte einheitliche `kapazitaet`-Feld statt `kapazitaet_energie` + `kapazitaet_zeit`.

### Duplikat-Section

| Datei | Problem |
|---|---|
| `04-tagebuch/2026/04/2026-04-17.md` | `## Tages-Review` zweimal vorhanden (Zeilen 58 und 60). Inhalt im zweiten Block. |

### Fehlende Kontakte-Files (aufgefallen beim Lesen)

- `Igor` in `heiraten-daenemark.md` referenziert ohne Kontakt-File. Mail-Bearbeiter der Yakymenskyys.
- `[[hans-ruediger-kaufmann]]` wird in mehreren hdwm-Files referenziert — kein Kontakt-File in `03-kontakte/` vorhanden.
- `[[christian]]` (Pulse) wird in Slack-Files als Kontakt verlinkt, das File heißt aber `christian-pulse.md`. Wikilink-Mismatch.

### Tote Wikilinks weitere Funde

- `[[cora-diskrepanzen]]` in `meeting-2026-04-18-cora-ausrichtung.md` — Zieldatei heißt `diskrepanzen.md`, nicht `cora-diskrepanzen.md`
- `[[cora-ai-architektur]]` in `scope-jann-proposal.md` — Zieldatei heißt `architektur.md`
- `[[pulse-slack-schreibstil]]` in mehreren Slack-Files — kein solches File gefunden
- `[[zukunftsausblick]]` in `meeting-2026-04-18-cora-ausrichtung.md` — existiert nicht als File

## Simea-Korrektur-Übersicht (für Double-Check)

Nur eine Stelle hatte `Simea` als halluzinierten CEMEA-Ersatz:

| Datei | Zeile | Alt | Neu |
|---|---|---|---|
| `01-projekte/hays/hays.md` | 23 | `Simea (Anfragen laufen über sie)` | `CEMEA (Anfragen laufen über die Region)` |

Alle anderen SEMEA/Simea/Semea-Suchen im Vault: keine weiteren Treffer in Content-Files.
