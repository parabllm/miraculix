---
typ: wissen
domain: vault-management
erstellt: 2026-04-25
vertrauen: bestätigt
quelle: cleanup-phase-3
---

# Vault-Schreibkonventionen

Verbindliche Regeln für Schreibweise, Encoding und Datei-Handling im Miraculix-Vault. Alle Claude-Instanzen, Skills und manuelle Edits müssen diese Regeln einhalten.

## Encoding und Zeichen

| Wo | Regel | Beispiel |
|---|---|---|
| Klartext (Fließtext, Listen, Überschriften) | Echte Umlaute (ä ö ü ß) und deutsche Standardrechtschreibung | "Gespräch", "müssen", "Straße" |
| Frontmatter-Werte (rechts vom Doppelpunkt, in Anführungszeichen) | Echte Umlaute, deutsche Standardrechtschreibung | `name: "Hans-Rüdiger Kaufmann"` |
| Frontmatter-Keys (links vom Doppelpunkt) | ASCII-only, snake_case | `kapazitaet_energie:` (nicht `kapazität_energie:`) |
| YAML-Enum-Werte (unquoted) | Echte Umlaute wenn deutsches Wort | `vertrauen: bestätigt` |
| Code-Blöcke und Inline-Code | ASCII-only, keine Modifikation durch Cleanup | `` `git commit -m "feat: ..."` `` |
| URLs, Pfade, IDs | ASCII-only, unverändert | `https://example.com/page` |
| Wikilinks `[[...]]` | Match exakt mit Dateiname (siehe Dateinamen-Regel) | `[[christian-pulse]]` |
| Dateinamen | ASCII, kebab-case, keine Umlaute, keine Leerzeichen | `kontakt-mueller.md` (nicht `Müller.md`) |
| Git-Commit-Messages | ASCII-only (Windows-Terminal-Kompatibilität) | `cleanup-phase1: batch 1` |

## Gedankenstriche

- Em-Dash (—, U+2014): niemals verwenden
- En-Dash (–, U+2013): niemals verwenden
- Stattdessen: normaler Bindestrich (-), Komma, oder Satzteilung mit Punkt
- Ausnahme: in Code-Blöcken erlaubt
- Ausnahme: in explizit markierten Negativ-Beispielen (z.B. in Stil-Doku)

## Archivierung und Datei-Operationen

**Beim Archivieren oder Verschieben wird der Dateiname NICHT verändert.**

Korrekt:
- Datei verschieben von `01-projekte/xy/file.md` nach `05-archiv/file.md`
- Frontmatter ergänzen: `status: archiviert` und/oder `archiviert_am: <datum>`
- Wikilinks bleiben dadurch funktionsfähig

Falsch:
- Datei umbenennen zu `file-VERSCHOBEN.md`, `file-archiviert.md`, `ALT-file.md`
- Suffix oder Präfix an den Dateinamen anhängen
- Wikilinks brechen dadurch in allen referenzierenden Files

Begründung: Obsidian-Wikilinks zeigen auf den Dateinamen ohne Pfad. Eine Umbenennung beim Verschieben bricht alle Verweise auf diese Datei.

## Konsistenz-Prinzipien

1. Bei Unsicherheit: nicht ändern, in Report dokumentieren, Deniz fragen
2. Im Zweifel konservativ: lieber zu wenig als zu viel automatisieren
3. Vor jedem Multi-File-Write: Plan zeigen, OK abwarten
4. Provenance: jede Aussage in Wissens-Files braucht `quelle:` und `vertrauen:` im Frontmatter
5. Wikilinks nie im Bulk raten — bei unklarer Zieldatei in Report aufnehmen

## Verweis im Skill-System

Diese Datei ist die Single Source of Truth für Schreibkonventionen. Der Skill `vault-system` enthält die Archivierungs-Regel und verweist auf diese Datei für Details.

## Tool-Sicherheit und Schreibmethoden

Diese Datei regelt **WAS** in .md-Files steht (Encoding, Umlaute, Naming). Die komplementaere Master-Quelle [[vault-schreibregeln]] regelt **WIE** Files geschrieben werden:

- Sichere und verbotene MCP-Tools (Desktop Commander Bug)
- Hex-Verify-Pflicht nach jedem Write
- Bug-Patterns A bis H
- Rollback-Verfahren

Beide Files MUESSEN gelesen werden vor Vault-Writes. Keine ist Ersatz fuer die andere.
