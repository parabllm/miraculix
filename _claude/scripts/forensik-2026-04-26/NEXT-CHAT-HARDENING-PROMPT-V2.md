# MISSION: Vault-Hardening V2 - Konsistente Schreibregeln, CLAUDE.md als Single Entry Point, Skills bombenfest

## Lage

Vault: `C:\Users\deniz\Documents\miraculix\` (Windows 11, PowerShell, Obsidian Desktop, Git, Github `parabllm/miraculix`)

Phase A Audit (forensik-2026-04-26/06-skill-audit.md) hat 5 kritische Findings ergeben:
1. **vault-system.md Z.50 empfiehlt aktiv den Bug-Tool-Pfad** (`write_file mode: append` als Umlaut-Workaround) - Risiko 5
2. Alle 7 Schreib-Skills sind tool-agnostisch - Risiko 4
3. CLAUDE.md hat keine Schreibregeln und keinen Verweis - Risiko 4
4. Worktrees haben veraltete Skill-Kopien
5. vault-pruefung.md hat keinen Frontmatter-Watchdog

Plus: Umlauten-Hinweise stehen im schreibstil.md und vault-system.md, aber NICHT in CLAUDE.md. Konsequenz: Claude Code liest CLAUDE.md beim Vault-Start automatisch, sieht aber nichts ueber Umlaute oder Schreibregeln. Erst beim Skill-Trigger.

**Auftrag:** System bombenfest machen, mit CLAUDE.md als Single Entry Point, Skills als Detail-Quelle, alle Schreibregeln (Frontmatter, Tools, Umlaute, Wikilinks) konsistent ueberall verankert.

## Zu bearbeitende Surface

### Vault-Root (Always-On fuer Claude Code)
```
CLAUDE.md          (Single Entry Point, wird beim Vault-Start geladen)
START-HERE.md      (Migrations-Doku, vermutlich nicht mehr relevant)
```

### Skills (Account-Level, Always-On in Claude Desktop bzw. on-trigger in Claude Code)
```
_claude/skills/
  vault-system.md           (Always-On Foundation)
  schreibstil.md            (Always-On fuer Vault-Writes)
  abgleich.md
  audio-verarbeiten.md
  drive-eingang-holen.md
  eingang-verarbeiten.md
  log.md
  tages-start.md
  transkript-verarbeiten.md
  vault-pruefung.md
  wissens-destillation.md
```

### Worktrees (Tot, sollen weg)
```
.claude/worktrees/elastic-payne-f690b2/   (Snapshot 19.04.2026, read-only)
.claude/worktrees/youthful-buck-a15c3a/   (Snapshot 18.04.2026, read-only)
```
Beide sind nicht als git worktrees registriert (`git worktree list` leer), also einfach tote Ordner-Klone. Vermutlich Artefakte eines alten Claude-Code-Runs mit `--worktree` Flag. Sind veraltet (audio-verarbeiten und transkript-verarbeiten fehlen, Inhalte 8 Tage alt).

### Master-Quelle (neu)
```
02-wissen/vault-schreibregeln.md            (kanonische Schreibregeln)
02-wissen/desktop-commander-frontmatter-bug.md  (Bug-Doku)
```

### Backups noetig
```
_claude/scripts/forensik-2026-04-26/05-pre-repair-backups/
```

## Aufgaben in dieser Reihenfolge

### Phase Pre-1: Self-Test des eigenen Write-Tools

Bevor irgendein Schreibvorgang stattfindet (auch nicht der Audit-Report).

1. Schreibe `_claude/scripts/forensik-2026-04-26/test-self-write.md` mit deinem Standard-Write-Tool (das du sonst auch verwenden wuerdest fuer Skills).
   Inhalt:
   ```
   ---
   typ: test
   datum: 2026-04-26
   teilnehmer: ["[[deniz]]", "[[test-person]]", "Externe Person"]
   tasks:
     - "Task A mit ~3h"
     - "Task B mit Backslash"
   email: "test@example.com"
   tags: [a, b, c]
   ---
   
   # Test
   
   > Block-Quote mit ~Tilde~ und [Brackets].
   
   | Kanal | Wert |
   |---|---|
   | Email | test@example.com |
   
   - [ ] Checkbox
   - [ ] Checkbox 2
   ```

2. Hex-Verify: erste 30 Bytes muessen sein `2D 2D 2D 0A 74 79 70 3A` oder `2D 2D 2D 0D 0A 74 79 70 3A`. NICHT `2D 2D 2D 0A 0A 23 23`.

3. Volltext-Check: keine `\[`, `\]`, `\~`, `\"` Escapes wo keine sein sollten. Tabellen-Zeilen mit Newline.

