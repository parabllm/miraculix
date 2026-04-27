---
typ: doku
name: Long-Notizen-Candidates fuer Body-Move
erstellt: 2026-04-27
kontext: V3-Hardening Aufgabe C, Migration FM >200 chars auf Block-Syntax
status: offen, Deniz entscheidet
---

# Long-Notizen-Candidates

Diese 10 Files haben `notizen:` mit > 300 chars. Wurden in V3-Migration auf
Block-Syntax `|-` umgestellt. Inhaltlich aber Kandidaten fuer Body-Move:
Notizen wandern in eine `## Notizen`-Sektion im Body, FM bleibt schlank.

Entscheidung pro File durch Deniz - kein Auto-Move.

## Liste (sortiert nach Laenge)

| Laenge | Pfad |
|---|---|
| 416 | `03-kontakte/rini-kodzadziku.md` |
| 411 | `03-kontakte/robin-kronshagen.md` |
| 381 | `03-kontakte/christine-kampmann.md` |
| 364 | `03-kontakte/lars-blum.md` |
| 340 | `03-kontakte/tim-stetter.md` |
| 334 | `03-kontakte/maddox-yakymenskyy.md` |
| 327 | `03-kontakte/eris-osmani-wiedmeier.md` |
| 318 | `03-kontakte/hans-ruediger-kaufmann.md` |
| 317 | `03-kontakte/anna-luettgen.md` |
| 310 | `03-kontakte/anastasia-quast.md` |

## Vorgehen falls Body-Move

1. `notizen:` Block-Syntax-Wert in Body als `## Notizen` Sektion verschieben
2. `notizen:` aus FM entfernen (nicht auf leerstring setzen)
3. Hex-Verify

Aber: Alle 10 sind Kontakt-Files. Die FM ist API-relevant (Properties-View
in Obsidian, wahrscheinlich auch JSON-Export ueber `_api/`). Body-Move
verschiebt das aus dem strukturierten Bereich. Vorteil: kuerzere FM in
Properties-View. Nachteil: kein Property-Filter mehr ueber notizen-Inhalt.

Empfehlung: nur bei sehr langem Inhalt (>500) Body-Move erwaegen. Aktuelle
Liste ist 300-416, alle noch im Properties-Rahmen vertretbar nach
Block-Syntax-Migration.
