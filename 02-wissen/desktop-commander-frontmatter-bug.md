---
typ: wissen
thema: desktop-commander-frontmatter-bug
status: aktiv
erstellt: 2026-04-26
vertrauen: bestätigt
quelle: forensik-2026-04-26
prioritaet: kritisch
---

# Desktop-Commander Frontmatter-Korruptions-Bug

Forensik-belegter Bug im MCP-Tool `Desktop Commander:write_file` (Extension `ant.dir.gh.wonderwhy-er.desktopcommandermcp` in Claude-Desktop-App). Korruptiert YAML-Frontmatter beim Schreiben von .md-Dateien.

## TL;DR

Tool fuehrt YAML-Pretty-Printer-Roundtrip durch beim Schreiben. Multi-Line-YAML wird zu einer Zeile kollabiert, schliessendes `---` faellt weg, `## `-Prefix wird eingefuegt, Backslashes werden hinzugefuegt, Tabellen kollabieren, Email-Adressen werden auto-verlinkt.

Reproduzierbar als Hex-Pattern A (`2D 2D 2D 0A 0A 23 23 20`).

## Hex-Pattern-Beispiele

### Vorher (sauber, von PowerShell oder Filesystem-MCP geschrieben)

```
2D 2D 2D 0A 74 79 70 3A 20 6C 6F 67 0A 64 61 74 75 6D 3A 20 32 30 32 36 ...
```

Klartext:
```
---
typ: log
datum: 2026 ...
```

### Nachher (kaputt, von Desktop-Commander geschrieben)

```
2D 2D 2D 0A 0A 23 23 20 5B 4C 6F 67 5D 28 6C 6F 67 29 ...
```

Klartext:
```
---

## [Log](log) ...
```

Sichtbarer Schaden:
1. Erste Zeile YAML weg
2. Zweites `---` (Frontmatter-Schluss) weg
3. `## ` (H2-Heading) eingefuegt
4. Auto-Linking auf Werten

### Pattern A im Detail

| Bytes | Bedeutung |
|---|---|
| `2D 2D 2D` | `---` (FM-Start, OK) |
| `0A` | `\n` (Zeilenende, OK) |
| `0A` | zweites `\n` (Leerzeile, FALSCH - hier sollte YAML-Key sein) |
| `23 23 20` | `## ` (H2-Marker, FALSCH - YAML wurde geloescht) |

## Affected Tools

| Tool | Status | Beleg |
|---|---|---|
| `Desktop Commander:write_file` | KAPUTT (bestaetigt) | Live-Reproduzent 2026-04-26 20:22-20:26 |
| `Desktop Commander:edit_block` | vermutlich kaputt | gleicher Engine-Code anzunehmen, Test offen |
| `Filesystem:write_file` (Anthropic offiziell) | SAUBER | Test 2026-04-26, siehe vault-schreibregeln.md Sektion 1.3 |
| `Filesystem:edit_file` | SAUBER | dito |
| PowerShell `[System.IO.File]::WriteAllBytes` | SAUBER | Self-Test 2026-04-26, siehe 07-self-test.md |
| Claude-Code Write-Tool | SAUBER | Self-Test 2026-04-26 |

## Forensik-Beweis

Vollstaendige Beweisfuehrung in `_claude/scripts/forensik-2026-04-26/REPORT.md`. Kern-Argument:

Waehrend des T1+T2-Reproducer-Tests (Idle plus Obsidian-Start, 0 Changes erwartet) wurde eine Test-Datei mit PowerShell-WriteAllBytes geschrieben (`test-watchdog-T0.md`, 890 Bytes). Diese blieb 30+ Minuten unveraendert, sauber.

Parallel dazu schrieb eine andere Claude-Desktop-Session (Coralate-Chat) drei .md-Files via Desktop Commander:

| Datei | Tool | mtime | Resultat |
|---|---|---|---|
| `01-projekte/coralate/coralate.md` | Desktop Commander write_file | 20:22:49 | KAPUTT (Pattern A) |
| `01-projekte/coralate/cora-ai/cora-ai.md` | Desktop Commander write_file | 20:24:17 | KAPUTT (Pattern A+C+E) |
| `meeting-2026-04-26-weekly.md` | Desktop Commander write_file | 20:26:07 | KAPUTT (Pattern A+E) |

Cause-Effect: gleiche Zeit, gleicher Vault, einziger Unterschied = das Schreib-Tool.

## Repariertes Pattern-Set

Voll-Patternliste der erkannten Korruptions-Varianten (siehe `forensik-2026-04-26/02-bug-summary.md`):

| ID | Pattern | Beschreibung |
|---|---|---|
| A | `2D 2D 2D 0A 0A 23 23 20` | Frontmatter zu Heading kollabiert |
| B | flat-Frontmatter | Multi-Line YAML zu Single-Line |
| C | `[[name]]` ohne Schluss-`]` | unvollstaendiges Wikilink-Array |
| D | `\[ \] \~ \"` Escapes wo nicht noetig | Backslash-Auto-Escape |
| E | Tabelle ohne Newline | Pipe-Zeilen kollabiert |
| F | LF-only EOL in CRLF-Vault | EOL-Style-Bruch |
| G | `[email](mailto:email)` in Frontmatter | Auto-Linking in YAML |
| H | `[[self-name]]` im Body als Self-Link | redundanter Self-Verweis |

## Reparatur-Skript

`_claude/scripts/forensik-2026-04-26/repair-frontmatter.ps1`

- DRY-RUN-Switch (`-Apply` als Pflicht-Flag fuer Aenderung)
- Backup VOR jedem Write nach `05-pre-repair-backups/`
- Funktionen: `Repair-FrontmatterValue`, `Parse-PatternA-Frontmatter`, `Format-MultilineYaml`
- Hex-Verify nach jedem Write

Status: vorbereitet, nicht ausgefuehrt. Phase B (DRY-RUN, dann 3 Batches) folgt nach dieser Phase.

## Praeventions-Strategie

### Layer 1: Skill-Regeln
Alle 11 Skills referenzieren `[[vault-schreibregeln]]`. `vault-system.md` Z.50 (gefaehrlicher Workaround) wird in Phase D entfernt.

### Layer 2: CLAUDE.md
Single Entry Point fuer Claude-Code. Schreibregeln-Sektion in den ersten 50 Zeilen, automatisch beim Vault-Start im Kontext.

### Layer 3: Memory-Pointer
Memory-Eintrag verweist auf vault-schreibregeln.md, kopiert nicht.

### Layer 4: Watchdog
`vault-health-check.ps1` scant alle .md-Files auf Pattern A-H. Pre-Commit-Hook blockiert neue Bugs.

### Layer 5: Defense-Test
Phase I: synthetischer Korruptions-Test pruefen ob alle Layer greifen.

## Was Deniz selbst tun muss

1. In Claude-Desktop-Sessions: KEINE Desktop-Commander-Tools mehr fuer .md mit YAML-Frontmatter.
2. Optional: Desktop-Commander-Extension komplett deaktivieren via Claude-Desktop UI (Extensions Tab > toggle off `Desktop Commander`).
3. Wenn Multi-Tool-Setup im Desktop: Filesystem-MCP bevorzugen (write_file und edit_file beide SAUBER getestet).

## Verweise

- [[vault-schreibregeln]] - kanonische Schreibregeln (TL;DR plus Detail-Sektionen)
- `_claude/scripts/forensik-2026-04-26/REPORT.md` - Forensik-Vollbericht
- `_claude/scripts/forensik-2026-04-26/02-bug-summary.md` - Pattern-Histogramm
- `_claude/scripts/forensik-2026-04-26/repair-frontmatter.ps1` - Reparatur-Skript

## Aenderungs-Historie

| Datum | Aenderung |
|---|---|
| 2026-04-26 | Initial-Erstellung. Filesystem-MCP-Test-Resultate eingebaut. |