4. Ergebnis dokumentieren in `forensik-2026-04-26/07-self-test.md`. Outcome:
   - **SAUBER:** dein Write-Tool ist OK, hex-verify nach jedem Write trotzdem Pflicht
   - **KAPUTT:** sofort auf PowerShell `[System.IO.File]::WriteAllBytes` switchen fuer alle weiteren Writes, dokumentieren welches Tool genau betroffen ist
   - **TEILBUG:** dokumentieren was genau passiert, im Zweifel auf PowerShell

### Phase B: Reparatur 13 kaputte Files

DRY-RUN parallel zu Phase C/D moeglich, Apply erst nach C done.

1. Frische Liste via `vault-health-check.ps1` oder `bug-scanner-v3.ps1`.

2. Backup VOR Reparatur in `forensik-2026-04-26/05-pre-repair-backups/` (zip plus einzeln pro File).

3. DRY-RUN: alle 13 Files mit Vorher-Nachher-Hex und rekonstruierten Wikilink-Werten. Bei Wikilinks pro File Deniz-Freigabe.

4. Apply in 3 Batches:
   - Batch 1: 5 Pulse-Kontakte (gleiche Signatur)
   - Batch 2: 8 heterogene Files
   - Batch 3: Pattern-E (lab-peptides plus alle mit kollabierten Tabellen). Hier git history pruefen via `git log -- <file>`, davor-Commit-Body als Quelle, Frontmatter aus reparierter Version. Wenn keine git history: Deniz manuell entscheiden.

5. Hex-Verify nach jedem Write. 60s Stabilitaets-Watch nach allen Writes.

### Phase C: Master-Quelle und Filesystem-MCP-Test

Bevor Skills geaendert werden: kanonische Quelle bauen.

1. **Erstelle `02-wissen/vault-schreibregeln.md`** mit Frontmatter:
   ```yaml
   ---
   typ: wissen
   thema: vault-schreibregeln
   status: aktiv
   erstellt: 2026-04-26
   vertrauen: bestaetigt
   quelle: forensik-2026-04-26
   prioritaet: kritisch
   ---
   ```
   
   Inhalt (in dieser Struktur):
   
   **Sektion 1: Sichere Schreibmethoden**
   - PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 ohne BOM, Code-Beispiel
   - Base64-Pipeline fuer grosse Files, Code-Beispiel
   - Welche MCP-Tools sicher sind (nach Phase-C-Test)
   
   **Sektion 2: Verbotene Schreibmethoden mit Begruendung**
   - `Desktop Commander:write_file` fuer .md mit YAML-Frontmatter (BUG: Pretty-Printer-Roundtrip)
   - `Desktop Commander:edit_block` fuer .md mit YAML-Frontmatter (zu testen, vermutlich gleiche Engine)
   - Filesystem MCP Tools (zu testen, Ergebnis hier eintragen)
   - Hex-Pattern-Beispiele Vorher-Nachher (Pattern A bis H)
   
   **Sektion 3: Pflicht-Verify**
   - Erste 50 Bytes hex-pruefen nach jedem Write
   - Erwartetes Pattern: `2D 2D 2D 0A` oder `2D 2D 2D 0D 0A` gefolgt von erstem YAML-Key
   - Verbotenes Pattern: `2D 2D 2D 0A 0A 23 23` (Pattern A)
   - Code-Beispiel des Verify-Snippets
   
   **Sektion 4: Umlaut-Regeln**
   - In .md Files: ä ö ü ß als UTF-8 Pflicht
   - In PowerShell-Strings: ASCII (ae oe ue ss) wenn Encoding fragwuerdig
   - Verbot: nie ae oe ue ss in .md Files
   - Pfade mit Umlauten (z.B. `01-projekte/persönlich/`): mit Bewusstsein behandeln, hex-verify nach Write
   
   **Sektion 5: Wikilink-Regeln**
   - Format `[[dateiname]]` ohne Anfuehrungszeichen im Inline
   - Format `["[[name]]", "[[other]]"]` in YAML-Arrays MIT Anfuehrungszeichen
   - Verbot: leere Wikilinks `[[]]`, ungeschlossene `[[name`, falsche Anfuehrungszeichen
   
   **Sektion 6: Rollback-Verfahren**
   - Wie aus pre-repair-backups wiederherstellen
   - Wie git history nutzen (`git show <commit>:<path>`)

