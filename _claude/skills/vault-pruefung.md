---
name: miraculix-vault-pruefung
description: |-
  Triggered when Deniz says "vault prüfen", "lint", "konsistenz check", "ist alles aktuell?", "geh mal alles durch", "vault audit" or similar - typically weekly or when Deniz wants to verify vault health.
  
  Use this skill to scan the vault for outdated information, contradictions, structural problems, duplicates, stale inbox items, and skill-drift.
  
  Produce a priority-sorted report - do NOT auto-fix. Deniz decides per finding.
---

# Vault-Prüfung (Lint)

Probleme finden, Bericht liefern. Deniz entscheidet.

## Scope

- Default: ganzer Vault
- Mit Argument: "vault prüfen hays" → nur HAYS

## Prüf-Kategorien

### 1. Veraltete Informationen
- `vertrauen: angenommen` älter als 4 Wochen → "Prüfung nötig"
- Wissens-Einträge `zuletzt_verifiziert` älter als 8 Wochen
- Projekte ohne Log seit 14+ Tagen
- Aufgaben `offen` mit `faellig` in Vergangenheit

### 2. Widersprüche
- Gleiche Fakten, verschiedene Werte
- Projekte `aktiv` aber alle Aufgaben `erledigt` → archivieren?
- Kontakte in Frontmatter ohne File in `03-kontakte/`

### 3. Struktur
- Files ohne Frontmatter / Pflichtfelder
- Kaputte Wikilinks
- Verwaiste Files
- Inbox-Items `unverarbeitet` älter als 7 Tage
- Frontmatter-Korruptions-Patterns: vollstaendige Liste in [[vault-schreibregeln]] Sektion 3.2. Watchdog-Skript: `_claude/scripts/vault-health-check.ps1`. Aufruf manuell: `powershell -ExecutionPolicy Bypass -File _claude/scripts/vault-health-check.ps1 -Full`. Output: Console-Summary plus Markdown-Report nach `_claude/scripts/vault-health-reports/YYYY-MM-DD-HHMM.md`.
- Leere Files (Size < 50 Bytes oder nur Frontmatter ohne Body). Watchdog markiert als WARN, nicht SEVERE (existierende Stubs blockieren keinen Auto-Push).

### 4. Duplikate
- Ähnliche Titel in verschiedenen Ordnern
- Gleiche Info in Projekt-File UND Wissens-File

### 5. Skill-Drift
Entity-Tabellen in `vault-system.md` werden manuell gepflegt.

Prüfe:
- Über-Projekt aus Skill-Tabelle auch als Ordner in `01-projekte/`?
- Ordner in `01-projekte/` die nicht in Skill stehen?
- Jede Wissens-Domain aus Skill auch als Ordner?
- Ordner in `02-wissen/` die nicht in Skill?

Bei Drift: Diff zeigen. Deniz bestätigt → Skill updaten UND erinnern: "Neue Version muss ins Claude Desktop UI hochgeladen werden."

## Ausgabe-Format

```
## Vault-Prüfung - 2026-04-16

### Veraltet (X)
- ⚠️ `02-wissen/n8n/webhook-pattern.md` - 9 Wochen alt

### Widersprüche (X)
- ❌ coralate.md sagt "SDK 54", wissen sagt "SDK 55"

### Struktur (X)
- 🔗 Kaputter Link: `[[robin-kronshagen]]`

### Duplikate (X)
- 📄 n8n Race-Condition in BEIDEN log + wissens-eintrag

### Eingang (X)
- 📥 3 Items seit 5+ Tagen

### Skill-Drift (X)
- 🔄 pulsepeptides in Ordner aber nicht in Skill-Tabelle
```

## Regeln

- **Nur berichten, nicht fixen.** Deniz entscheidet.
- **Priorisierung:** Widersprüche > Skill-Drift > Veraltet > Struktur > Duplikate > Eingang
- **Bei false-positives:** "Möglicher Widerspruch, kann unkritisch sein: ..."

## Vault-Writes

Vor jedem .md-Write Pflicht-Lektuere:
- [[vault-schreibkonventionen]] - WAS rein (Encoding, Umlaute, Naming, Gedankenstriche)
- [[vault-schreibregeln]] - WIE schreiben (Tools, Rollback, Bug-Patterns)

Kernregeln:
- NIE Desktop Commander `write_file` oder `edit_block` fuer .md mit YAML-Frontmatter
- Hex-Verify Pflicht nach jedem Write (erste 8 Bytes muessen `2D 2D 2D 0A` plus YAML-Key sein)
