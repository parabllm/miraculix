---
typ: forensik
phase: J
datum: 2026-04-27
zeitpunkt: 09:50
status: complete
---

# Hardening-Report V2

Konsolidiert die Forensik vom 2026-04-26 und das anschliessende Hardening durch alle Phasen Pre-1 bis J. Zustand am Ende: Vault-Korruption behoben, Defense-Layer aktiv, alle 13 Files repariert, Watchdog laeuft sauber.

## TL;DR

- Root cause Frontmatter-Korruption identifiziert: Desktop Commander MCP `write_file`/`edit_block` (Pretty-Printer-Roundtrip-Bug, Pattern A `2D 2D 2D 0A 0A 23 23 20`).
- 13 kaputte Files repariert: 10 via git-restore (last-known-good Commits), 3 via algorithmischer Pattern-A-Reparatur (kein git-Vorgaenger).
- Watchdog `_claude/scripts/vault-health-check.ps1` aktiv: erkennt Patterns A, B, C, G plus leere Files plus kaputte Wikilinks. Default 0.5s Scan-Dauer fuer 277 Files.
- Defense-Layer 1 (Auto-Push Pre-Check): integriert in `_migration/auto-push.ps1`, blockiert Push bei SEVERE-Findings.
- Defense-Layer 2 (Manueller Watchdog-Aufruf): dokumentiert in vault-schreibregeln.md.
- Defense-Layer 3 (Skill-Trigger via vault-pruefung): dokumentiert in vault-pruefung.md.
- 11 Skills, 2 Master-Quellen (vault-schreibregeln.md plus vault-schreibkonventionen.md), CLAUDE.md mit prominenter Schreibregeln-Sektion und Sprachregeln.
- Memory aktualisiert: Pointer auf Master-Quellen, kein Inhalts-Duplikat.
- Synthetischer Defense-Test bestanden: Watchdog erkennt synthetisches Pattern A, Pre-Push blockiert, Wikilink-Detection greift.
- Worktrees `elastic-payne-f690b2` und `youthful-buck-a15c3a` entfernt (Branches plus Ordner).

## Phasen-Bilanz

| Phase | Inhalt | Resultat |
|---|---|---|
| Pre-1 | Self-Test des Claude-Code Write-Tools | SAUBER, dokumentiert in `07-self-test.md` |
| 0 bis 4 | Forensik (Vorgeschichte, Bug-Scan, Reproducer, Hypothesen-Test) | Root cause bewiesen, dokumentiert in `REPORT.md` |
| A | Skill-Audit | 11 Skills auditiert, 5 Findings priorisiert in `06-skill-audit.md` |
| B | Reparatur 13 Files | 13/13 sauber (10 git-restore, 3 algo-repair). Backup unter `05-pre-repair-backups/` |
| C | Master-Quellen plus Filesystem-MCP-Test | `vault-schreibregeln.md` und `desktop-commander-frontmatter-bug.md` erstellt. Filesystem-MCP getestet, beide Schreib-Tools SAUBER |
| D | Skill-Updates | Alle 11 Skills mit Verweis auf Master-Quellen. vault-system.md Z.50 Bug-Workaround entfernt |
| E | CLAUDE.md plus START-HERE.md | KRITISCHE VAULT-SCHREIBREGELN plus Sprachregeln Sektionen oben in CLAUDE.md. START-HERE.md nach `_migration/` archiviert |
| F | Watchdog plus Pre-Push-Hook | `vault-health-check.ps1` plus `auto-push.ps1` Integration. Pre-Commit-Hook nicht installiert (Begruendung in Defense-Ebenen) |
| G | Memory-Hardening | Pointer-Eintrag auf Master-Quellen geschrieben (`feedback_vault_writes.md`), MEMORY.md-Index erweitert |
| H | Defense-Tests | Pattern A synth-detection OK, Pre-Push-Block OK, Wikilink-Detection OK, Skill-Konsistenz OK |
| J (dieser Report) | Final-Doku plus Worktree-Cleanup | Worktrees weg, Report geschrieben |

## Reparierte Files (13)

### Via git restore (10)

| File | Last-Good-Commit | Datum | Bytes vorher | Bytes nachher |
|---|---|---|---|---|
| `03-kontakte/christian-pulse.md` | 1494c8b4 | 2026-04-17 10:47 | 696 | 715 |
| `03-kontakte/kai-pulse.md` | 90ef09f6 | 2026-04-20 23:06 | 587 | 606 |
| `03-kontakte/german-pulse.md` | 1494c8b4 | 2026-04-17 10:47 | 626 | 644 |
| `03-kontakte/patrick-pulse.md` | 1494c8b4 | 2026-04-17 10:47 | 604 | 622 |
| `03-kontakte/lizzi-pulse.md` | 1494c8b4 | 2026-04-17 10:47 | 565 | 583 |
| `01-projekte/pulsepeptides/knowledge-base/lab-peptides.md` | cffc4bbc | 2026-04-24 21:18 | 42872 | 44119 |
| `01-projekte/pulsepeptides/pulsepeptides.md` | cffc4bbc | 2026-04-24 21:18 | 5546 | 4969 |
| `01-projekte/pulsepeptides/knowledge-base/bestellprozess.md` | cffc4bbc | 2026-04-24 21:18 | 1116 | 1160 |
| `01-projekte/coralate/coralate.md` | 6172afab | 2026-04-20 15:00 | 4205 | 4293 |
| `01-projekte/coralate/cora-ai/cora-ai.md` | f7bbc32b | 2026-04-25 19:48 | 4225 | 4287 |