2. **Erstelle `02-wissen/desktop-commander-frontmatter-bug.md`** mit Bug-Doku:
   - Hex-Pattern-Beispiele (Vorher-Nachher mit Klartext)
   - Forensik-Beweis (Verweis auf REPORT.md)
   - Affected Tools (Desktop Commander bestaetigt; Filesystem MCP zu testen)
   - Reparatur-Skript-Pfad
   - Praeventions-Strategie

3. **Filesystem-MCP-Test ueber Deniz (er ist im Claude Desktop Chat).**
   - Praepariere Test-Datei `_claude/scripts/forensik-2026-04-26/test-files/filesystem-mcp-test-input.md` mit dem gleichen Stress-Frontmatter wie Self-Test
   - Praepariere `filesystem-mcp-test-instructions.md` mit:
     - Welches Tool soll Deniz im Claude-Desktop-Chat aufrufen (Filesystem:write_file, Filesystem:edit_file, Filesystem:edit_text_file)
     - Welche Inhalte schreiben
     - Erwartete vs. kaputte Hex-Patterns
     - Wie Resultat reporten
   - Zeige Deniz beide Files und sag "Bitte fuehre diese Tests im Claude-Desktop-Chat aus und gib mir die Hex-Outputs zurueck"
   - Trage Test-Resultate in `vault-schreibregeln.md` Sektion 2 (Verbotene/Erlaubte Tools) und in `desktop-commander-frontmatter-bug.md` ein

### Phase D: Skill-Updates (alle 11 Skills referenzieren Master)

Prinzip: Master-Quelle ist `02-wissen/vault-schreibregeln.md`. Skills referenzieren, kopieren nicht. Vermeidet Drift.

**Wichtigste Aenderung zuerst:** vault-system.md Z.50 (gefaehrlicher Workaround) entfernen.

1. **`vault-system.md`** (Risiko 5):
   - Z.50 Umlaut-Workaround `write_file mit mode: append` LOESCHEN
   - Stattdessen: Verweis auf `02-wissen/vault-schreibregeln.md` Sektion Umlaut-Regeln
   - Neue Sektion ganz oben (vor "Ordnerstruktur"): "VAULT-SCHREIBREGELN (PFLICHT)" mit 3-Zeilen-TLDR plus Verweis auf vault-schreibregeln.md
   - 3-Zeilen-TLDR muss enthalten: 
     - "NIE Desktop Commander write_file fuer .md mit YAML-Frontmatter"
     - "Immer PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 NoBOM verwenden"
     - "Hex-Verify nach jedem Write Pflicht. Details in `02-wissen/vault-schreibregeln.md`"

2. **`schreibstil.md`** (gut, aber konsolidieren):
   - Pruefen ob Umlaut-Hinweise konsistent zu vault-schreibregeln.md
   - Verweis auf vault-schreibregeln.md fuer technische Schreibregeln (Stil bleibt hier, Tools dort)

3. **Schreib-Skills (`log.md`, `eingang-verarbeiten.md`, `audio-verarbeiten.md`, `transkript-verarbeiten.md`, `abgleich.md`, `wissens-destillation.md`, `tages-start.md`, `drive-eingang-holen.md`)**:
   - Pro Skill: Sektion "Vault-Writes" am Ende mit Verweis auf vault-schreibregeln.md
   - Wenn der Skill File-Operations beschreibt: explizit PowerShell-Methode dokumentieren oder auf Master verweisen
   - KEIN Skill darf einen unsicheren Tool-Pfad empfehlen

4. **`vault-pruefung.md`**:
   - Erweitern um Pflicht-Check der Frontmatter-Patterns A bis H (nutzt vault-health-check.ps1)
   - Plus: leere Files (size < 50 Bytes), kaputte Wikilinks
   - Verweis auf vault-schreibregeln.md

### Phase E: CLAUDE.md als Single Entry Point

Das ist Deniz' explizite Forderung: alles Wichtige soll in CLAUDE.md stehen damit Claude Code es beim Vault-Start automatisch im Kontext hat.

