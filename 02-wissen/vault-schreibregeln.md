---
typ: wissen
thema: vault-schreibregeln
status: aktiv
erstellt: 2026-04-26
vertrauen: bestätigt
quelle: forensik-2026-04-26
prioritaet: kritisch
---

# Vault-Schreibregeln

Kanonische Quelle fuer Tool-Wahl, Verify-Pflicht und Rollback beim Schreiben in den Miraculix-Vault.

Diese Datei wird referenziert von `CLAUDE.md`, allen Skills in `_claude/skills/`, und der Memory.

## Komplementaere Master-Quellen (beide Pflicht-Lektuere vor Vault-Writes)

| Datei | Regelt | Stichworte |
|---|---|---|
| [[vault-schreibkonventionen]] | **WAS** in Files steht | Encoding, Umlaute, ASCII vs UTF-8 Zonen, Gedankenstriche-Verbot, Dateiname-Stabilitaet, Wikilink-Match-Regel |
| **diese Datei** ([[vault-schreibregeln]]) | **WIE** Files geschrieben werden | Tool-Sicherheit, Hex-Verify-Pflicht, Rollback, Bug-Patterns A bis H |

Beide MUESSEN gelesen werden vor Vault-Writes. Keine ist Ersatz fuer die andere.

## TL;DR (3 Zeilen)

1. NIE `Desktop Commander:write_file` oder `edit_block` fuer .md mit YAML-Frontmatter (Pretty-Printer-Roundtrip-Bug, korruptiert Frontmatter).
2. Sichere Schreibmethoden: PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 NoBOM, Filesystem-MCP `write_file`/`edit_file`, Claude-Code Write-Tool.
3. Hex-Verify nach JEDEM Write Pflicht. Erste 8 Bytes muessen `2D 2D 2D 0A 74 ...` (LF) oder `2D 2D 2D 0D 0A ...` (CRLF) ergeben, NICHT `2D 2D 2D 0A 0A 23 23` (Pattern A).

## Sektion 1: Sichere Schreibmethoden

### 1.1 PowerShell WriteAllBytes (Gold-Standard)

```powershell
$content = @"
---
typ: log
datum: 2026-04-26
---

Inhalt mit echten Umlauten ä ö ü ß.
"@
$bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($content)
[System.IO.File]::WriteAllBytes($path, $bytes)
```

Eigenschaften:
- UTF-8 ohne BOM
- LF oder CRLF je nach Quell-String (Here-String mit `@"..."@` -> CRLF, einzelne PowerShell-Strings mit Newline-Escape -> LF)
- Atomic (kein Roundtrip)
- Funktioniert mit Multi-Line-YAML, Wikilink-Arrays, Tabellen

### 1.2 Base64-Pipeline (fuer grosse Files oder Inhalt mit Quoting-Problemen)

```powershell
$b64 = "PASTE_BASE64_HERE"
$bytes = [Convert]::FromBase64String($b64)
[System.IO.File]::WriteAllBytes($path, $bytes)
```

Wann nutzen: wenn Inhalt komplexe Quoting-Strukturen hat (PowerShell Here-String wird unzuverlaessig), oder bei sehr grossen Files (>10 KB).

### 1.3 Filesystem-MCP (Anthropic offiziell)

Getestet 2026-04-26 (siehe `_claude/scripts/forensik-2026-04-26/test-files/fs-mcp-write-result.md`):

| Tool | Status | Beleg |
|---|---|---|
| `Filesystem:write_file` | SAUBER | 502 Bytes, Pattern A negativ, Frontmatter intakt, Wikilink-Array intakt, Umlaute korrekt UTF-8 |
| `Filesystem:edit_file` | SAUBER (sogar besser, chirurgisch) | Git-style Diff, nur geaenderte Zeile betroffen, Rest unangetastet |
| `Filesystem:edit_text_file` | nicht verfuegbar | N/A |

Filesystem-MCP ist die bevorzugte Wahl in Claude-Desktop-Sessions wenn verfuegbar. `edit_file` ist `write_file` ueberlegen, weil chirurgischer Edit (kein Full-Rewrite, kein Re-Verify-Risk fuer unveraenderte Sektionen).

