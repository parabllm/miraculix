---
typ: cleanup-report
datum: 2026-04-24
phase: 1
---

# Phase 1 Cleanup Report

## Statistik (Stand: nach Batch 2)

| Metrik | Wert |
|---|---|
| Gescannte Dateien (gesamt bisher) | ~130 |
| Davon mit Änderungen | 24 |
| Umlaut-Ersetzungen | ~110 |
| Gedankenstrich-Ersetzungen | ~55 |
| CEMEA-Korrekturen | 0 |
| Ungeklärte Fälle | 2 |
| Konsistenz-Funde | 5 |

**Batch 1:** `04-tagebuch/` (8 Files), `03-kontakte/` (44 Files) — 4 geändert
**Batch 2:** `01-projekte/hdwm/`, `01-projekte/thalor/herosoftware/`, `01-projekte/persönlich/kommunikation-referenzen/slack/` — 20 geändert

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

### Simea-Personenname vs. Region (Batch 2)

| Datei | Zeile | Fund | Entscheidung |
|---|---|---|---|
| `01-projekte/hays/hays.md` | 23 | `Simea (Anfragen laufen über sie)` | Personenname, KEIN Regions-Kürzel → nicht ersetzt. Bitte bestätigen. |

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

## Nächste Batches (geplant)

- **Batch 3:** `01-projekte/` Restordner (Coralate, Bachelor, Pulse, Thalor-Rest) — freie Fahrt
- **Batch 4:** `02-wissen/`, `_claude/skills/`, `05-archiv/`, Root-Level
- **Schema-Konsistenz:** Separater Lauf am Ende für `bestaetigt → bestätigt` etc.
