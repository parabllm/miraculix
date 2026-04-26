---
typ: forensik
phase: A
datum: 2026-04-26
zeitpunkt: 22:05
---

# Phase A - Skill-Audit-Report

## Zusammenfassung

11 Skills geprueft, plus CLAUDE.md, plus START-HERE.md, plus 2 Worktrees mit eigenen Skill-Kopien.

**Zentrale Schwachstelle:** Alle Skills sind **tool-agnostisch** geschrieben. Kein Skill schreibt vor, mit welchem Tool eine .md-Datei zu erzeugen oder zu modifizieren ist. Die AI darf frei waehlen. Bei Desktop-Commander-Wahl entsteht der Korruptions-Bug.

**Konkrete Gefahr:** `vault-system.md` Zeile 50 empfiehlt sogar **explizit** `write_file mit mode: append` als Workaround fuer Umlaut-Probleme - das ist genau der gefaehrliche Tool-Pfad.

## Skill-Tabelle

| Skill | Zweck | File-Ops | Tools erwaehnt | Schreibregeln | Umlaut | Wikilink | Risiko |
|---|---|---|---|---|---|---|---|
| `vault-system.md` | Master-Skill, Always-on | indirekt (Anweisungen) | **`write_file/mode: append`** als Workaround | nein | ja Z.50 | nein | **5** |
| `log.md` | Session-Log schreiben | ja (Log-Files mit FM) | keine | nein | nein | nein | **4** |
| `eingang-verarbeiten.md` | Inbox triage | ja (neue Files plus Updates) | keine | nein | nein | nein | **4** |
| `abgleich.md` | Reconcile Projekt | ja (Updates auf `{slug}.md`) | keine | nein | nein | nein | **4** |
| `transkript-verarbeiten.md` | Meeting-Note erweitern | ja (Updates plus Move) | keine | nein | nein | nein | **4** |
| `tages-start.md` | Daily Note | ja (neue mit FM) | keine | nein | nein | nein | **4** |
| `wissens-destillation.md` | Neue Wissens-Eintraege | ja (mit FM-Template) | keine | nein | nein | nein | **4** |
| `audio-verarbeiten.md` | Audio plus Transkript | indirekt (Python-Skript) | Python plus ffmpeg | nein | nein | nein | 2 |
| `drive-eingang-holen.md` | rclone-Pull | indirekt (rclone) | PowerShell Skript-Aufruf | nein | nein | nein | 2 |
| `schreibstil.md` | Stil-Regeln | nein | nicht relevant | nein | nein | nein | 1 |
| `vault-pruefung.md` | Lint-Bericht | nein (nur Report) | nicht relevant | nein | nein | erwaehnt nur "Kaputte Wikilinks" | 1 |
| `CLAUDE.md` | Boot-Instruction | indirekt | keine | nein | indirekt via Skill-Verweis | nein | 4 |
| `START-HERE.md` | Setup-Guide | n/a | n/a | n/a | n/a | n/a | 1 |

**Risiko-Skala:**
- **5 Kritisch** - empfiehlt aktiv unsicheres Tool
- **4 Hoch** - tool-agnostisch, AI kann unsicheres Tool waehlen
- **3 Mittel** - nicht relevant in Audit
- **2 Niedrig** - delegiert an Hilfsskripte
- **1 Sehr niedrig** - schreibt nichts

## Tool-Erwaehnungen im Detail

| Skill | Zeile | Erwaehnter Tool | Bewertung |
|---|---|---|---|
| `vault-system.md` | 50 | `str_replace`/`edit_block` (Warnung), `write_file mit mode: append` (Empfehlung als Workaround) | **GEFAEHRLICH** - Empfehlung loeschen oder durch PowerShell-Methode ersetzen |
| `vault-system.md` | 177 | `python-dotenv` oder `PowerShell-Loader` fuer .env | OK - betrifft nur .env-Loading |
| `audio-verarbeiten.md` | 19, 99 | `winget install Gyan.FFmpeg`, `PowerShell neu starten` | OK - betrifft nur Setup |
| `drive-eingang-holen.md` | 25 | `powershell -ExecutionPolicy Bypass -File "_claude/scripts/drive-inbox-pull.ps1"` | OK - delegiert an Skript |
| `drive-eingang-holen.md` | 33 | "Claude Desktop App mit MCP (Shell + Filesystem verfuegbar)" | NEUTRAL - dokumentiert Verfuegbarkeit, schreibt nicht selbst |
| `drive-eingang-holen.md` | 39 | "kein Zugriff auf Deniz' lokales Filesystem" | OK - nur Beschreibung |
| `drive-eingang-holen.md` | 46 | `winget install Rclone.Rclone` | OK - Setup |
| `drive-eingang-holen.md` | 3 | "filesystem+shell MCPs" als Voraussetzung | NEUTRAL |

## Inkonsistenzen und veraltete Anweisungen