### 1.4 Claude-Code Write-Tool

Self-Test 2026-04-26 (siehe `_claude/scripts/forensik-2026-04-26/07-self-test.md`): SAUBER. Standard-Write-Tool in Claude-Code produziert ohne Korruption fuer .md mit Multi-Line-Frontmatter, Wikilink-Arrays, Tabellen, Block-Quotes, Backslash-Escapes.

Hex-Verify trotzdem Pflicht (Defense-in-Depth).

## Sektion 2: Verbotene Schreibmethoden mit Begruendung

### 2.1 Desktop Commander `write_file` (Extension `ant.dir.gh.wonderwhy-er.desktopcommandermcp`)

**Status:** VERBOTEN fuer .md mit YAML-Frontmatter.

**Bug-Fingerprint:** Pattern A. Multi-Line-YAML wird zu einer Zeile mit `## ` Prefix kollabiert, schliessendes `---` weg, Backslash-Escapes auf `[ ]`, Tabellen kollabiert, Email-Auto-Linking.

```
Vorher (sauber):
2D 2D 2D 0A 74 79 70 3A 20 6C 6F 67 0A ...
---\ntyp: log\n...

Nachher (kaputt):
2D 2D 2D 0A 0A 23 23 20 ...
---\n\n## ...
```

**Beweis:** Live-Reproduzent waehrend Forensik 2026-04-26, parallel zu T1+T2-Test (siehe REPORT.md). Test-Datei (PowerShell-geschrieben) blieb sauber. Coralate-Files (Desktop Commander) wurden parallel kaputt geschrieben.

**Wer ist betroffen:** Claude-Desktop-Sessions mit aktiver Desktop-Commander-Extension. Claude-Code ist NICHT betroffen (eigenes Write-Tool, siehe Self-Test).

### 2.2 Desktop Commander `edit_block`

**Status:** VERBOTEN fuer .md mit YAML-Frontmatter.

**Begruendung:** Vermutlich gleicher Engine-Code wie `write_file` (Pretty-Printer-Roundtrip). Nicht 100% bewiesen, aber als Defense vorerst gleichgesetzt mit `write_file`. Test-Hypothese fuer Phase I: synthetischer Test mit `edit_block`.

### 2.3 Allgemeine Regel

Jedes MCP-Tool, das einen YAML-Pretty-Printer-Roundtrip durchfuehrt, ist gefaehrlich fuer Frontmatter. Erkennen:
- Wenn Tool eine `mode: append`-Option als Workaround fuer Encoding-Probleme empfiehlt -> verdaechtig
- Wenn Tool YAML neu serialisiert statt durchzureichen -> Roundtrip-Risiko
- Wenn Tool Hex-Pattern A produziert -> bestaetigt verboten

## Sektion 3: Pflicht-Verify nach jedem Write

### 3.1 Verify-Snippet (PowerShell)

```powershell
$f = "<path>"
$bytes = [System.IO.File]::ReadAllBytes($f)
$first8 = ($bytes[0..7] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
$ok_lf  = '2D 2D 2D 0A'
$ok_crlf = '2D 2D 2D 0D 0A'
$bad_a_lf  = '2D 2D 2D 0A 0A 23 23 20'
$bad_a_crlf = '2D 2D 2D 0D 0A 0D 0A 23'

if ($first8 -eq $bad_a_lf -or $first8 -eq $bad_a_crlf) {
    Write-Host "BUG-PATTERN A DETECTED: $first8" -ForegroundColor Red
    throw "Frontmatter-Korruption erkannt"
} elseif ($first8.StartsWith($ok_lf) -or $first8.StartsWith($ok_crlf)) {
    Write-Host "OK: $first8"
} else {
    Write-Host "WARN: unerwartetes Pattern: $first8" -ForegroundColor Yellow
}
```

### 3.2 Verbotene Patterns (sofort-Stop)