1. **CLAUDE.md** (Vault-Root) ueberarbeiten:
   - Neue Sektion ganz am Anfang nach "Identitaet": **"KRITISCHE VAULT-SCHREIBREGELN (PFLICHT, immer beachten)"**
     - 3-Zeilen-TLDR (siehe vault-system.md oben)
     - Verweis auf `02-wissen/vault-schreibregeln.md` fuer Details
     - Sektion "Was Claude NIE schreiben darf":
       - `Desktop Commander:write_file`/`edit_block` fuer .md mit YAML-Frontmatter
       - Filesystem MCP write_file/edit_file (falls Phase-C-Test KAPUTT zeigt)
       - Auto-Reformatierung von YAML
       - Tabellen-Manipulation ohne Backup
     - Klare Konsequenz-Anweisung: "Bei Verstoss: Datenverlust moeglich. Bei Unsicherheit: erst Deniz fragen."
   
   - Neue Sektion "**Sprachregeln**" nach den Schreibregeln:
     - Deutsche Inhalte mit echten Umlauten ä ö ü ß (UTF-8)
     - Verbot ae oe ue ss in .md Files
     - Ausnahme: Git-Commit-Messages und PowerShell-Strings ASCII
     - Keine Gedankenstriche (em/en dash), Verweis auf schreibstil.md fuer den Rest
   
   - Existierende Sektion "Was Claude NICHT tun soll" um die neuen Punkte erweitern (oder mit Schreibregeln-Sektion mergen)
   
   - Verweise auf alle Skills aktuell halten (audio-verarbeiten und transkript-verarbeiten in der Operations-Skills-Tabelle ergaenzen falls fehlen)

2. **START-HERE.md**:
   - Pruefen ob noch relevant. Ist Migration-Setup-Doku, Migration ist erledigt.
   - Vorschlag: nach `_migration/` verschieben oder archivieren
   - Falls bleibt: Verweis auf vault-schreibregeln.md ergaenzen

### Phase F: Watchdog plus Pre-Commit-Hook

1. `_claude/scripts/vault-health-check.ps1` finalisieren:
   - Scant alle .md Files
   - Erkennt Patterns A bis H (Bug-Patterns)
   - Erkennt leere Files (< 50 Bytes oder nur Frontmatter)
   - Erkennt kaputte Wikilinks
   - Exit-Code 0 sauber, > 0 Bugs gefunden
   - Output: Markdown-Report nach `_claude/scripts/vault-health-reports/YYYY-MM-DD.md`

2. Pre-Commit-Hook `.git/hooks/pre-commit`:
   - Ruft vault-health-check.ps1 auf
   - Blockiert Commits wenn neue Bugs eingefuehrt wurden (Diff zu vorigem Commit)
   - Bypass via `git commit --no-verify` mit Warnung
   - Vor Setup Deniz fragen ob er das will (manche User wollen keine Pre-Commit-Hooks)

3. Dokumentation in vault-schreibregeln.md.

### Phase G: Memory-Hardening

1. `memory_user_edits view`.

2. Sicherstellen, KEINE Redundanz zu Skills:
   - Behalte: existierende Memory-Eintraege (Desktop-App-Hinweis, Gedankenstriche-Verbot, Umlauten-Regel, Vault-Write-Regel)
   - Pruefe: Vault-Write-Regel in Memory ist konsistent zu vault-schreibregeln.md (Memory ist Pointer, nicht Kopie)
   - Falls Memory mehr enthaelt als noetig fuer Pointer-Funktion: kuerzen

3. Memory-Eintrag soll sagen: "Wenn im Miraculix-Vault, lies `02-wissen/vault-schreibregeln.md` und befolge die Regeln dort. Niemals Desktop Commander write_file fuer .md mit YAML-Frontmatter."

### Phase H: Worktree-Cleanup

1. Pruefe nochmal ob die zwei Worktrees was Einzigartiges enthalten (Diff zu Haupt-Vault). Erwartung: sind nur 8 Tage alte Snapshots, alles drin ist auch im Haupt-Vault aber neuer.

2. Falls einzigartig: rausziehen, Diff zeigen, Deniz entscheiden.

3. Falls nichts einzigartig: loeschen via PowerShell (nicht git worktree remove, weil sind keine echten worktrees):
   ```powershell
   Remove-Item -Recurse -Force "C:\Users\deniz\Documents\miraculix\.claude\worktrees\elastic-payne-f690b2"
   Remove-Item -Recurse -Force "C:\Users\deniz\Documents\miraculix\.claude\worktrees\youthful-buck-a15c3a"
   Remove-Item "C:\Users\deniz\Documents\miraculix\.claude\worktrees" -ErrorAction SilentlyContinue
   ```
   Falls Ordner read-only: erst attrib, dann remove.

