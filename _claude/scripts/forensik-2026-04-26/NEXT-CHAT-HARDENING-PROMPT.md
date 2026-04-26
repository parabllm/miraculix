# MISSION: Vault-Sicherheits-Hardening - MCP-Tool-Korruption verhindern, Skills/Memory bombenfest machen

## Lage und Auftrag

Vault: `C:\Users\deniz\Documents\miraculix\` (Windows 11, PowerShell, Obsidian Desktop, Git-tracked, Github `parabllm/miraculix`)

Letzte Forensik (2026-04-26, Bericht in `_claude/scripts/forensik-2026-04-26/REPORT.md`) hat als Root Cause der Frontmatter-Korruption das Tool `Desktop Commander:write_file` identifiziert. Dieses Tool laeuft Markdown-Files durch einen Pretty-Printer-Roundtrip und produziert dabei systematisch die Patterns:

- Pattern A: `---\n\n## key: value key: value...` (Multi-Line-YAML zu einer Zeile geschmiert mit `## ` Prefix)
- Pattern B: `---\n\nkey: value...key:\n\n- listitem\n\n---` (YAML-Listen aus Frontmatter herausgepusht)
- Pattern C: Wikilink-Arrays mit fehlendem oeffnenden `"`
- Pattern D: Backslash-Escapes `\[`, `\]`, `\~` wo keine sein sollten
- Pattern E: Pipe-Tabellen kollabiert in eine Zeile (Datenverlust)
- Pattern F: Email-Adressen auto-linked zu `[email](mailto:email)`
- Pattern G: Block-Quotes reflowed
- Pattern H: CRLF zu LF konvertiert

Sichere Schreibmethoden (bewiesen stabil):
- PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 ohne BOM
- Base64-Encode-Decode-Pipeline fuer grosse Files
- Filesystem MCP write_file (zu pruefen ob das gleiche Bug-Engine hat)

**Auftrag:** Mache das Miraculix-System bombenfest gegen drei Probleme:

1. **Frontmatter-Korruption durch falsche MCP-Tools** (HOECHSTE PRIORITAET, akut)
2. **Umlaut-Behandlung** (mittelpriorisiert, Deniz hat Skills schon ergaenzt aber Konsistenz pruefen)
3. **Leere Files / falsch gesetzte Wikilinks** (mittelpriorisiert, separates Hardening)

Es soll am Ende egal sein welcher Chat (Claude Desktop, Claude Code, parallel laufend, mit oder ohne Memory) auf den Vault zugreift, nichts darf Files korrumpieren oder Claude-Wissen ruinieren.

## Zu inspizierende Surface (vollstaendige Liste)

### Skill-Files (alle muessen geprueft werden)

```
C:\Users\deniz\Documents\miraculix\_claude\skills\
  abgleich.md
  audio-verarbeiten.md
  drive-eingang-holen.md
  eingang-verarbeiten.md
  log.md
  schreibstil.md
  tages-start.md
  transkript-verarbeiten.md
  vault-pruefung.md
  vault-system.md
  wissens-destillation.md
```

### Vault-Root Anweisungen

```
C:\Users\deniz\Documents\miraculix\CLAUDE.md
C:\Users\deniz\Documents\miraculix\START-HERE.md
```

### Worktrees

```
C:\Users\deniz\Documents\miraculix\.claude\worktrees\
  elastic-payne-f690b2\
  youthful-buck-a15c3a\
```
Pruefen was dort liegt, ob eigene CLAUDE.md oder Skill-Overrides existieren.

### Scripts

```
C:\Users\deniz\Documents\miraculix\_claude\scripts\
```
Vor allem Helper-Skripte und der gesamte forensik-2026-04-26 Ordner. Bug-Scanner und Watchdog dort sollen Basis fuer das neue System werden.

### Skill-Sources extern (Project-Skills von Deniz)

Diese liegen in `/mnt/skills/user/` oder dem Anthropic-Project-Settings, sind nicht im Repo. Falls Claude Code Zugriff drauf hat, auch die pruefen. Falls nicht, dokumentieren dass Deniz die manuell pruefen muss.

### Memory-Surface