### Via algorithmische Pattern-A-Reparatur (3)

Files ohne pre-corruption git-Vorgaenger. Reparatur-Skript: `09-repair-batch3.ps1`. Algorithmus: Pattern-A-Erkennung, Flat-FM-Tokenize, Multi-Line-YAML-Rekonstruktion, Wikilink-Array-Fixup.

| File | Keys parsed | Bytes vorher | Bytes nachher |
|---|---|---|---|
| `01-projekte/pulsepeptides/knowledge-base/zy-peptides.md` | 16 | 14362 | 14361 |
| `01-projekte/pulsepeptides/clickup-pulse-entwurf.md` | 8 | 10296 | 10032 |
| `01-projekte/coralate/cora-ai/meeting-2026-04-26-weekly.md` | 13 | 4096 | 4107 |

## Defense-Layer

### Layer 1: Auto-Push Pre-Check
- Skript: `_migration/auto-push.ps1`
- Modus: `vault-health-check.ps1 -Full -FailOnBugs`
- Trigger: Windows Scheduled Task, alle 6 Stunden
- Verhalten: bei SEVERE-Findings keinen `git push`, Log-Eintrag in `_migration/auto-push.log`, Exit 0 (Scheduled Task sieht Run als erfolgreich an)

### Layer 2: Manueller Watchdog
- Skript: `_claude/scripts/vault-health-check.ps1`
- Aufruf: `powershell -ExecutionPolicy Bypass -File _claude/scripts/vault-health-check.ps1 -Full`
- Output: Console plus Markdown-Report in `_claude/scripts/vault-health-reports/YYYY-MM-DD-HHMM.md`
- Modi: `-Quick` (nur Pattern A, ~200ms), `-Full` (alle Patterns, ~500ms), `-FailOnBugs` (CI-Mode mit Exit-Code)

### Layer 3: Skill-Trigger via vault-pruefung
- Skill: `_claude/skills/vault-pruefung.md` Sektion 3
- Trigger: Deniz sagt "vault pruefen" / "lint"
- Watchdog ist Teil des wochentlichen Vault-Audits

### Pre-Commit-Hook (NICHT installiert)
- Vorlage: `_claude/scripts/pre-commit-hook.sh.example`
- Begruendung fuer Nicht-Installation: Auto-Push Pre-Check (Layer 1) deckt den Use-Case ab ohne Pre-Commit-Hook-Nervigkeit bei Massen-Commits

## Erkannte Patterns

| ID | Was | Watchdog |
|---|---|---|
| A | Frontmatter zu `## ` Heading kollabiert (Hex `2D 2D 2D 0A 0A 23 23 20`) | erkennt |
| B | Multi-Line-YAML zu Single-Line kollabiert (flat-FM) | erkennt (strikte Heuristik: 0-1 linestart-keys plus 4+ total-keys) |
| C | Wikilink-Array kaputt (Backslash-Escape, fehlende Quotes) | erkennt |
| D | Backslash-Escapes auf `[`, `]`, `~` | nicht produktiv (zu viele FPs in Markdown) |
| E | Tabellen kollabiert | nicht produktiv (zu viele FPs) |
| F | LF-only EOL | nicht produktiv (gemischter Vault) |
| G | Auto-Link in Frontmatter (mailto: oder URL) | erkennt |
| H | Self-Link Body | nicht produktiv |
| - | Leere Files (0 Bytes oder nur FM) | erkennt als WARN |
| - | Wikilinks `[[]]` und Unbalanced `[[`/`]]` | erkennt als WARN, Code-Spans gestripped |

## Filesystem-MCP-Test (Phase C)

Manuell durch Deniz im Claude-Desktop-Chat ausgefuehrt am 2026-04-26.

| Tool | Status | Beleg |
|---|---|---|
| `Filesystem:write_file` | SAUBER | 502 Bytes Output, Pattern A negativ, Wikilinks intakt, Umlaute UTF-8 korrekt |
| `Filesystem:edit_file` | SAUBER, sogar besser | Git-style Diff, chirurgischer Edit ohne Full-Rewrite |
| `Filesystem:edit_text_file` | nicht verfuegbar | N/A in Anthropic-Filesystem-MCP |

Konsequenz: Filesystem-MCP wurde in vault-schreibregeln.md als bevorzugte Schreibmethode aufgenommen.

## Watchdog Final-Status

```
Files gescannt: 277
Dauer: 0.5 Sekunden
SEVERE (Korruption):  0
WARN (leer/Wikilink): 7
```

WARN-Bestand bleibt:
- 5 leere Files (0 Bytes): hans-ruediger-kaufmann.md, 2026-03-19-pulse-restrukturierung.md, mitarbeiterführung.md, heiraten-daenemark.md, test-person.md
- 2 EMPTY_BODY (nur Frontmatter): christoph-sandbrink.md, julia-renzikowski.md