| Pattern | Hex (erste Bytes) | Bedeutung |
|---|---|---|
| A | `2D 2D 2D 0A 0A 23 23 20` | YAML kollabiert zu `---\n\n## ` |
| A-CRLF | `2D 2D 2D 0D 0A 0D 0A 23` | wie A, mit CRLF |
| C | (im Body) `5B 5B [^]]+ 5D` ohne Schluss-Klammer | unvollstaendiges Wikilink-Array |
| E | (im Body) Tabellen-Pipe-Zeile direkt gefolgt von Inhalt ohne `\n` | kollabierte Tabelle |
| G | (im Body) `\[<email>\]\(mailto:` in Frontmatter | Auto-Linking in YAML |

### 3.3 Erlaubte Patterns

- `2D 2D 2D 0A` (LF) gefolgt von ASCII-Buchstaben (YAML-Key)
- `2D 2D 2D 0D 0A` (CRLF) gefolgt von ASCII-Buchstaben
- `EF BB BF 2D 2D 2D ...` (BOM + LF + ---) -> akzeptabel aber suboptimal, BOM lieber vermeiden

### 3.4 Lange Frontmatter-String-Werte

Frontmatter-Werte mit > 100 Zeichen muessen YAML-Block-Syntax `|-` mit 2-Space-Einrueckung verwenden.

Begruendung: Lange einzeilige Werte rendert Obsidian als roten Code-Block (sieht aus wie Pattern-A-Korruption). Block-Syntax rendert sauber als Multi-Line-Property.

```yaml
notizen: |-
  Erste Zeile.

  Zweiter Absatz.
```

Ausnahmen (kein Block-Syntax noetig): Listen `[a, b]`, Wikilink-Arrays `["[[xy]]"]`, Datums-Strings, kurze Werte (<100 chars).

Detail-Regel mit Beispielen siehe [[vault-schreibkonventionen]] Sektion "Lange Frontmatter-String-Werte".

## Sektion 4: Umlaut-Regeln

Encoding und Umlaut-Detail-Regeln stehen in [[vault-schreibkonventionen]] (Sektion "Encoding und Zeichen").

Kurz-Regel:
- `.md` Files: echte Umlaute ä ö ü ß als UTF-8
- PowerShell-Strings: ASCII (ae oe ue ss) wenn Encoding fragwuerdig
- Pfade mit Umlauten (z.B. `01-projekte/persönlich/`): mit Bewusstsein behandeln, Hex-Verify nach Write

Verbot: keine `ae oe ue ss` Schreibung in `.md` Files (Ausnahme: in Code-Blocks und PowerShell-Snippets).

## Sektion 5: Wikilink-Regeln

### 5.1 Inline (Body)

Format `[[dateiname]]` ohne Anfuehrungszeichen.

```markdown
Ich habe gestern mit [[deniz]] gesprochen ueber [[pulsepeptides]].
```

### 5.2 YAML-Array (Frontmatter)

Format `["[[name]]", "[[other]]", "Externe Person"]` MIT Anfuehrungszeichen pro String.

```yaml
teilnehmer: ["[[deniz]]", "[[kalani]]", "Externe Person"]
```

### 5.3 Verbotene Patterns

| Verboten | Grund |
|---|---|
| `[[]]` | leerer Wikilink |
| `[[name` | ungeschlossen |
| `[[ name ]]` | Whitespace-Padding (Obsidian akzeptiert es nicht zuverlaessig) |
| `[name]([[name]])` | doppeltes Linking |
| `["[[a]]"` ohne Schluss-`]` | kaputtes Array (Pattern C) |
| Frontmatter-Wert ohne `[]` Array-Wrapper bei mehreren Wikilinks | YAML-Parser-Fehler |

### 5.4 Naming-Bezug

Wikilink-Target = Dateiname ohne `.md`. Match strikt mit Dateiname (siehe [[vault-schreibkonventionen]] Sektion "Dateinamen"). Daher: `[[christian-darmahkasih]]` nicht `[[Christian Pulse]]`.

## Sektion 6: Rollback-Verfahren

### 6.1 Aus pre-repair-backups wiederherstellen