`memory_user_edits` enthaelt aktuell 4 Eintraege. Nach diesem Run sollen die kritischen Vault-Schreibregeln dort verankert sein, aber NICHT redundant zu den Skills (Memory ist Backup, Skills sind Source of Truth).

### Anhang-Configs zur Referenz

```
C:\Users\deniz\AppData\Roaming\Claude\claude_desktop_config.json
.obsidian\core-plugins.json
.obsidian\community-plugins.json
.gitattributes
.gitignore
.git\hooks\
```
Bereits bekannt aus Phase 0/1 Forensik, im forensik-2026-04-26 Ordner archiviert.

## Aufgaben in dieser Reihenfolge

### Phase A: Audit der bestehenden Skills und Anweisungen

Vor allem anderen: lesen und verstehen was aktuell gilt. Keine Aenderung.

1. Lies vollstaendig: `CLAUDE.md`, `START-HERE.md`, alle Skill-Files unter `_claude/skills/`. Auch beide Worktree-Verzeichnisse.

2. Erstelle Audit-Report `_claude/scripts/forensik-2026-04-26/06-skill-audit.md` mit folgenden Spalten pro Skill:
   - Name
   - Zweck (kurz)
   - Schreibt File-Operations? (ja, nein, indirekt)
   - Welche Tools werden zum Schreiben empfohlen? (z.B. Desktop Commander, Filesystem MCP, PowerShell, Edit-Tools)
   - Hat Vault-Schreibregeln-Sektion? (ja, nein)
   - Hat Umlaut-Hinweis? (ja, nein)
   - Hat Wikilink-Validation? (ja, nein)
   - Risiko-Score (1-5) fuer Korruption falls AI dem Skill folgt
   - Gefundene Inkonsistenzen oder veraltete Anweisungen

3. Liste alle Stellen in den Skills wo `write_file`, `edit_block`, `Filesystem`, `Desktop Commander`, oder direkte File-Manipulation erwaehnt wird. Pro Stelle: Skill, Zeile, gefaehrlich oder OK.

4. Identifiziere Widersprueche zwischen Skills (z.B. ein Skill sagt `write_file`, anderer sagt PowerShell). Liste sie.

5. Pruefe Worktree-Verzeichnisse: enthalten sie eigene CLAUDE.md oder Skill-Overrides die im Konflikt zu den Haupt-Skills stehen? Falls ja: dokumentieren und Deniz fragen ob die ueberhaupt noch aktiv sind.

6. Speichere Report. Zeige Deniz Top 5 Findings mit Risiko-Score.

### Phase B: Reparatur der 13 noch kaputten Files

Aus Phase 5 des vorigen Runs vorbereitet, aber noch nicht ausgefuehrt.

1. Frische Liste der aktuell kaputten Files via `vault-health-check.ps1` oder `bug-scanner-v3.ps1` aus dem forensik-Ordner.

2. Backup vor Reparatur in `forensik-2026-04-26/05-pre-repair-backups/` (zip plus einzeln pro File).

3. DRY-RUN Reparatur-Skript zeigen, alle 13 Files mit Vorher-Nachher-Hex und rekonstruierten Werten. Bei Wikilink-Arrays: explizit auflisten welche Werte rekonstruiert wurden, Deniz pro File freigeben lassen.

4. Apply in 3 Batches:
   - Batch 1: Einfache Pulse-Kontakte (5 Files, gleiche Signatur)
   - Batch 2: Heterogene Files (8 Files, einzeln verifizieren)
   - Batch 3: Pattern-E-Files (lab-peptides.md plus alle mit kollabierten Tabellen)
     Hier: git history pruefen (`git log -- <file>`), letzten Commit vor Korruption finden, `git show <commit>:<path>` als Body-Quelle nehmen, Frontmatter aus reparierter Version. Wenn keine git history: Deniz manuell entscheiden lassen.

5. Hex-Verify nach jedem Write. 60 Sekunden Stabilitaets-Watch nach allen Writes.

6. Falls eine Datei nach Write wieder kaputt geht: STOPP, Phase 3 Reproducer wiederholen, da laeuft noch ein zweiter Korruptions-Mechanismus.