Diese Files sind STRUKTURELL verdaechtig aber nicht durch Desktop-Commander-Bug korrupiert. Deniz entscheidet ob loeschen, befuellen oder ignorieren.

## Verbleibende Risiken

| Risiko | Bewertung | Mitigation |
|---|---|---|
| Desktop-Commander-Bug existiert weiter | hoch wenn Tool benutzt wird | Verboten in vault-schreibregeln.md plus CLAUDE.md plus Memory plus 11 Skills |
| Pattern-Detection unvollstaendig (E, F, H nicht produktiv) | mittel | Pattern A/C/G fangen die hauefigsten Faelle. E/F/H sind Heuristik-Falle |
| Auto-Push-Watchdog blockiert nur, alarmiert nicht aktiv | niedrig | Log in auto-push.log. Bei Bedarf spaeter Notification-Mechanik |
| Memory-Cache-Vergiftung wenn neuer Chat den Bug ignoriert | niedrig | CLAUDE.md hat Schreibregeln in den ersten 50 Zeilen, bei Vault-Start automatisch im Kontext |
| Pre-Corruption-git-Versionen koennten selbst korrupt gewesen sein | niedrig | Hex-Verify aller restorierten Files passt, alle Pattern A negativ |

## Monatliche Verify-Routine

Empfehlung an Deniz:

1. Einmal pro Monat: `powershell -File _claude/scripts/vault-health-check.ps1 -Full`. Wenn 0 SEVERE: gut.
2. Bei Skill- oder Konventions-Aenderungen: vault-schreibregeln.md und vault-schreibkonventionen.md auf Konsistenz mit den Skills pruefen.
3. Jeden zweiten Monat: Master-Quellen-Versionen pruefen (Pattern-Liste vollstaendig? Tool-Liste aktuell?).
4. Bei neuen MCP-Tools im Claude-Desktop oder Claude-Code: Filesystem-MCP-Test (Schritt aus Phase C) als Smoke-Test wiederholen.

## Was Deniz selbst tun muss

1. Coralate-Chat und andere parallele Claude-Desktop-Sessions: KEINE Desktop-Commander `write_file`/`edit_block` mehr fuer Vault-Files. Prefer Filesystem-MCP.
2. Optional: Desktop-Commander-Extension komplett deaktivieren via Claude-Desktop UI > Extensions Tab > toggle off `Desktop Commander`. Nur wenn nicht anderweitig gebraucht.
3. Monatliche Verify-Routine in den Kalender (oder Skill-Trigger "vault pruefen" weekly).
4. Bei kommenden Auto-Push-Blocks: in `_migration/auto-push.log` schauen, Findings reparieren (manuell oder via repair-Skript), dann Auto-Push laesst wieder durch.
5. Die WARN-Files (leere Files, EMPTY_BODY) entscheiden: loeschen oder befuellen.

## Forensik-Artefakte

Alle unter `_claude/scripts/forensik-2026-04-26/`:

| Datei | Inhalt |
|---|---|
| `00-vorgeschichte.md` | Phase 0 Vorgeschichte |
| `01-forensik.md` | Phase 1 System-Forensik |
| `02-bug-scan-final.csv` | Phase 2 Bug-Scan |
| `02-bug-summary.md` | Phase 2 Cluster |
| `02-vault.bundle` | Git-Bundle Backup |
| `03-T1-result.md` | Phase 3 Reproducer T1 |
| `03-T1-watch.log`, `03-T2-watch.log` | Watch-Logs |
| `06-skill-audit.md` | Phase A Skill-Audit |
| `07-self-test.md` | Phase Pre-1 Self-Test |
| `08-pre-repair-analysis.json` | Phase B Pre-Repair Daten |
| `09-repair-batch3.ps1` | Phase B Algo-Repair Skript |
| `05-pre-repair-backups/` | Phase B Backups (13 Files plus ZIP) |
| `bug-scanner-v3.ps1` | Phase 2 Forensik-Scanner |
| `repair-frontmatter.ps1` | Phase B Vorgaenger-Skript (durch Batches ersetzt) |
| `verify-self-test.ps1` | Phase Pre-1 Verify |
| `test-files/` | Filesystem-MCP-Test-Material |
| `filesystem-mcp-test-instructions.md` | Phase C Anleitung fuer Deniz |
| `REPORT.md` | Forensik-Vollbericht |
| `HARDENING-REPORT-V2.md` | dieser Report |

## Verweise

- `02-wissen/vault-schreibkonventionen.md` - Master-Quelle Encoding/Naming
- `02-wissen/vault-schreibregeln.md` - Master-Quelle Tools/Verify/Rollback
- `02-wissen/desktop-commander-frontmatter-bug.md` - Bug-Doku
- `_claude/scripts/vault-health-check.ps1` - Watchdog
- `_migration/auto-push.ps1` - Auto-Push mit Pre-Check
- `CLAUDE.md` - Boot-Instruction mit prominenter Schreibregeln-Sektion
