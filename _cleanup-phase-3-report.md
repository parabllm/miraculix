---
typ: cleanup-report
datum: 2026-04-25
phase: 3
---

# Phase 3 Cleanup Report

## Durchgeführte Änderungen

| Commit | Aktion |
|---|---|
| `c3dbbe3` | Kalani-Lager-Besuch umbenannt + Archiv-Regel in vault-system.md |
| `2de4802` | Tote Wikilinks gefixt: [[christian]]→[[christian-pulse]], [[pulse-slack-schreibstil]] entfernt, [[zukunftsausblick]] entfernt |
| `f7bbc32` | architektur.md → cora-ai-architektur.md, [[architektur]] in Coralate-Files aktualisiert |
| (dieser Commit) | Schreibkonventionen-Doku, Phase-3-Report |

---

## Archiv-Skill-Audit

**Befund:** Das `-VERSCHOBEN`-Suffix kommt aus **keinem aktuellen Skill-File**. Kein Skill enthält Logik zum Umbenennen bei Archivierung. Die Aktion war wahrscheinlich eine manuelle Ad-hoc-Intervention außerhalb des Skill-Systems.

Geprüfte Skill-Files: abgleich.md, drive-eingang-holen.md, eingang-verarbeiten.md, log.md, schreibstil.md, tages-start.md, vault-pruefung.md, vault-system.md, wissens-destillation.md, audio-verarbeiten.md, transkript-verarbeiten.md

- `transkript-verarbeiten.md` verschiebt Transkripte nach `_anhaenge/transkripte/` — aber **ohne Umbenenn-Logik**, Dateiname bleibt identisch. Korrekte Implementierung.
- `vault-system.md` "Was NIE tun" — jetzt ergänzt mit der Archivierungs-Regel.

**Neue Regel in vault-system.md** (Zeile in "Was NIE tun"):
> Dateinamen beim Archivieren oder Verschieben ändern. Beim Verschieben nach 05-archiv/ oder zwischen Ordnern bleibt der Dateiname exakt gleich. Status-Indikatoren ("verschoben", "archiviert", "alt") gehören ins Frontmatter (status: archiviert), niemals in den Dateinamen. Umbenennung bricht alle Wikilinks.

---

## Globaler Wikilink-Check

**42 tote Wikilinks gefunden.** Kategorisiert nach Ursache:

### Kategorie 1: Falsch-Positiv / Erwartete Platzhalter (kein Handlungsbedarf)

| Wikilink | Datei | Ursache |
|---|---|---|
| `[[{slug}]]`, `[[log1]]`, `[[log2]]`, `[[projekt-a]]` | Skill-Files | Beispiel-Platzhalter in Skill-Doku |
| `[[kontakt-slug]]` | vault-system.md, kommunikation-referenzen.md | Template-Beispiel |
| `[[pfad/zur/meeting-note.md]]`, `[[_anhaenge/...]]` | transkript-verarbeiten.md | Pfad-Beispiele in Skills |
| `[[herosoftware/logs/2026-04-16-wf4-fix]]` | eingang-verarbeiten.md | Skill-Beispiellink |
| `[[architektur]]`, `[[christian]]`, `[[cora-diskrepanzen]]`, `[[pulse-slack-schreibstil]]`, `[[zukunftsausblick]]` | Cleanup-Reports | Dokumentation von Phasen 1-3 (historische Referenz) |

### Kategorie 2: Voller Pfad-Wikilinks (Obsidian-Inkompatibel)

Obsidian löst Wikilinks über Dateinamen auf, nicht über vollständige Pfade.

| Wikilink | Datei | Hinweis |
|---|---|---|
| `[[01-projekte/coralate/food-scanner/logs/2026-04-13-pipeline-production-ready-doc62]]` | claude-workflow/continuity-doc-pattern.md | Datei existiert — nur Wikilink-Format falsch |
| `[[01-projekte/coralate/food-scanner/logs/2026-04-13-session-abschluss-doc62-auth-geloest]]` | claude-workflow/continuity-doc-pattern.md | Datei existiert — nur Format falsch |
| `[[01-projekte/coralate/logs/2026-04-07-cora-backend-build]]` | claude-workflow/continuity-doc-pattern.md | Datei existiert |
| `[[01-projekte/thalor/herosoftware/logs/2026-03-25-hetzner-setup-daily-sync]]` | n8n/webhook-timeout-hetzner-cron-pattern.md | Datei existiert |
| `[[01-projekte/thalor/herosoftware/logs/2026-03-26-clay-integration-templates-tier-system]]` | crm-integration/attio-match-kaskade.md | Datei existiert |
| `[[01-projekte/thalor/herosoftware/logs/2026-03-27-wf1-domain-match-create-fehler-fix]]` | crm-integration/attio-match-kaskade.md | Datei existiert |
| `[[01-projekte/thalor/herosoftware/logs/2026-04-13-production-ready-refactor-4-scripts]]` | n8n/webhook-timeout-hetzner-cron-pattern.md | Datei existiert |
| `[[01-projekte/thalor/pulsepeptides/logs/2026-03-19-pulse-restrukturierung]]` | integration/slack-3s-timeout-async-pattern.md | Datei existiert |
| `[[02-wissen/lexware/api-uebersicht]]` | heiraten-daenemark/admin-hub-konzept.md | Datei `api-uebersicht.md` existiert in 02-wissen/lexware/ |