### Phase C: Konsolidierte Vault-Schreibregeln

Bevor irgendein Skill geaendert wird: erst eine Master-Quelle bauen, dann referenzieren. Vermeidet Redundanz und Drift.

1. Erstelle `02-wissen/vault-schreibregeln.md` als kanonische Master-Datei mit Frontmatter:
   ```yaml
   typ: wissen
   thema: vault-schreibregeln
   status: aktiv
   erstellt: 2026-04-26
   vertrauen: bestaetigt
   quelle: forensik-2026-04-26
   prioritaet: kritisch
   ```
   Inhalt soll enthalten:
   - **Sichere Methoden** (PowerShell WriteAllBytes UTF-8 NoBOM, Base64-Pipeline) mit konkreten Code-Beispielen
   - **Verbotene Methoden** mit Begruendung und Hex-Pattern Beispiel:
     - `Desktop Commander:write_file` fuer .md mit YAML-Frontmatter
     - `Desktop Commander:edit_block` fuer .md mit YAML-Frontmatter (zu pruefen, vermutlich gleiche Engine)
     - `Filesystem:write_file` (zu testen, evtl auch betroffen)
     - `Filesystem:edit_file` (zu testen)
   - **Bedingt erlaubte Methoden** (z.B. write_file fuer Files OHNE Frontmatter, mit Verifikations-Pflicht)
   - **Pflicht-Verify** nach jedem Write: erste 50 Bytes Hex-Check, vergleichen mit erwartetem Pattern `2D 2D 2D 0A` (oder `2D 2D 2D 0D 0A`) gefolgt von einem YAML-Key, NICHT `2D 2D 2D 0A 0A 23 23`
   - **Rollback-Verfahren** falls Verify Bug zeigt
   - **Umlaut-Regeln** (echte UTF-8 Umlaute in .md Files, ASCII in PowerShell-Strings)
   - **Wikilink-Validation** (geschachtelte Anfuehrungszeichen, Array-Format)

2. Erstelle parallel `02-wissen/desktop-commander-frontmatter-bug.md` als Bug-Dokumentation mit:
   - Hex-Pattern-Beispiele (Vorher-Nachher)
   - Forensik-Beweis (Verweis auf REPORT.md)
   - Affected Tools (Stand: Desktop Commander; zu testen: Filesystem MCP)
   - Reparatur-Skript-Pfad

3. **Echter Test der Filesystem MCP Tools**: Schreibe eine Test-Datei mit Multi-Line-Frontmatter via `Filesystem:write_file` und `Filesystem:edit_file`, hex-verify, dokumentiere ob die auch betroffen sind. Resultat in beiden Wissens-Files eintragen. Wichtig: nicht raten, testen.

### Phase D: Skill-Updates (jeder Skill prueft die Master-Quelle)

Prinzip: Skills referenzieren `vault-schreibregeln.md`, kopieren nicht. Vermeidet Drift.

1. **`vault-system.md`**:
   - Neue Sektion ganz oben "KRITISCHE VAULT-SCHREIBREGELN" mit Verweis auf `02-wissen/vault-schreibregeln.md` und einem 3-Zeilen-TLDR (Verbot Desktop Commander write_file fuer Frontmatter, Pflicht PowerShell WriteAllBytes, Hex-Verify nach Write)
   - Diese Sektion MUSS so prominent sein dass kein zukuenftiger Run sie uebersehen kann
   - Existierende Inhalte hinten an

2. **`schreibstil.md`**:
   - Pruefen ob hier File-Schreibregeln gemischt sind. Falls ja: trennen, schreibstil bleibt schreibstil, file-schreiben verweist auf vault-schreibregeln
   - Umlaut-Regeln pruefen ob konsistent zu Master

3. **`log.md`, `eingang-verarbeiten.md`, `audio-verarbeiten.md`, `transkript-verarbeiten.md`, `abgleich.md`, `wissens-destillation.md`, `tages-start.md`**:
   - Alle die irgendwo `write_file`, `edit_block`, `create_file` oder aehnlich erwaehnen: aendern auf PowerShell-Methode oder explizit dokumentieren wann welche Methode OK ist
   - Verweis auf `vault-schreibregeln.md` an markanter Stelle

