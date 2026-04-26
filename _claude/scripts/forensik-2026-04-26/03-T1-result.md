---
typ: forensik
phase: 3
trigger: T1
zeitpunkt: 2026-04-26 20:32:26
---

# T1 - Idle ohne Obsidian (10 Min)

## Setup

- Test-Datei: `_claude/scripts/forensik-2026-04-26/test-files/test-watchdog-T0.md` (890 bytes, UTF-8 ohne BOM, LF)
- Baseline-Hash: `5285F861D9ED8DDC8336ED1B3DF1856CD8E8B73B3BA299F625BFB4BCA7C039F6`
- Baseline-mtime: `2026-04-26 20:21:26`
- Watcher-Intervall: 60s, Dauer 10 Min
- Obsidian-Status: alle 4 Prozesse beendet (verifiziert)
- Claude Desktop-Status: 17+ Prozesse aktiv (cowork-svc PID 17340 inklusive)

## Ergebnis

**0 Aenderungen in 10 Minuten.**

```
20:23:26 - unchanged
20:24:26 - unchanged
20:25:26 - unchanged
20:26:26 - unchanged
20:27:26 - unchanged
20:28:26 - unchanged
20:29:26 - unchanged
20:30:26 - unchanged
20:31:26 - unchanged
20:32:26 - unchanged
T1 ENDED. Total changes: 0
```

Hash blieb identisch ueber alle 10 Pruefungen.

## Beweis-Wert

H8c (Cowork-Background-Watcher der idle laeuft) **WIDERLEGT**: Die Test-Datei liegt im allowed-directory der Filesystem-MCP (`C:\Users\deniz\Documents`) und im Anwendungsbereich des laufenden cowork-svc, wurde aber 10 Minuten nicht angefasst.

Der Korruptions-Trigger ist **NICHT passiv-zeitbasiert** sondern **explicit-aktion-getriggert**.

## Hypothesen-Update

| ID | Status |
|---|---|
| H1 Auto-Push | bereits widerlegt |
| H2 Umlaut-Skript | bereits teilwiderlegt |
| H3 Properties Plugin | UNGEKLAERT (T2-T7 brauchen wir) |
| H4 Bases Plugin | UNGEKLAERT (T2-T7) |
| H5 File-Recovery | unwahrscheinlich |
| H6 OneDrive | bereits widerlegt |
| H7 Community-Plugin | bereits widerlegt |
| H8a Filesystem MCP Roundtrip | UNGEKLAERT - aber mehr unwahrscheinlich (idle ist sicher) |
| H8b Desktop Commander | UNGEKLAERT - aber mehr unwahrscheinlich (idle ist sicher) |
| H8c Cowork-Watcher | **WIDERLEGT** durch T1 |
| H10 Obsidian-Trigger | sehr wahrscheinlich, T2 wird zeigen |

## Naechster Schritt

T2: Obsidian starten ohne irgendeine Datei zu oeffnen. 60s warten. Hex-Diff. Misst ob Obsidian beim Start Files anfasst (z.B. via File-Recovery-Indexierung).