**Empfehlung Phase 4:** In 02-wissen/ Wikilinks auf Kurzform umstellen (nur Dateiname, kein Pfad).

### Kategorie 3: Wirklich fehlende Zieldateien (manuelles Review nötig)

| Wikilink | Datei | Zeile | Vermutetes Problem |
|---|---|---|---|
| `[[gliederung]]` | bachelor-thesis/logs/2026-04-23-sandbrink-betreuung.md | ? | `gliederung-klartext.md` existiert — Wikilink sollte `[[gliederung-klartext]]` heißen |
| `[[scope]]` | bachelor-thesis/logs/2026-04-23-sandbrink-betreuung.md | ? | `scope-klartext.md` existiert — Wikilink sollte `[[scope-klartext]]` heißen |
| `[[pipeline-reset-2026-04-23]]` | bachelor-thesis/scope-klartext.md | ? | File nicht gefunden, vermutlich nie angelegt |
| `[[modulhandbuch-business-management]]` | hdwm/hdwm.md + hdwm/pruefungsordnung.md | ? | Kein Vault-File für Modulhandbuch — wahrscheinlich externes Dokument |
| `[[01-projekte/thalor/_projekt]]`, `[[01-projekte/thalor/resolvia/_projekt]]` | 02-wissen-Files | ? | `_projekt.md` Naming war alte Notion-Konvention. Zieldateien heißen jetzt ohne Präfix |
| `[[references]]` | 05-archiv/migration-abschluss.md | ? | Wahrscheinlich Section-Referenz im selben File |
| `[[...]]` | vault-schreibkonventionen.md | ? | Inline-Code-Block mit Beispielsyntax — kein echter Link (false positive) |
| `[[lab-peptides-pricelist-2026-01.pdf]]` | pulsepeptides/knowledge-base/lab-peptides.md | ? | PDF-Datei in _anhaenge, kein .md File |

---

## Schema-Konsistenz-Check

### Typen-Übersicht

| typ | Anzahl | Schema-Gesundheit |
|---|---|---|
| `log` | 60 | Gut — aber `werkzeuge` Feld (95%) fehlt in `_meta/schema.md`-Doku |
| `kontakt` | 45 | Exzellent — 100% auf allen Pflichtfeldern |
| `aufgabe` | 36 | Gut |
| `wissen` | 24 | Fragmentiert — viele optionale Felder haben <60% Coverage |
| `sub-projekt` | 19 | Gut |
| `kommunikation-thread` | 10 | Exzellent — 100% auf allen Feldern |
| `tagebuch` | 9 | Inkonsistenz: 5 Files nutzen `kapazitaet` (alt), 4 nutzen Split-Schema `kapazitaet_energie` + `kapazitaet_zeit` |
| `ueber-projekt` | 8 | Gut |
| `meeting` | 7 | OK — `projekt` und `zusammenfassung` fehlen je 1 File |
| `meeting-note` | 7 | OK |
| viele seltene Typen | je 1-2 | Einzelfälle, kein Handlungsbedarf |

### Auffälligkeiten

1. **`typ: meeting` vs `typ: meeting-note`**: Zwei separate Typen für Meeting-Dokumentation. Semantisch unklar: Wann meeting, wann meeting-note? Empfehlung: im Schema dokumentieren.

2. **`typ: tagebuch` kapazitaet-Schema**: Bekannt aus Phase 1. 4 Files nutzen `kapazitaet:` (alt), 4 nutzen das neue Split-Schema. Die 5. mit `kapazitaet:` ist `2026-04-24.md` die mit `kapazitaet: 1` einen Wert hat.

3. **`typ: wissen` Domain-Feld**: `domain` hat nur 62% Coverage. Einige Wissen-Files aus der Health-Sammlung (`augenringe.md`, `neurotransmitter-network.md` etc.) fehlt dieses Feld. Nicht kritisch aber inkonsistent.

4. **Datum-Schema in kontakt**: `zuletzt_aktualisiert` (22%) und `aktualisiert` (11%) existieren parallel — zwei verschiedene Feldnamen für denselben Zweck. Schema sollte das vereinheitlichen.

5. **`vertrauen: bestaetigt`** (ohne Umlaut): Noch in vault-system.md Z.135 als Beispieltext vorhanden. Kein Frontmatter-Wert, daher kein Problem für Schema-Validierung, aber inkonsistent mit dem Rest des Vaults.

---

## Schreibkonventionen-Doku

Neu angelegt: `02-wissen/vault-schreibkonventionen.md`

Enthält: Encoding-Regeln, Gedankenstrich-Verbot, Archivierungs-Regel, Konsistenz-Prinzipien.

---

## Offene Punkte (nicht in Phase 3 gefixt)

Folgende Punkte wurden dokumentiert aber NICHT gefixt da außerhalb des Phase-3-Scope:

- `[[gliederung]]` → sollte `[[gliederung-klartext]]` sein (bachelor-thesis Log)
- `[[scope]]` → sollte `[[scope-klartext]]` sein (bachelor-thesis Log)
- `[[pipeline-reset-2026-04-23]]` → File anlegen oder Link entfernen
- Voller-Pfad-Wikilinks in 02-wissen/-Files → auf Kurzform umstellen
- `kapazitaet`-Schema in alten Tagebuch-Files angleichen
- `meeting` vs `meeting-note` Typ-Konvention dokumentieren
- `zuletzt_aktualisiert` vs `aktualisiert` vereinheitlichen
- `werkzeuge` Feld in `typ: log` Schema dokumentieren
