---
typ: backup-manifest
datum: 2026-04-26
zeitpunkt: 22:39:48
phase: B-pre-repair
---

# Pre-Repair Backup-Manifest

| # | Pfad | Bytes | SHA256 | mtime |
|---|---|---|---|---|
| 1 | `03-kontakte\christian-pulse.md` | 696 | 6084AA79329F3F3C... | 2026-04-25 20:51:44 |
| 2 | `03-kontakte\kai-pulse.md` | 587 | 0507C163452A27DE... | 2026-04-25 20:52:09 |
| 3 | `03-kontakte\german-pulse.md` | 626 | 7EAEA8A9067349E9... | 2026-04-25 20:52:15 |
| 4 | `03-kontakte\patrick-pulse.md` | 604 | 66BD53B9103E0075... | 2026-04-25 20:52:42 |
| 5 | `03-kontakte\lizzi-pulse.md` | 565 | F34D25A5D7C7010C... | 2026-04-25 20:52:48 |
| 6 | `01-projekte\pulsepeptides\knowledge-base\zy-peptides.md` | 14362 | 00C6CBB47ADEE63A... | 2026-04-26 16:58:40 |
| 7 | `01-projekte\pulsepeptides\knowledge-base\lab-peptides.md` | 42872 | AD128926536D68FC... | 2026-04-26 17:00:55 |
| 8 | `01-projekte\pulsepeptides\pulsepeptides.md` | 5546 | 5B9B2835F73C6CE8... | 2026-04-26 17:16:07 |
| 9 | `01-projekte\pulsepeptides\knowledge-base\bestellprozess.md` | 1116 | 11D4058ECBDBC531... | 2026-04-26 17:19:16 |
| 10 | `01-projekte\pulsepeptides\clickup-pulse-entwurf.md` | 10296 | 160235CE9CBA0505... | 2026-04-26 17:19:21 |
| 11 | `01-projekte\coralate\coralate.md` | 4205 | CF103F86106F896A... | 2026-04-26 20:22:49 |
| 12 | `01-projekte\coralate\cora-ai\cora-ai.md` | 4225 | DC8E318249F98218... | 2026-04-26 20:24:17 |
| 13 | `01-projekte\coralate\cora-ai\meeting-2026-04-26-weekly.md` | 4096 | 419745968B176E82... | 2026-04-26 21:33:07 |

## Wiederherstellung

Per File:
```powershell
$src = "_claude/scripts/forensik-2026-04-26/05-pre-repair-backups/<filename>__<...>.md"
$dst = "<original-path>"
Copy-Item $src $dst -Force
```