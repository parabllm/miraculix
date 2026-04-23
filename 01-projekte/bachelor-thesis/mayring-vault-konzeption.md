---
typ: aufgabe
name: "Mayring-Vault Konzeption für Interview-Auswertung"
projekt: "[[bachelor-thesis]]"
status: offen
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
faellig: 2026-05-31
kontakte: ["[[christoph-sandbrink]]"]
quelle: chat_session
vertrauen: bestaetigt
erstellt: 2026-04-23
---

# Mayring-Vault Konzeption

Separater Obsidian-Vault mit eigener Pipeline für die qualitative Inhaltsanalyse der Experteninterviews nach Mayring. Läuft parallel zum Bachelor-Thesis-Research-Vault (`bachelor-thesis-vault`), ist aber inhaltlich und technisch davon getrennt.

## Warum separat

Die Pipeline im Bachelor-Thesis-Research-Vault ist für Literatur-Passagen optimiert (Ingestion, Metadaten-Verifikation, Fuzzy-Quote-Validation, Kategorien-Routing). Die Mayring-Inhaltsanalyse hat andere Anforderungen:

- Transkript-Ingestion statt PDF-Ingestion
- Paraphrasierung und Generalisierung statt Fuzzy-Zitat-Validierung
- Deduktiv-induktive Kategorienbildung mit Iteration am Material
- Intracoderreliabilität-Tracking
- Anonymisierung (I01, I02 etc.) statt bibliographischer Metadaten

Eine saubere Trennung hält beide Pipelines fokussiert und erlaubt unabhängige Entwicklung.

## Workflow-Idee

1. Interviews werden transkribiert (F4 oder vergleichbar)
2. Transkripte wandern in Mayring-Vault
3. Mayring-Pipeline verarbeitet nach seinen Regeln, klassifiziert Passagen nach K1 bis K6 plus induktiven Subkategorien
4. Verarbeitete und klassifizierte Interview-Passagen werden zurück in den Bachelor-Thesis-Research-Vault gespielt, dort mit `intended_use: empirical` markiert
5. Oder alternativ: Mayring-Output bleibt im Mayring-Vault und wird beim Schreiben von Kapitel 5 manuell herangezogen

Variante wird nach Fertigstellung Mayring-Vault entschieden.

## Aktueller Stand

Konzept noch nicht detailliert ausgearbeitet. Aktivierung nach:
- Finalisierung Scope und Gliederung (erledigt 23.04.2026)
- Pipeline-Sondierung Bachelor-Thesis-Research-Vault (läuft)
- Erste Interviews tatsächlich durchgeführt (frühestens Mai 2026)

## Offene Fragen

- Welche Tools für Transkription (F4, otter.ai, Microsoft Copilot Premium Teams-Transkription)
- Soll die Mayring-Pipeline ebenfalls Claude-Code-basiert sein (wie der Research-Vault) oder reicht manuelle Arbeit in Obsidian mit MAXQDA-Export
- Wie Anonymisierung technisch umsetzen (automatisch oder manuell)
- Import-Format zurück in den Research-Vault definieren, falls Variante Rückspielung gewählt wird

## Nächste Schritte

- [ ] Abwarten erste Interview-Termine, frühestens nach Antworten der aktuellen Anfragen
- [ ] Parallel: Mayring-Vault Grobkonzept skizzieren (kann nach erstem Interview konkretisiert werden)
- [ ] Abstimmung mit Sandbrink im nächsten Betreuungsgespräch