4. **`vault-pruefung.md`**:
   - Erweitern um Pflicht-Check der Frontmatter-Patterns A bis H (basiert auf bug-scanner-v3.ps1)
   - Auch leere Files und kaputte Wikilinks pruefen (siehe Phase F)

5. **`drive-eingang-holen.md`**:
   - Pruefen ob beim Drive-Pull eine File-Korruption passieren kann. Drive-API liefert raw bytes, sollte safe sein, aber dokumentieren

6. Falls Worktrees eigene CLAUDE.md haben: dort gleiche Sektion einfuegen oder Verweis auf Haupt-Vault.

### Phase E: CLAUDE.md und START-HERE.md Hardening

1. **CLAUDE.md** (Vault-Root, wird automatisch von Claude Code beim cd in den Vault geladen):
   - Prominente Sektion ganz am Anfang "VAULT-SCHREIBREGELN (PFLICHT)"
   - Dort die 3-Zeilen-TLDR plus Verweis auf Wissens-Eintrag
   - Sektion "Was Claude NIE tun darf":
     - Desktop Commander write_file/edit_block fuer .md mit YAML-Frontmatter
     - Andere unsichere File-Tools fuer Vault-Files
     - Auto-Reformatierung von YAML
     - Tabellen-Manipulation ohne Backup
   - Plus klare Anweisung: "Wenn du diese Regel brichst, kannst du Datenverlust verursachen. Bei Unsicherheit: erst Deniz fragen, dann schreiben."

2. **START-HERE.md**:
   - Pruefen ob hier File-Schreibregeln stehen. Falls ja: konsistent halten zu CLAUDE.md
   - Verweis auf vault-schreibregeln.md

### Phase F: Defense Layer 1 - Watchdog im Pre-Commit-Hook

1. `_claude/scripts/vault-health-check.ps1` finalisieren (basiert auf bug-scanner-v3 aus forensik):
   - Scannt alle .md Files
   - Erkennt Patterns A bis H
   - Erkennt leere Files (size < 50 Bytes oder nur Frontmatter ohne Body)
   - Erkennt kaputte Wikilinks (`[[]]`, `[[ ]]`, `[[name`, ungeschlossen)
   - Exit-Code 0 = sauber, > 0 = Bugs gefunden
   - Output: Markdown-Report mit Liste betroffener Files

2. Pre-Commit-Hook `_meta/git-hooks/pre-commit` (oder direkt `.git/hooks/pre-commit`):
   - Ruft vault-health-check.ps1 auf
   - Blockiert Commits wenn neue Bugs eingefuehrt wurden (Diff zu vorigem Commit)
   - Erlaubt Bypass via `git commit --no-verify` mit Warnung

3. Dokumentation des Hook-Setups in `vault-schreibregeln.md`.

### Phase G: Defense Layer 2 - Memory-Hardening

1. Pruefe aktuelle Memory-Eintraege via `memory_user_edits view`.

2. Stelle sicher dass folgende Eintraege existieren (deduplizieren wenn schon da):
   - Vault-Schreibregel (knapp, mit Verweis auf Skill und Wissens-Eintrag)
   - Umlaut-Regel (existiert bereits laut Phase 0)
   - Hinweis auf CLAUDE.md im Vault-Root
   - Hinweis auf vault-schreibregeln.md

3. Memory soll nicht alles enthalten was in Skills steht. Memory ist nur Pointer auf Wahrheit. Skills sind Wahrheit. Sonst Drift.

### Phase H: Test der neuen Defenses

1. Synthetischer Korruptions-Versuch: Schreibe Test-Datei `_claude/scripts/forensik-2026-04-26/test-defense.md` via `Desktop Commander:write_file` mit komplexem Frontmatter. Pruefe:
   - Wird sie kaputt geschrieben? (sollte ja, Bug existiert noch im Tool)
   - Wird sie vom Watchdog erkannt? (sollte ja)
   - Wird Pre-Commit-Hook blockieren? (testen mit echtem Commit-Versuch dieser Datei)