```powershell
$backup = "_claude/scripts/forensik-2026-04-26/05-pre-repair-backups/<file>.md.bak"
$target = "<original-path>"
Copy-Item $backup $target -Force
```

### 6.2 Aus Git-History wiederherstellen

```powershell
# zeige Versionen einer Datei
git log --oneline -- 01-projekte/.../file.md

# wiederherstelle aus spezifischem Commit
git show <commit>:01-projekte/.../file.md > 01-projekte/.../file.md
```

### 6.3 Aus Bundle wiederherstellen

```powershell
git bundle unbundle "_claude/scripts/forensik-2026-04-26/02-vault.bundle"
git checkout <ref> -- <path>
```

### 6.4 Verify nach Rollback

Nach jedem Rollback: Hex-Verify per Snippet aus Sektion 3.1.

## Defense-Ebenen

Drei Layer schuetzen den Vault gegen Korruption. Jede Ebene ist eigenstaendig wirksam.

### Layer 1: Auto-Push Pre-Check (automatisch)

Skript: `_migration/auto-push.ps1` (Windows Scheduled Task, alle 6 Stunden)

Vor jedem `git push` ruft es `vault-health-check.ps1 -Full -FailOnBugs` auf. Bei Korruptions-Findings (Pattern A/C/G) wird der Push BLOCKIERT, Log-Eintrag in `_migration/auto-push.log`, Exit-Code 0 (Scheduled Task sieht Run als erfolgreich an).

So bleiben kaputte Files lokal bis sie repariert sind. GitHub wird nie mit Korruption gefuettert.

### Layer 2: Manueller Watchdog-Aufruf

Skript: `_claude/scripts/vault-health-check.ps1`

Aufruf-Beispiele:
```powershell
# Volle Pruefung mit Markdown-Report
powershell -ExecutionPolicy Bypass -File _claude/scripts/vault-health-check.ps1 -Full

# Schnelle Pruefung (nur Pattern A, ~200ms)
powershell -ExecutionPolicy Bypass -File _claude/scripts/vault-health-check.ps1 -Quick

# Skript-Modus mit Exit-Code (fuer CI/Hooks)
powershell -ExecutionPolicy Bypass -File _claude/scripts/vault-health-check.ps1 -Full -FailOnBugs -NoReport
```

Output: Console-Summary plus Markdown-Report nach `_claude/scripts/vault-health-reports/YYYY-MM-DD-HHMM.md` (nur wenn Findings).

### Layer 3: Skill-Trigger via vault-pruefung

Skill: `_claude/skills/vault-pruefung.md` Sektion 3 (Struktur)

Wenn Deniz "vault pruefen" / "lint" sagt, wird der Watchdog als Teil des Vault-Audits aufgerufen. Bericht ist Teil des wochentlichen Vault-Health-Checks.

### Pre-Commit-Hook (NICHT installiert, optional)

Bewusst nicht standard-installiert. Begruendung: Auto-Push Pre-Check (Layer 1) deckt den gleichen Use-Case ab ohne den Nervigkeits-Faktor von Pre-Commit-Hooks bei Massen-Commits. Falls trotzdem gewuenscht: `_claude/scripts/pre-commit-hook.sh.example` als Vorlage (in Phase F vorbereitet, nicht aktiv).

## Verweise

- [[vault-schreibkonventionen]] - Encoding, Umlaute, Naming, Gedankenstriche
- [[desktop-commander-frontmatter-bug]] - Bug-Doku mit Hex-Patterns und Forensik-Beweis
- `_claude/scripts/forensik-2026-04-26/REPORT.md` - vollstaendige Forensik
- `_claude/scripts/forensik-2026-04-26/07-self-test.md` - Self-Test-Resultat
- `_claude/scripts/vault-health-check.ps1` - Watchdog (Phase F, aktiv)
- `_migration/auto-push.ps1` - Auto-Push mit Pre-Check (Phase F, aktiv)

## Aenderungs-Historie

| Datum | Aenderung |
|---|---|
| 2026-04-26 | Initial-Erstellung nach Forensik. FS-MCP-Test-Resultate eingebaut. |
