---
typ: forensik
phase: final
datum: 2026-04-26
zeitpunkt: 21:35
status: root-cause-confirmed
---

# Forensik-Report - Vault-Frontmatter-Korruption

## TL;DR

**Root Cause: Desktop Commander MCP `write_file` Tool** (verfuegbar in Claude Desktop App ueber Extension `ant.dir.gh.wonderwhy-er.desktopcommandermcp`). Tool transformiert Markdown-Frontmatter beim Schreiben kaputt: Multi-Line-YAML zu einer Zeile mit `## ` Prefix, schliessendes `---` weg, Backslash-Escapes auf `[ ]`, Tabellen-Kollaps, Email-Auto-Linking.

13 Files aktuell betroffen. Alle bekannte Korruptions-Patterns sind reproduzierbar dem Tool zuordenbar.

## Beweisfuehrung

### Negative Evidenz (was es NICHT ist)

| Hypothese | Status | Beweis |
|---|---|---|
| H1 Auto-Push-Task | widerlegt | Skript-Analyse, modifiziert keine Inhalte |
| H2 Umlaut-Fix-Skript | widerlegt | dash-replacer.py harmlos, ZY-Korruption nach Reparatur |
| H3 Properties Plugin | widerlegt | Reine Obsidian-Existenz korruptiert nicht (T1+T2 jeweils 0 changes) |
| H4 Bases Plugin | widerlegt | dito |
| H5 File-Recovery | widerlegt | Snapshot-Ordner existiert nicht |
| H6 OneDrive-Sync | widerlegt | Documents nicht in OneDrive |
| H7 Community-Plugin | widerlegt | Kein plugins/ Ordner |
| H8c Cowork-Watcher | widerlegt | T1 = 0 changes in 10 Min Idle |
| H10 Obsidian-Start | widerlegt | T2 = 0 changes nach Obsidian-Start mit Auto-Tab-Restore |

### Positive Evidenz (was es IST)

**Live-Beweis waehrend Reproducer-Test** (T1+T2 liefen, Test-Datei mit PowerShell `WriteAllBytes` geschrieben):

| Datei | Tool | mtime | Status |
|---|---|---|---|
| `test-watchdog-T0.md` | PowerShell WriteAllBytes UTF-8 NoBOM | 20:21:26 | sauber, blieb sauber |
| `01-projekte/coralate/coralate.md` | Desktop Commander write_file | 20:22:49 | KAPUTT (Pattern A) |
| `01-projekte/coralate/cora-ai/cora-ai.md` | unklar | 20:24:17 | KAPUTT (Pattern A+C+E) |
| `01-projekte/coralate/cora-ai/meeting-2026-04-26-weekly.md` | Desktop Commander write_file | 20:26:07 (created) bzw. 21:33:07 (re-mod) | KAPUTT (Pattern A+E) |

Test-Datei wurde NIE von Desktop Commander beruehrt, blieb intakt. Coralate-Files wurden parallel zur Forensik durch eine andere laufende Claude-Desktop-Session via Desktop Commander geschrieben und sind alle kaputt.

### Hex-Pattern-Charakteristik

**PowerShell-Write (sauber):**
```
2D 2D 2D 0A 74 79 70 3A 20 ...   = ---\ntyp: ...
```

**Desktop-Commander-Write (kaputt):**
```
2D 2D 2D 0A 0A 23 23 20 ...      = ---\n\n## ...
```

Reproduzierbarer Fingerprint des Bug-Tools.

## Aktuell kaputte Files (13)

| # | Pfad | Patterns | mtime | Cluster |
|---|---|---|---|---|
| 1 | `03-kontakte/christian-pulse.md` | A+C | 25.04 20:51:44 | A |
| 2 | `03-kontakte/kai-pulse.md` | A+C | 25.04 20:52:09 | A |
| 3 | `03-kontakte/german-pulse.md` | A+C | 25.04 20:52:15 | A |
| 4 | `03-kontakte/patrick-pulse.md` | A+C | 25.04 20:52:42 | A |
| 5 | `03-kontakte/lizzi-pulse.md` | A+C | 25.04 20:52:48 | A |
| 6 | `01-projekte/pulsepeptides/knowledge-base/zy-peptides.md` | A | 26.04 16:58:40 | B |
| 7 | `01-projekte/pulsepeptides/knowledge-base/lab-peptides.md` | E+G | 26.04 17:00:55 | B |
| 8 | `01-projekte/pulsepeptides/pulsepeptides.md` | A+C+E | 26.04 17:16:07 | B |
| 9 | `01-projekte/pulsepeptides/knowledge-base/bestellprozess.md` | A | 26.04 17:19:16 | B |
| 10 | `01-projekte/pulsepeptides/clickup-pulse-entwurf.md` | A+E | 26.04 17:19:21 | B |
| 11 | `01-projekte/coralate/coralate.md` | A | 26.04 20:22:49 | C |
| 12 | `01-projekte/coralate/cora-ai/cora-ai.md` | A+C+E | 26.04 20:24:17 | C |
| 13 | `01-projekte/coralate/cora-ai/meeting-2026-04-26-weekly.md` | A+E | 26.04 21:33:07 | C |

