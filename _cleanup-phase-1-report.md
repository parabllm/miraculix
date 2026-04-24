---
typ: cleanup-report
datum: 2026-04-24
phase: 1
---

# Phase 1 Cleanup Report

## Statistik (Stand: nach Batch 1)

| Metrik | Wert |
|---|---|
| Gescannte Dateien (gesamt bisher) | 52 |
| Davon mit Änderungen | 4 |
| Umlaut-Ersetzungen | 41 |
| Gedankenstrich-Ersetzungen | 0 |
| CEMEA-Korrekturen | 0 |
| Ungeklärte Fälle | 1 |
| Konsistenz-Funde | 4 |

**Verarbeitete Ordner:** `04-tagebuch/` (8 Files), `03-kontakte/` (44 Files)

**Geänderte Files:**
- `04-tagebuch/2026/04/2026-04-17.md` — 3 Umlaut-Ersetzungen
- `04-tagebuch/2026/04/2026-04-21.md` — 17 Umlaut-Ersetzungen
- `03-kontakte/calvin-blick.md` — 13 Umlaut-Ersetzungen
- `03-kontakte/martin-herd.md` — 8 Umlaut-Ersetzungen

---

## Ungeklärte Fälle zum Klären

### Umlaut-Zweifel

| Datei | Zeile | Wort | Kontext | Überlegung |
|---|---|---|---|---|
| `03-kontakte/calvin-blick.md` | 19 | `lauft → läuft` | "auch wenn operativ primär Robin läuft" | `au` → `äu` ist kein Standard-ASCII-Muster (nicht ae/oe/ue). Im Kontext mit primaer (gleicher Satz, klar ASCII) war es eindeutig — habe es geändert. **Falls falsch: rückgängig machen.** |

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

- **Batch 2:** `01-projekte/` (~170 Files) — nach Go-Signal
- **Batch 3:** `02-wissen/`, `_claude/skills/`, `05-archiv/`, Root-Level