2. Skill-Konsistenz-Test: Lies `vault-system.md` und pruefe ob die Schreibregeln-Sektion in den ersten 50 Zeilen steht (Top-of-Mind-Test).

3. Cross-Reference-Test: Pruefe ob jeder Skill der File-Operations macht, einen Verweis auf `vault-schreibregeln.md` hat.

4. Wikilink-Validation-Test: Erstelle bewusst kaputte Wikilinks in einer Test-Datei, pruefe ob vault-pruefung.md Skill sie erkennt.

5. Loesche test-defense.md am Ende, behalte aber den Test-Output als Beweis.

### Phase I: Final-Report

`forensik-2026-04-26/HARDENING-REPORT.md` mit:
- Was war das Audit-Ergebnis (Phase A)
- Welche Files wurden repariert (Phase B)
- Welche Skills wurden geaendert (Phase D, E)
- Welche neuen Schutzschichten existieren (Phase F, G)
- Test-Ergebnisse (Phase H)
- Liste verbleibender Risiken
- Liste was Deniz selbst tun muss (z.B. Memory pruefen, Filesystem-MCP-Test bestaetigen)
- Monatliche Verify-Routine

## Constraints

- **Plan-and-Execute strikt:** Vor jeder Phase Plan zeigen, dann ausfuehren. Bei destructive actions (Phase B Reparatur) explizite Freigabe pro Batch.

- **Keine Annahmen:** Bei jedem Tool dessen Verhalten unklar ist (Filesystem MCP, edit_block etc.) erst TESTEN dann dokumentieren.

- **Echte Umlaute:** In .md Files ä ö ü ß als UTF-8. In PowerShell-Strings ASCII (ae oe ue ss) wenn Encoding fragwuerdig.

- **Keine Gedankenstriche** im Output. Komma, Punkt, normaler Bindestrich.

- **Keine Redundanz:** Master-Quelle ist `02-wissen/vault-schreibregeln.md`. Alle Skills referenzieren, kopieren nicht.

- **Hex-Verify nach jedem File-Write** ohne Ausnahme. Auch fuer scheinbar harmlose Wissens-Eintraege.

- **Eigenes Schreiben:** Diesen Run wirst du SELBST viele Files schreiben muessen (Wissens-Eintrag, Skill-Updates, Hook). Verwende AUSSCHLIESSLICH PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 ohne BOM ODER Base64-Pipeline. NIE Desktop Commander write_file fuer das. Sonst implodiert die Mission.

- **Worktrees beachten:** Wenn dort eigene Anweisungen liegen die noch aktiv sind: konsistent halten oder Deniz fragen ob loeschen.

- **Memory ist Pointer, nicht Wahrheit:** Skills enthalten die Wahrheit, Memory verweist nur drauf.

## Erfolgskriterien

Am Ende muss gelten:

1. Alle 13 kaputten Files sind repariert mit Hex-Verify
2. `02-wissen/vault-schreibregeln.md` existiert als kanonische Master-Quelle
3. `02-wissen/desktop-commander-frontmatter-bug.md` dokumentiert den Bug mit Beweis
4. Jeder Skill der File-Ops macht hat Verweis auf Master-Quelle und kein Widerspruch dazu
5. CLAUDE.md hat prominente Schreibregeln-Sektion
6. Watchdog-Skript existiert und funktioniert
7. Pre-Commit-Hook ist eingerichtet (oder dokumentiert warum nicht)
8. Memory-Eintraege sind konsolidiert (Pointer auf Skills)
9. Synthetischer Korruptions-Test in Phase H beweist dass Defense Layer greifen
10. Filesystem MCP Tools sind getestet ob sie auch betroffen sind, Ergebnis dokumentiert

## Hinweise zum Stil

- Normale Saetze, keine Bullet-Walls.
- Direkte Sprache, kein Smalltalk.
- Tabellen wo Vergleiche sinnvoll.
- Bei Ungewissheit: explizit "unklar weil...".
- Sparringspartner: bei Zweifeln widersprechen mit Begruendung.
- Bei jeder Phase die geschaetzten Tool-Calls vorab nennen, damit Deniz weiss wie lange das dauert.