## Loesung (Phase 5+6 Plan)

### Sofort (Phase 5)

1. **Coralate-Chat stoppen** (Deniz-Hand): bevor weitere Files korruptiert werden.
2. **Aktuelle 13 Files reparieren** mit `repair-frontmatter.ps1` (DRY-RUN zuerst, dann Apply mit Backup). cora-ai.md und meeting-2026-04-26-weekly.md sind neu, brauchen Erweiterung des Skripts.
3. **Stabilitaets-Verify**: 60s warten, alle 13 nochmal hex-check.

### Strukturell (Phase 6)

1. **Wissens-Eintrag im Vault**: `02-wissen/desktop-commander-frontmatter-bug.md` mit:
   - Bug-Beschreibung mit Hex-Pattern
   - Verbotene Tools-Liste
   - Pflicht-Schreibmethoden mit Beispielen
   - Referenz auf forensik-2026-04-26 fuer historische Beweisfuehrung
2. **Skill-Updates**:
   - `vault-system.md` neue Sektion "Vault-Schreibregeln" mit Verbot von Desktop Commander `write_file` und `edit_block` fuer .md mit YAML-Frontmatter, Pflicht-Methode PowerShell `WriteAllBytes`
   - `log.md`, `eingang-verarbeiten.md`, `audio-verarbeiten.md`, `transkript-verarbeiten.md` jeweils Hinweis auf neue Schreibregeln
3. **Watchdog-Skript** `_claude/scripts/vault-health-check.ps1`:
   - Scannt alle .md auf Pattern A, C, G
   - Exit-Code != 0 wenn Bugs gefunden
   - Optional Pre-Commit-Hook
4. **CLAUDE.md ergaenzen**: explizite Warnung "Was Claude NIE tun soll" um den Desktop Commander Punkt erweitern

## Was Deniz selbst tun muss

1. **Coralate-Chat stoppen** (anderer Claude-Desktop-Tab): kritisch, sofort
2. **In ALLEN aktiven Claude-Desktop-Sessions** zu Miraculix-Files: keine Tools mit `write_file`, `edit_block`, `move_file` aus Desktop Commander mehr. Nur PowerShell `WriteAllBytes`.
3. Optional: Desktop Commander Extension komplett deaktivieren via Claude Desktop UI (Extensions Tab > toggle off `Desktop Commander`).

## Was strukturell verhindert werden muss

Der Default-Workflow in Skills muss explizit die sichere Methode vorschreiben. Ohne diese Regel wird der Bug bei jedem neuen Claude-Chat wiederholt.

Konkrete Pattern fuer Vault-Files mit YAML-Frontmatter:

```powershell
# RICHTIG (sicher):
$content = @"
---
typ: log
datum: 2026-04-26
---

Inhalt
"@
$bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($content)
[System.IO.File]::WriteAllBytes($path, $bytes)

# FALSCH (kaputt-machend):
# write_file mit content das YAML-Frontmatter enthaelt
# (wenn ueber Desktop Commander aufgerufen)
```

Fuer Files OHNE Frontmatter ist Desktop Commander vermutlich sicher, aber als Defense-in-Depth empfehle ich generelles Verbot fuer .md-Files im Vault.

## Forensik-Artefakte

Alle Beweise unter `_claude/scripts/forensik-2026-04-26/`:

| Datei | Inhalt |
|---|---|
| `00-vorgeschichte.md` | Phase 0 - Skills, Tasks, Hooks, Scripts, Hypothesen |
| `01-forensik.md` | Phase 1 - Configs, Plugins, Extensions, Hypothesen-Update |
| `02-bug-scan-final.csv` | Phase 2 - alle Files mit Bug-Patterns |
| `02-bug-summary.md` | Phase 2 - Summary mit Cluster-Histogramm |
| `02-vault.bundle` | komplettes Git-Bundle (25 MB Backup) |
| `02-working-tree-changes.patch` | Working-Tree-Diff |
| `03-T1-result.md` | Phase 3 T1 - Idle 10 Min, 0 changes |
| `03-T1-watch.log` | Watch-Log T1 |
| `03-T2-watch.log` | Watch-Log T2 (Obsidian-Start, 0 changes) |
| `01-claude-extensions/` | Extension-Manifests + Settings |
| `repair-frontmatter.ps1` | Reparatur-Skript (vorbereitet) |
| `bug-scanner-v3.ps1` | Watchdog-Scanner |
| `REPORT.md` | dieser Report |