1. **Umlaut-Workaround in vault-system.md ist gefaehrlich** (siehe oben). Die Forensik vom 26.04 hat bewiesen, dass `write_file` selbst der Bug-Verursacher ist - es ist also keine sichere Alternative zu `str_replace/edit_block`, sondern teilweise der **gleiche Bug-Engine** mit nur anderem Manifest.

2. **Kein Skill referenziert eine zentrale Schreibregel-Quelle.** Es gibt kein `02-wissen/vault-schreibregeln.md` (existiert noch nicht). `02-wissen/vault-schreibkonventionen.md` (von Cleanup-Phase 3) deckt nur Encoding und Umlaute ab, NICHT Tool-Wahl.

3. **`schreibstil.md`** behandelt Stil aber nicht File-Tools. Trennung ist konzeptuell richtig, aber dadurch fehlt eine klare File-Tool-Quelle.

4. **`vault-pruefung.md`** erwaehnt "Kaputte Wikilinks" als Pruefkategorie aber nicht die Frontmatter-Patterns A-H aus der Forensik. Watchdog-Logik fehlt.

5. **Kein Hex-Verify in irgendeinem Skill.** Nach Write-Operations gibt es keine Pflicht-Verifikation der ersten Bytes.

## Worktree-Befund

```
git worktree list:
  C:/Users/.../miraculix                                        cf2a436 [main]
  C:/Users/.../miraculix/.claude/worktrees/elastic-payne-f690b2 6a41150 [claude/elastic-payne-f690b2]
  C:/Users/.../miraculix/.claude/worktrees/youthful-buck-a15c3a 94586c9 [claude/youthful-buck-a15c3a]
```

**Beide Worktrees haben veraltete Skill-Versionen vom 18./19. April:**
- `vault-system.md`: 5385 bytes (vs. 8763 bytes auf main)
- `audio-verarbeiten.md`: **fehlt komplett** (Skill ist erst nach Apr 25 angelegt worden)
- `transkript-verarbeiten.md`: **fehlt komplett**
- CLAUDE.md ist anders (volle 127 Zeilen Diff)

**Risiko:** Wenn Claude Code in einem dieser Worktrees gestartet wird (cd in den Worktree), liest es die alten Skill-Versionen. Diese kennen die neuen Konventionen nicht. Falls die Worktrees noch aktiv sind: muessen entweder synced oder geloescht werden.

**Frage an Deniz:** Sind die Worktrees noch aktiv? Falls nicht: `git worktree remove <pfad>` und Branches loeschen. Falls aktiv: erfordern eigenes Hardening parallel zum Main.

## Top-5-Findings (priorisiert nach Risiko)

| # | Finding | Risiko | Severity | Action in Phase D/E |
|---|---|---|---|---|
| 1 | `vault-system.md` Z.50 empfiehlt `write_file mit mode: append` als Umlaut-Workaround | **5** | kritisch | Zeile umschreiben: PowerShell `WriteAllBytes` als sichere Methode, Verweis auf Master-Schreibregeln |
| 2 | Alle 7 Schreib-Skills sind tool-agnostisch (vault-system, log, eingang-verarbeiten, abgleich, transkript-verarbeiten, tages-start, wissens-destillation) | **4** | hoch | In allen 7 Skills neuen Abschnitt "File-Operations" mit Verweis auf Master-Schreibregeln |
| 3 | CLAUDE.md hat keine Schreibregeln-Sektion und keinen Verweis | **4** | hoch | Phase E: Prominente Sektion "VAULT-SCHREIBREGELN (PFLICHT)" am Anfang |
| 4 | Worktrees haben veraltete Skill-Kopien (18./19. April) - `audio-verarbeiten` und `transkript-verarbeiten` fehlen komplett | **3** | mittel | Phase D Schluss: pruefen ob Worktrees aktiv. Wenn ja: Skills syncen. Wenn nicht: entfernen. Deniz fragen. |
| 5 | `vault-pruefung.md` hat keinen Watchdog-Check fuer Frontmatter-Patterns A-H | **3** | mittel | Phase D + F: Skill um Patterns-Check erweitern, vault-health-check.ps1 als Backend |

## Naechste Schritte

Phase A abgeschlossen, Output saved. Naechster sinnvoller Schritt:

**Vorschlag Reihenfolge** (geaendert vom urspruenglichen Plan):
1. **Phase C zuerst** (Master-Schreibregeln + Filesystem-MCP-Test) - bevor Skills geupdated werden, muss die Master-Quelle stehen, sonst Drift
2. **Phase B Reparatur** (13 kaputte Files) - parallel oder davor sinnvoll, weil Skills jetzt schon teils kaputt sind
3. **Phase D Skill-Updates** - referenziert Master aus Phase C
4. **Phase E** CLAUDE.md - prominente Schreibregeln-Sektion
5. **Phase F** Watchdog plus Pre-Commit-Hook
6. **Phase G** Memory-Hardening
7. **Phase H** Defense-Tests
8. **Phase I** Final-Report

**Frage an Deniz vor Phase B/C:** Sind die Worktrees noch aktiv? (Default: deaktiviert/zu loeschen, da veraltet seit 7+ Tagen.)
