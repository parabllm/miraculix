---
typ: forensik
phase: 2
datum: 2026-04-26
zeitpunkt: 20:10
---

# Phase 2 - Vault-weiter Bug-Scan

## Zusammenfassung

633 .md Files gescannt. **10 Files mit definitiver Strukturkorruption** (Pattern A, C oder G). Plus diverse weitere mit Pattern E (Tabellen-Heuristik) - davon viele False Positives, einige echte Korruption.

## Definitiv kaputte Files (10 Files)

Sortiert nach Last-Modified-Time. Alle haben Pattern A (Frontmatter ## Prefix) oder G (Auto-Link in Frontmatter) oder C (Wikilink-Array kaputt).

### Cluster A - 25.04.2026 20:51-20:53 (5 Files in 64 Sekunden)

Pulse-Kontakt-Files. Massen-Edit-Pattern. Pattern A + C. 8 Backslash-Escapes pro File.

| Pfad | mtime |
|---|---|
| `03-kontakte/christian-pulse.md` | 2026-04-25 20:51:44 |
| `03-kontakte/kai-pulse.md` | 2026-04-25 20:52:09 |
| `03-kontakte/german-pulse.md` | 2026-04-25 20:52:15 |
| `03-kontakte/patrick-pulse.md` | 2026-04-25 20:52:42 |
| `03-kontakte/lizzi-pulse.md` | 2026-04-25 20:52:48 |

### Cluster B - 26.04.2026 16:58-17:19 (5 Files in 21 Minuten)

PulsePeptides-Files. Aktiv heute, parallel zu Obsidian-Aktivitaet.

| Pfad | A | C | G | mtime |
|---|---|---|---|---|
| `01-projekte/pulsepeptides/knowledge-base/zy-peptides.md` | 1 | 0 | 0 | 2026-04-26 16:58:40 |
| `01-projekte/pulsepeptides/knowledge-base/lab-peptides.md` | 0 | 0 | **1** | 2026-04-26 17:00:55 |
| `01-projekte/pulsepeptides/pulsepeptides.md` | 1 | 1 | 0 | 2026-04-26 17:16:07 |
| `01-projekte/pulsepeptides/knowledge-base/bestellprozess.md` | 1 | 0 | 0 | 2026-04-26 17:19:16 |
| `01-projekte/pulsepeptides/clickup-pulse-entwurf.md` | 1 | 0 | 0 | 2026-04-26 17:19:21 |

`lab-peptides.md` hat KEIN Pattern A aber Pattern G (`email: "[lily@x.com](mailto:lily@x.com)"`) plus per git-diff bestaetigte Tabellen-Kollabierung. Andere Korruptions-Variante als Cluster A.

## Cluster-Histogramm (ohne Worktrees)

| Stunde | Files | Bewertung |
|---|---|---|
| 2026-04-16 19-23 | 11 | Vault-Init-Phase, Pattern E sind vermutlich False Positives (CamelCase in Eigennamen) |
| 2026-04-17 09-13 | 2 | normale Edits |
| 2026-04-19 19 - 2026-04-21 12 | 9 | normale Edits |
| 2026-04-23 16-17 | 4 | normale Edits |
| **2026-04-24 21** | **18** | **VERDACHT - moeglicher dritter Korruptions-Cluster, aber Pattern E ist unzuverlaessig** |
| 2026-04-25 13-14 | 4 | Cleanup-Phase 2 |
| 2026-04-25 19 | 5 | Cleanup-Phase 3 (sauber laut commits) |
| **2026-04-25 20** | **5** | **Cluster A (Pulse-Kontakte) - bestaetigt kaputt** |
| **2026-04-26 16-17** | **13** | **Cluster B - bestaetigt kaputt (5 Files), 8 Pattern-E-Verdacht** |

## Pattern-E-Heuristik

Die "kollabierte Tabellen"-Heuristik (Pattern E: 4+ aufeinanderfolgende Capital-Worte ohne Trenner) hat **viele False Positives**: Eigennamen wie "WordPress", "WooCommerce", "PulsePeptides" etc. werden faelschlich erkannt. Die 55 Files mit nur Pattern E sind UNZUVERLAESSIG, brauchen manuelle Pruefung.

`lab-peptides.md` hat Pattern E + G und ist bestaetigt kaputt. Andere Pattern-E-Files muessen einzeln per git-diff verifiziert werden.

## Pattern-Kombinationen (Forensik-Daten)

Alle 5 Cluster-A-Files haben **identische** Bug-Signature:
- Pattern A=1, C=1, D_brackets=8, G=0, E=0, F=1 (LF-only)
- Header: `---\n\n## typ: kontakt name: "..."`
- Wikilink-Array kaputt: `\[[pulsepeptides]]"\]`
- 8 Backslash-Escapes (4x `\[` + 4x `\]`)

Cluster B ist **heterogener**:
- `zy-peptides.md`, `pulsepeptides.md`, `bestellprozess.md`, `clickup-pulse-entwurf.md`: Pattern A
- `lab-peptides.md`: Pattern G plus E (kein Pattern A!)

Das deutet auf **zwei verschiedene Korruptions-Mechanismen** hin, oder eine Variation derselben Pipeline mit verschiedenen Triggern.

## File-Lock-Beobachtung

Beim Backup-Versuch (Compress-Archive) war `pulsepeptides.md` von einem anderen Prozess gehalten. Diese Datei ist auch in Cluster B (frisch korrupt). Korrelation: Datei wird von einem aktiven Prozess geschrieben.

## Naechste Schritte fuer Phase 3

Reproducer-Test mit:
1. **Frische Test-Datei** in einem isolierten Forensik-Subordner.
2. **T1-T6 Trigger-Variation** wie im Mission-Brief.
3. **Plugin-Isolations-Test (Phase 4)**: Properties + Bases temporaer auf `false` setzen, dann oeffnen-Test.
4. **MCP-Isolations-Test:** Filesystem-MCP und Desktop Commander auf `isEnabled: false` setzen, dann Test.

Insbesondere muss die Frage beantwortet werden: was ist der TRIGGER fuer die Korruption?
- (a) Datei oeffnen in Obsidian
- (b) Tab schliessen
- (c) Obsidian-Start
- (d) Auto-Push-Run
- (e) Anthropic Cowork/CCD interner Scheduler
- (f) Etwas anderes
