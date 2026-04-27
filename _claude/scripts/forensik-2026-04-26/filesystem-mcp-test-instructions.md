---
typ: forensik
phase: C
datum: 2026-04-26
zweck: filesystem-mcp-test-anleitung
adressat: deniz-im-claude-desktop-chat
---

# Filesystem-MCP-Test - Anleitung fuer Deniz

## Ziel

Klaeren ob die Filesystem-MCP-Tools (Anthropics offizielles `@modelcontextprotocol/server-filesystem` oder vergleichbar) den gleichen Frontmatter-Korruptions-Bug haben wie Desktop Commander, oder sicher sind.

Resultat fliesst in `02-wissen/vault-schreibregeln.md` Sektion "Verbotene Schreibmethoden" / "Sichere Schreibmethoden" ein.

## Voraussetzung

- Du bist im Claude-Desktop-Chat (nicht Claude-Code)
- Filesystem-MCP-Server ist verbunden (Tool-Liste enthaelt z.B. `Filesystem:write_file`, `Filesystem:edit_file`, `Filesystem:read_file`)

## Test-Setup

Quelle: `_claude/scripts/forensik-2026-04-26/test-files/filesystem-mcp-test-input.md` (337 Bytes ish, sauber von Claude-Code Write geschrieben).

Pre-Check (du im Claude-Desktop-Chat):
```powershell
$f = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-files\filesystem-mcp-test-input.md"
$bytes = [System.IO.File]::ReadAllBytes($f)
"Pre-Test SIZE: $($bytes.Length)"
"Pre-Test FIRST 8 hex: $(($bytes[0..7] | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')"
```
Erwartet: `2D 2D 2D 0A 74 79 70 3A` (sauberer Soll-Zustand).

## Test 1: Filesystem:write_file

Kopiere den Inhalt von `filesystem-mcp-test-input.md` 1:1 (auch das `---` und alles).

Schreibe damit eine NEUE Datei via Filesystem-MCP:
```
Tool: Filesystem:write_file
path: C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-files\fs-mcp-write-result.md
content: <kopierter Inhalt>
```

Direkt nach dem Write, im selben Chat, run:
```powershell
$f = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-files\fs-mcp-write-result.md"
$bytes = [System.IO.File]::ReadAllBytes($f)
"=== Filesystem:write_file ==="
"SIZE: $($bytes.Length)"
"FIRST 30 hex: $(($bytes[0..29] | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')"
$content = [System.Text.Encoding]::UTF8.GetString($bytes)
"Pattern A check: $($content.StartsWith('---' + [char]10 + [char]10 + '## '))"
"Backslash-Bracket-Escapes: $(([regex]::Matches($content, '\\\[|\\\]')).Count)"
"Tabellen-Pipe-Zeilen: $(($content -split [char]10 | Where-Object { $_ -match '^\|' }).Count)"
"Wikilink-Array: $(([regex]::Match($content, 'teilnehmer:.*')).Value)"
```

Reporte mir die Output-Zeilen.

## Test 2: Filesystem:edit_file (falls verfuegbar)

Lies die existierende `filesystem-mcp-test-input.md` und mache eine kleine Aenderung im Body via `edit_file` oder `edit_text_file`. Z.B. `Ende.` zu `Ende des Test-Inhalts.` aendern.

NACH der Edit-Operation, run:
```powershell
$f = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-files\filesystem-mcp-test-input.md"
$bytes = [System.IO.File]::ReadAllBytes($f)
"=== Filesystem:edit_file ==="
"SIZE: $($bytes.Length)"
"FIRST 30 hex: $(($bytes[0..29] | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')"
$content = [System.Text.Encoding]::UTF8.GetString($bytes)
"Pattern A: $($content.StartsWith('---' + [char]10 + [char]10 + '## '))"
"Frontmatter intakt: $(($content -split [char]10 | Where-Object { $_ -match '^---$' }).Count -ge 2)"
"Tabellen-Zeilen: $(($content -split [char]10 | Where-Object { $_ -match '^\|' }).Count)"
"Wikilink-Array: $(([regex]::Match($content, 'teilnehmer:.*')).Value)"
```

Reporte.

## Test 3 (optional): Filesystem:edit_text_file (falls verfuegbar, anderer Code-Pfad)

Wie Test 2 aber mit `edit_text_file` statt `edit_file`. Reporte.

## Erwartete Patterns

**SAUBER** (Tool ist OK):
- `FIRST 8 hex: 2D 2D 2D 0A 74 79 70 3A`
- `Pattern A check: False`
- `Backslash-Bracket-Escapes: 0`
- `Tabellen-Pipe-Zeilen: 4` (3 aus Test 1, 4 mit Wikilink-Zeile)
- `Wikilink-Array: teilnehmer: ["[[deniz]]", "[[test-person]]", "Externe Person"]`

**KAPUTT** (Tool hat Bug):
- `FIRST 8 hex: 2D 2D 2D 0A 0A 23 23 20` (Pattern A Fingerprint)
- `Pattern A check: True`
- Backslash-Escapes > 0
- Tabellen-Zeilen kollabiert
- Wikilink-Array verstuemmelt

## Reporting-Format

Schick mir pro Tool diese 4 Zeilen:
```
Tool: <name>
SIZE: <bytes>
FIRST_8_HEX: <hex>
PATTERN_A: <true|false>
NOTES: <auffaelligkeiten>
```

Wenn ein Tool nicht verfuegbar ist (z.B. nur `write_file` aber kein `edit_file`): einfach "N/A" reporten.

## Nach dem Test

Result-Files koennen in test-files/ bleiben (oder du loeschst fs-mcp-write-result.md falls aufgeraeumt werden soll). Die Originale (filesystem-mcp-test-input.md) bitte stehen lassen, wird in Phase I nochmal benutzt.