### Phase I: Synthetischer Defense-Test

1. Korruptions-Versuch: Schreibe `_claude/scripts/forensik-2026-04-26/test-defense.md` via `Desktop Commander:write_file` mit komplexem Frontmatter. Pruefe:
   - Wird sie kaputt geschrieben? (sollte ja)
   - Wird sie vom Watchdog erkannt? (sollte ja)
   - Wuerde Pre-Commit-Hook blockieren? (testen mit echtem Commit-Versuch)

2. Skill-Konsistenz-Test: Lies `vault-system.md` und CLAUDE.md, pruefe ob die Schreibregeln-Sektion in den ersten 50 Zeilen steht (Top-of-Mind-Test).

3. Cross-Reference-Test: Pruefe ob jeder Skill der File-Ops macht, einen Verweis auf `vault-schreibregeln.md` hat.

4. Wikilink-Validation-Test: Bewusst kaputte Wikilinks in einer Test-Datei, vault-pruefung.md erkennt sie?

5. Test-Files am Ende loeschen, Test-Output behalten.

### Phase J: Final-Report

`forensik-2026-04-26/HARDENING-REPORT-V2.md`:
- Self-Test-Ergebnis (Phase Pre-1)
- Reparatur-Resultate (Phase B)
- Master-Quelle und Filesystem-MCP-Test-Ergebnis (Phase C)
- Skill-Aenderungen (Phase D, E)
- Defense Layer (Phase F, G)
- Worktree-Cleanup (Phase H)
- Test-Resultate (Phase I)
- Liste verbleibender Risiken
- Was Deniz selbst tun muss
- Monatliche Verify-Routine

## Constraints

- **Plan-and-Execute strikt:** Vor jeder Phase Plan zeigen, dann ausfuehren. Bei destructive actions explizite Freigabe pro Batch.

- **Self-Test ist Pflicht.** Phase Pre-1 vor allem anderen. Wenn dein Tool den Bug hat, switchst du sofort. Ohne Self-Test wird die Mission gefaehrlich.

- **Echte Umlaute in .md Files.** ä ö ü ß als UTF-8 Pflicht. ASCII (ae oe ue ss) nur in PowerShell-Strings wo Encoding fragwuerdig.

- **Keine Gedankenstriche** im Output. Komma, Punkt, normaler Bindestrich.

- **Keine Redundanz:** vault-schreibregeln.md ist Master. Skills und CLAUDE.md verweisen, kopieren NICHT. Memory ist Pointer.

- **Hex-Verify nach JEDEM File-Write.** Erste 30-50 Bytes pruefen. Ohne Ausnahme.

- **Worktrees zuerst pruefen, dann loeschen.** Nicht blind weg.

- **Filesystem-MCP-Test laeuft ueber Deniz.** Du kannst die Tools nicht direkt aufrufen (du bist Claude Code, nicht Claude Desktop). Praepariere klar was er tun soll.

## Erfolgskriterien

1. Alle 13 kaputten Files sind repariert mit Hex-Verify
2. `02-wissen/vault-schreibregeln.md` existiert als kanonische Master-Quelle
3. `02-wissen/desktop-commander-frontmatter-bug.md` dokumentiert den Bug
4. Filesystem-MCP-Test-Resultat ist dokumentiert (durch Deniz ausgefuehrt)
5. CLAUDE.md hat prominente Schreibregeln-Sektion und Sprachregeln-Sektion
6. vault-system.md Z.50 Bug-Workaround ist entfernt
7. Alle 11 Skills haben Verweis auf vault-schreibregeln.md (kein Widerspruch)
8. Watchdog-Skript existiert und funktioniert
9. Pre-Commit-Hook ist eingerichtet (oder bewusst nicht, dokumentiert)
10. Memory-Eintraege sind Pointer, nicht Kopien
11. Worktrees sind weg (oder mit Begruendung behalten)
12. Synthetischer Defense-Test in Phase I beweist dass alle Layer greifen

## Hinweise zum Stil

- Normale Saetze, keine Bullet-Walls.
- Direkte Sprache, kein Smalltalk.
- Tabellen wo Vergleiche sinnvoll.
- Bei Ungewissheit: explizit "unklar weil...".
- Sparringspartner: bei Zweifeln widersprechen mit Begruendung.
- Bei jeder Phase Tool-Call-Schaetzung vorab nennen.