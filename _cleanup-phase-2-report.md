---
typ: cleanup-report
datum: 2026-04-25
phase: 2
---

# Phase 2 Cleanup Report

## Statistik

| Metrik | Wert |
|---|---|
| Neue Kontakt-Files angelegt | 4 |
| Bestehende Files geändert | 10 |
| Neue Wikilinks gesetzt | ~12 |
| Cora-Wikilink-Fixes | 2 |
| Commits | 5 |

**Commits:**
- `477f530` — kontakte angelegt (4 neue Files + Maddox-Update)
- `6825539` — maddox-familie verknüpft (heiraten-daenemark, bellavie)
- `5739f75` — cora-wikilinks gefixt
- `e6bf9f2` — kaufmann-verlinkung hdwm
- (Final-Commit folgt)

---

## Neue Kontakt-Files

| File | Name | Rolle |
|---|---|---|
| `03-kontakte/hans-ruediger-kaufmann.md` | Hans-Rüdiger Kaufmann | Professor HdWM, International Sales |
| `03-kontakte/andrij-yakymenskyy.md` | Andreiy Yakymenskyy | Vater von Maddox |
| `03-kontakte/natalia-yakymenskyy.md` | Natalia Yakymenskyy | Mutter von Maddox |
| `03-kontakte/igor-puzynya.md` | Igor Puzynya | Familienfreund Yakymenskyys, Mail-Bearbeiter |

---

## Ungeklärter Fall — Manuelles Review nötig

### Widerspruch: Eltern vs. Geschwister in Maddox-File

**Problem:** Das bestehende `maddox-yakymenskyy.md` hat in `notizen`:
> "2 Geschwister: Natalia, Andrej."

Die Phase-2-Instruktion definiert aber:
- Andrij Yakymenskyy = **Vater** von Maddox
- Natalia Yakymenskyy = **Mutter** von Maddox

Das ist ein direkter Widerspruch. Die `notizen` des Maddox-Files wurden **nicht geändert**, da unklar ist ob die bestehende Notiz falsch ist (Migration aus Notion) oder ob Natalia und Andrej tatsächlich Geschwister sind und die Eltern andere Namen haben.

**Handlungsbedarf:** Deniz muss klären:
- Sind Natalia und Andrej die Eltern oder Geschwister von Maddox?
- Wenn Geschwister: Welche Namen haben die Eltern?
- Wenn Eltern: `notizen` in `maddox-yakymenskyy.md` anpassen von "2 Geschwister: Natalia, Andrej" zu "Eltern: Andrij und Natalia"

Bis zur Klärung bleiben die neuen Kontakt-Files mit Vater/Mutter-Rolle angelegt (entsprechend der Instruktion), aber die Maddox-Notiz ist noch inkonsistent.

---

## Konsistenz-Funde (während Phase 2 aufgefallen)

### Wikilinks in HdWM-Files

`international-sales-turnitin-bericht.md` hat keine vollständige Kaufmann-Namensnennung im Body — nur "Prof." ohne Namen. Kein Wikilink gesetzt (zu vage). Für Phase 3 prüfen ob eine Intro-Zeile mit Namen sinnvoll wäre.

### Igor in weiteren Files

`admin-hub-konzept.md` hat weitere Igor-Erwähnungen (Z.39, Z.149, Z.163, Z.95) — nur die erste "erste Erwähnung" wurde verlinkt. Folge-Erwähnungen bleiben ohne Link, konsistent mit der Phase-2-Regel.

`email-assistent-konzept.md` Z.113, Z.139 haben weitere Igor-Erwähnungen ohne Link — ebenfalls absichtlich nur Ersterwähnung verlinkt.

### `[[pulse-slack-schreibstil]]` — noch immer toter Link

Wurde in Phase 1 identifiziert. Dieser Wikilink in mehreren Slack-Files zeigt auf ein nicht existierendes File. Für Phase 3 entweder File anlegen oder Link entfernen.

### `[[cora-ai-architektur]]` und `[[cora-diskrepanzen]]` gefixt

Beide Wikilinks zeigen jetzt auf die tatsächlich existierenden Files `[[architektur]]` und `[[diskrepanzen]]` in `01-projekte/coralate/cora-ai/`. Für Phase 3: Überlegung ob die Dateien selbst umbenannt werden sollen (cora-ai-architektur.md etc.) um Verwechslung mit anderen architektur.md zu vermeiden.

### `03-kontakte/eris-osmani-wiedmeier.md`

Frontmatter hat `quelle: gespräch_2026-04-22` (nach Phase-1-Schema-Fix). Dieses ist jetzt im richtigen Format `gespräch_` statt `gespraech_`.

---

## Nicht in Scope (für Phase 3 dokumentiert)

- Dateinamen-Umbenennungen (z.B. architektur.md → cora-ai-architektur.md)
- Restliche tote Wikilinks (pulse-slack-schreibstil, zukunftsausblick, etc.)
- Frontmatter-Schema-Erweiterungen
- Alle weiteren neuen Kontakt-Files außer den 4 explizit genannten
