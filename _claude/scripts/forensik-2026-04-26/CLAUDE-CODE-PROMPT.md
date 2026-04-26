# MISSION: Vault-Frontmatter-Korruption Root-Cause-Analyse und permanenter Fix

## Kontext und Auftrag

Vault: `C:\Users\deniz\Documents\miraculix\` (Windows 11, PowerShell, Obsidian Desktop, Git-tracked)
Github: `parabllm/miraculix`

**Problem (verlangt eine Loesung, nicht nur Reparatur):**
Mehrere .md Files im Vault werden wiederholt mit kaputtem YAML-Frontmatter gespeichert. Selbst nach Reparatur sind sie nach Obsidian-Start wieder kaputt. Das Problem trat erstmals am 2026-04-25 oder 2026-04-26 auf, parallel zu zwei Aktivitaeten:
1. Vault-weiter Umlaut-Fix-Run (Chat "Copilot Premium Faehigkeiten erkunden", 2026-04-25)
2. Einrichtung Scheduled Task `Miraculix Vault Auto-Push` (Chat "Obsidian Migration", 2026-04-17)

Sync ist nachweislich deaktiviert (`.obsidian/core-plugins.json` zeigt `"sync": false`), trotzdem werden Files modifiziert.

**Auftrag:**
1. Wurzel finden mit Beweis (Reproducer)
2. Permanent fixen (nicht nur reparieren)
3. Alle aktuell kaputten Files reparieren mit Backup
4. Praevention dokumentieren so dass es nie wieder passiert
5. Watchdog-Skript so dass kuenftige Bugs sofort erkannt werden

## Bekannte Bug-Patterns

A. Frontmatter zu einer Zeile geschmiert mit `## ` Prefix:
   `---\n\n## key: value key: value ...\n\n` (kein schliessendes `---`)

B. Frontmatter zu einer Zeile ohne `## `, mit schliessendem `---`:
   `---\n\nkey: value key: value ... key:\n\n- listitem\n\n---`
   YAML-Multiline-Listen werden in den Body herausgepusht

C. Wikilink-Arrays mit fehlendem oeffnenden `"`:
   Korrekt waere `["[[name]]", "[[other]]"]`, kaputt ist `[[name]]", "[[other]]"]`

D. Markdown-Escapes wo keine sein sollten:
   `\[`, `\]` (besonders bei Checkboxen `- \[ \]`)
   `\~` (z.B. `\~3h` statt `~3h`)
   `\{`, `\}`, `\*`, `\_` (vermutlich auch)

E. Pipe-Tabellen kollabiert in eine Zeile:
   `| Kanal | Wert |` wird zu `KanalWertEmail...` ohne Newlines
   Das ist Datenverlust, nicht reparabel ohne Quelle

F. Umlaute korrekt UTF-8 codiert (kein Encoding-Issue), nur Strukturschaden

## Bekannte Hauptverdaechtige (priorisieren)

H1 (HOCH): **Scheduled Task `Miraculix Vault Auto-Push`**
   - Eingerichtet am 2026-04-17
   - Laeuft bei Login (nach 2 Min Verzoegerung) plus alle 6 Stunden
   - StartWhenAvailable aktiv (Catch-up-Logik)
   - Ist git-bezogen, aber wenn da Pre-Commit-Hooks oder File-Filters laufen, manipuliert es Files
   - Pruefe besonders: ruft das Task-Skript ein anderes File-Manipulations-Skript auf?

H2 (HOCH): **Umlaut-Fix-Skript vom 2026-04-25**
   - Im Chat "Copilot Premium Faehigkeiten erkunden" wurde ein Vault-weiter Umlaut-Fix besprochen
   - Womoeglich als geplanter Task hinterlegt, oder als One-Shot-Skript ausgefuehrt mit ungewollten Side-Effects
   - Falls als FileSystemWatcher implementiert, laeuft er weiter im Hintergrund

H3 (MITTEL): **Obsidian Properties Plugin** (`"properties": true`)
   - Parst YAML beim Datei-Oeffnen, reserialisiert beim naechsten Save
   - Buggy bei multiline-Listen oder bestimmten Strings

H4 (MITTEL): **Obsidian Bases Plugin** (`"bases": true`)
   - Neue Obsidian-Funktion, manipuliert ggf. Frontmatter

H5 (NIEDRIG): **Obsidian File-Recovery** (`"file-recovery": true`)
   - Stellt evtl. alte Snapshots wieder her

H6 (NIEDRIG): **OneDrive/Drive-Sync auf dem Pfad**
   - Pruefen via `$env:OneDrive`, Symlinks, Registry

H7 (NIEDRIG): **Community-Plugin** (Liste laut .json leer, aber Plugins-Ordner pruefen)

## Aufgaben in dieser Reihenfolge

### Phase 0: Vorgeschichte erforschen

Bevor irgendein Test laeuft, sammle Kontext aus den letzten 48 Stunden.

1. Erstelle Forensik-Ordner `C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\`. Alle Outputs landen hier.

2. Lies die folgenden Skills komplett (relevant fuer Vault-Schreibregeln und gestrige Aenderungen):
   - `_claude\skills\miraculix-vault-system\SKILL.md` (oder wo der Skill liegt - Pfad pruefen)
   - `_claude\skills\miraculix-log\SKILL.md`
   - `_claude\skills\miraculix-eingang-verarbeiten\SKILL.md`
   - Alle anderen `miraculix-*` Skills im Skill-Verzeichnis

3. Suche Past-Chats nach Stichworten und protokolliere wer was wann angefasst hat:
   - "umlaut" plus "vault" plus "fix" (Umlaut-Fix von gestern)
   - "Copilot Premium Faehigkeiten" (gestriger Chat 2026-04-25)
   - "auto-push" plus "scheduled task" (Migration-Chat 2026-04-17)
   - "frontmatter" und "kaputt"

4. Pruefe alle Scheduled Tasks die mit dem Vault interagieren:
   ```powershell
   Get-ScheduledTask | Where-Object { $_.TaskName -match "miraculix|vault|obsidian" } | Format-List TaskName, State, Triggers, Actions
   ```
   Dokumentiere jeden Action-Pfad. Falls ein Task ein Skript aus `_claude/scripts/` aufruft, lies das Skript und dokumentiere was es tut.

5. Pruefe ob FileSystemWatcher-Prozesse laufen:
   ```powershell
   Get-Process | Where-Object { $_.ProcessName -match "watcher|monitor|sync" }
   Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match "miraculix|vault" } | Select-Object ProcessId, CommandLine
   ```

6. Liste alle Skripte unter `_claude/scripts/` und `_claude/scheduled/` (falls existiert), mit Last-Modified-Time. Lies jedes Skript das in den letzten 7 Tagen modifiziert wurde.

7. Pruefe `.git/hooks/` auf installierte Pre-Commit, Post-Commit oder Pre-Push Hooks.

8. Pruefe `.gitattributes` auf `text=auto` oder `eol=` Settings die Files transformieren koennten.

9. Speichere alles als Markdown-Report nach `forensik-2026-04-26\00-vorgeschichte.md`.

### Phase 1: System-Forensik

1. Kopiere folgende Configs in den Forensik-Ordner:
   - `.obsidian/core-plugins.json`
   - `.obsidian/community-plugins.json` (auch wenn leer)
   - `.obsidian/app.json`
   - `.obsidian/appearance.json`
   - `.obsidian/workspace.json`
   - `.obsidian/sync.json` (falls vorhanden)

2. Liste `.obsidian/plugins/` Verzeichnis-Inhalt rekursiv (welche Community-Plugins sind faktisch installiert, auch wenn json leer ist).

3. Liste laufende Obsidian-Prozesse mit StartTime, ProcessName, Id. Bei mehreren Prozessen: was ist der Parent-Prozess.

4. Pruefe ob `C:\Users\deniz\Documents\miraculix\` innerhalb eines OneDrive-, Google-Drive- oder Dropbox-synchronisierten Pfads liegt:
   ```powershell
   $env:OneDrive
   Get-Item "C:\Users\deniz\Documents\miraculix" | Select-Object Attributes, LinkType, Target
   reg query "HKEY_CURRENT_USER\Software\Microsoft\OneDrive\Accounts" 2>$null
   ```

5. Liste alle .md Files im Vault, die in den letzten 24h modifiziert wurden, sortiert nach Zeitstempel ASC. Markiere welche von Deniz selbst stammen vs verdaechtig automatisch.

6. Speichere als `forensik-2026-04-26\01-forensik.md`.

### Phase 2: Vault-weiter Bug-Scan

1. Erstelle Backup vor allem anderen:
   ```powershell
   $forensik = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26"
   Compress-Archive -Path "C:\Users\deniz\Documents\miraculix\*" -DestinationPath "$forensik\02-vault-backup.zip" -Force -CompressionLevel Optimal
   ```
   Test-Archive verifizieren.

2. Scanne jede .md Datei rekursiv unter `C:\Users\deniz\Documents\miraculix\` (exklusive `.git`, `.obsidian`, `node_modules`, `_claude\scripts\forensik-2026-04-26`).

3. Pro Datei: Pruefe alle Bug-Patterns A bis F. Mehrere Bugs pro Datei moeglich. Erkenne anhand:
   - Erste 30 Bytes (Pattern A: `2D 2D 2D 0A 0A 23 23`, Pattern B: `2D 2D 2D 0A 0A` plus key:)
   - Volltext: Regex fuer Pattern C, D, E
   - Tabellen-Erkennung: Suche nach Mustern wo `|` ohne umgebende Newlines steht (kollabierte Tabellen)

4. Schreibe Ergebnis als CSV nach `forensik-2026-04-26\02-bug-scan.csv` mit Spalten:
   `pfad, pattern_a, pattern_b, pattern_c_wikilink, pattern_d_escapes, pattern_e_tabellen, file_size_bytes, last_modified, modified_by_recent_run`

5. Erstelle kompakte Markdown-Zusammenfassung nach `02-bug-summary.md`:
   - Total Files
   - Files pro Pattern
   - Top-10 schlimmste Files (meiste Bugs)
   - Histogram der Last-Modified-Zeitstempel (cluster sich was um bestimmte Uhrzeiten = Hinweis auf Scheduled Task)

### Phase 3: Reproducer-Test

Ziel: Beweisen welcher Mechanismus die Files kaputt schreibt. Ohne diesen Beweis raten wir.

1. Stelle sicher dass alle Obsidian-Prozesse beendet sind. Frage Deniz vorher:
   "Ich starte gleich einen Reproducer-Test. Soll ich die laufenden Obsidian-Prozesse killen? Antworte mit `kill` oder `lass laufen`."

2. Erstelle Test-Datei `_claude\scripts\forensik-2026-04-26\test-watchdog.md` via PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 ohne BOM. Inhalt:
   ```
   ---
   typ: test
   datum: 2026-04-26
   teilnehmer: ["[[test-person]]"]
   tasks:
     - "Test-Task mit ~3h Schaetzung"
   fokus_projekte:
     - pulsepeptides
     - thalor
   ---

   # Test-Watchdog

   Inhalt mit ~ und [ und ] und Wikilink [[test]].

   | Spalte A | Spalte B |
   |---|---|
   | Wert 1 | Wert 2 |

   - [ ] Checkbox-Task
   ```

3. SHA256 und Hex-Snapshot der ersten 300 Bytes nach `03-test-T0-baseline.txt`.

4. **Test-Schritt T1: Idle ohne Obsidian.**
   Pruefe in 30-Sekunden-Intervallen fuer 5 Minuten ob die Datei sich aendert. Stop-Bedingung: Datei wurde geaendert ODER 5 Minuten ohne Aenderung. Hex-Snapshot bei jeder Aenderung.

5. **Test-Schritt T2: Obsidian oeffnet, Datei nicht.**
   Frage Deniz: "Bitte starte Obsidian aber oeffne NICHT die Test-Datei. Schreibe `gestartet` wenn Obsidian laeuft." Warte. Nach `gestartet`: 30 Sekunden warten, Hex-Snapshot.

6. **Test-Schritt T3: Datei oeffnen, nicht editieren.**
   Frage Deniz: "Oeffne jetzt `test-watchdog.md` in Obsidian. Schreibe `auf` wenn offen." Warte. Nach `auf`: 30 Sekunden warten, Hex-Snapshot.

7. **Test-Schritt T4: Tab schliessen ohne Edit.**
   Frage Deniz: "Schliesse den Tab der Test-Datei in Obsidian (kein Edit). Schreibe `zu` wenn fertig." Warte. Nach `zu`: 30 Sekunden warten, Hex-Snapshot.

8. **Test-Schritt T5: Auto-Push triggern.**
   Pruefe ob Scheduled Task `Miraculix Vault Auto-Push` existiert. Falls ja, triggere ihn manuell:
   ```powershell
   Start-ScheduledTask -TaskName "Miraculix Vault Auto-Push"
   ```
   30 Sekunden warten, Hex-Snapshot.

9. **Test-Schritt T6: Synthetisches Frontmatter mit Multi-Line-Liste plus Tabelle.**
   Schreibe eine zweite Test-Datei mit komplexerem Frontmatter (verschachtelte Listen, lange Strings mit Sonderzeichen) und durchlaufe T2 bis T5 nochmal.

10. Speichere alle Snapshots, Diffs und Diagnose nach `03-test-protokoll.md`. Diagnose muss beantworten:
    - Wurde die Datei von Idle-Zustand kaputt geschrieben? (T1)
    - Vom Obsidian-Start ohne sie zu oeffnen? (T2)
    - Vom blossen Anschauen der Datei? (T3)
    - Vom Tab-Schliessen? (T4)
    - Vom Auto-Push-Task? (T5)
    - Welche Patterns sind erschienen?

### Phase 4: Hypothesen-Test mit Evidenz

Bestaetige oder widerlege jede Hypothese basierend auf Phase 0 bis 3:

H1: Scheduled Task `Miraculix Vault Auto-Push`
   - Beweis-Indikatoren: T5-Resultat, Action-Pfad-Inspektion aus Phase 0, Cluster bei Auto-Push-Zeiten in Phase 2 Histogram

H2: Umlaut-Fix-Skript
   - Beweis-Indikatoren: Existenz eines aktiven FileSystemWatchers oder weiteren Tasks aus Phase 0, Datei-Modifikationen ohne offensichtlichen Trigger in Phase 3 T1

H3: Properties Plugin
   - Beweis-Indikatoren: T3-Resultat (Anschauen kaputt schreibt) oder T4-Resultat (Tab schliessen schreibt). Test: Plugin temporaer deaktivieren via `core-plugins.json` `"properties": false` und T3+T4 wiederholen. Wenn Datei dann stable bleibt, Plugin ist Schuldiger.

H4: Bases Plugin
   - Analog H3 mit `"bases": false`.

H5: File-Recovery
   - `.obsidian/snapshots/` pruefen, T1-Resultat

H6: OneDrive/externe Sync
   - Phase 1 Schritt 4 Resultat

H7: Community-Plugin
   - Phase 1 Schritt 2 Resultat

Falls H3 oder H4 vermutet wird: Mache zusaetzlichen Plugin-Isolations-Test. Deaktiviere ALLE Plugins temporaer (alle keys auf false ausser daily-notes), starte Obsidian, Reproducer, dann ein Plugin nach dem anderen reaktivieren bis Bug zurueckkommt.

Ergebnis nach `forensik-2026-04-26\04-hypothesen.md` mit pro Hypothese:
   - Status: BESTAETIGT, WIDERLEGT, UNKLAR
   - Evidenz: konkrete Datei-Snapshots, Logs
   - Confidence: hoch, mittel, niedrig

### Phase 5: Root Cause + Permanenter Fix

Bevor du IRGEND einen Fix anwendest: zeige Deniz den Plan, frage explizit "go" oder "warte". Bei jedem destructive write: einzeln Freigabe.

Basierend auf Phase 4: Wende den passenden Fix an.

**Fall A: Wenn ein Skript/Task der Schuldige ist:**
   - Stoppe und deaktiviere Scheduled Task: `Disable-ScheduledTask -TaskName "..."`
   - Identifiziere ob das Skript fixbar ist oder geloescht werden muss
   - Wenn fixbar: Fix anwenden, neu testen, dann reaktivieren
   - Wenn nicht: Loeschen und durch sicheres Aequivalent ersetzen

**Fall B: Wenn ein Obsidian-Plugin der Schuldige ist:**
   - Deaktiviere via `core-plugins.json` setzen auf `false`
   - Erklaere Deniz die Trade-Offs (z.B. Properties-Tab in Obsidian-UI verschwindet)
   - Falls Plugin essentiell ist: Issue beim Obsidian-Team melden, im Wissens-Eintrag dokumentieren

**Fall C: Wenn externe Sync der Schuldige ist:**
   - Vault aus Sync-Pfad herausziehen oder Sync-Ausschluss konfigurieren

Nach Fix-Anwendung:

1. Reparatur-Skript schreiben und ausfuehren `_claude\scripts\forensik-2026-04-26\repair-frontmatter.ps1`. Logik:
   - Lese Datei als UTF-8 Bytes via `[System.IO.File]::ReadAllBytes`
   - Erkenne Pattern A oder B (Frontmatter in einer Zeile)
   - Tokenize Felder via Key-Boundaries (Regex `(?:^|(?<=\s))(\w+):\s+`)
   - Field-Value extrahieren bis zum naechsten Field oder Frontmatter-Ende
   - De-escape `\[`, `\]`, `\~`, `\{`, `\}`, `\*`, `\_`
   - Bei Wikilink-Arrays: erkenne `[[name]]` ohne Quotes und stelle korrekte Form `["[[name]]"]` her
   - Schreibe sauberes Multi-Line-YAML zurueck via `[System.IO.File]::WriteAllBytes` mit UTF-8 ohne BOM
   - Pro File: Hex-Verify nach Write

2. Stabilitaets-Verify: 60 Sekunden warten ohne Obsidian-Start, dann hex-check ob alle Files stable bleiben.

3. Final-Verify mit Obsidian-Start: Frage Deniz "Starte jetzt Obsidian. Schreib `gestartet`." Nach `gestartet` 60 Sekunden warten, dann nochmal alle reparierten Files hex-checken.

### Phase 6: Praevention und Dokumentation

1. Erstelle Wissens-Eintrag im Vault: `02-wissen\vault-frontmatter-bug-root-cause-2026-04-26.md` mit Frontmatter:
   ```yaml
   typ: wissen
   thema: vault-frontmatter-bug-root-cause
   status: aktiv
   erstellt: 2026-04-26
   vertrauen: bestaetigt
   quelle: forensik-2026-04-26
   ```
   Inhalt:
   - Bug-Beschreibung mit Beispielen aus Phase 2
   - Root Cause aus Phase 5 (mit Reproducer-Beweis)
   - Permanente Loesung
   - Verbotene Schreib-Methoden mit Begruendung
   - Wie zukuenftige Bugs frueh erkannt werden

2. Update `_claude\skills\miraculix-vault-system\SKILL.md` mit neuer Sektion "Vault-Schreibregeln" am Ende:
   - YAML-Frontmatter immer Multi-Line schreiben
   - Bei Listen-Werten YAML-Block-Style verwenden, kein Inline-Array fuer komplexe Werte
   - Pflicht-Verify nach jedem File-Write via Hex-Check der ersten 50 Bytes
   - Liste der gefaehrlichen Tools die Bugs verursachen
   - Verweis auf den Wissens-Eintrag und das Watchdog-Skript

3. Update `_claude\skills\miraculix-log\SKILL.md` falls dort File-Write-Logik steht. Analog fuer alle anderen Skills die `.md`-Files schreiben.

4. Erstelle Watchdog-Skript `_claude\scripts\vault-health-check.ps1`:
   - Scannt alle .md Files im Vault
   - Erkennt alle Bug-Patterns A bis F
   - Gibt Anzahl Vorkommen plus betroffene Files zurueck
   - Exit-Code != 0 wenn Bugs gefunden
   - Dokumentation des Aufrufs in `vault-system` Skill

5. Optional: Erstelle Pre-Commit-Hook in `.git/hooks/pre-commit` der Watchdog ausfuehrt und Commits mit kaputten Files blockiert.

6. Erstelle Final-Report nach `forensik-2026-04-26\REPORT.md` mit klaren Antworten auf:
   - Was war die Root Cause?
   - Welcher Beweis aus Phase 3?
   - Welcher Fix wurde angewendet?
   - Wieviele Files repariert?
   - Was muss Deniz selbst tun?
   - Wie wird das in Zukunft verhindert?
   - Wie kann Deniz monatlich verifizieren dass alles stable ist?

## Constraints

- **Plan-and-Execute strikt:** Vor jeder Phase kurz Plan zeigen, dann ausfuehren. Bei Phase 5 explizite Freigabe von Deniz vor jeder destructive action. Niemals einfach drauflos.

- **Echte Umlaute:** In geschriebenen .md Files immer ae, oe, ue, ss als UTF-8 Umlaute. In PowerShell-Script-Strings wo Encoding fragwuerdig ist, ASCII-Aequivalent verwenden um Bug nicht selbst zu verursachen.

- **Keine Gedankenstriche** im Output. Stattdessen Komma, Punkt, Bindestrich.

- **Backup vor allem destructiven:** Phase 2 Schritt 1 ist nicht verhandelbar.

- **Bei jedem File-Write:** Hex-Snapshot direkt nach Write. Bei Auffaelligkeit STOPP und Deniz informieren.

- **Obsidian Start/Stopp:** Immer Deniz fragen, niemals selbst ohne Freigabe killen.

- **Sicherheit gegen Datenverlust:** Pattern E (kollabierte Tabellen) ist nicht reparabel ohne Quelle. Wenn dabei: Datei markieren, in Bug-Scan-Report explizit auflisten, NICHT versuchen zu rekonstruieren ausser Deniz gibt manuell die Inhalte.

- **Sicherheit gegen Re-Korruption:** Nach Fix in Phase 5 bevor irgendein anderer Prozess startet, hex-Verify. Wenn Datei wieder kaputt: Phase 5 wiederholen mit zusaetzlicher Hypothese.

## Erfolgskriterien

Am Ende muss klar und belegt sein:

1. Welcher Mechanismus genau den Bug verursacht (mit Reproducer-Beweis aus Phase 3)
2. Permanente Loesung ist angewendet
3. Alle bisherigen kaputten Files sind repariert (mit hex-Verify)
4. Watchdog-Skript existiert und funktioniert
5. Erkenntnisse sind im Vault dokumentiert (nicht nur im Chat)
6. Deniz kann Obsidian starten und schliessen ohne dass Files kaputt gehen
7. Eine monatliche Routine ist etabliert

## Hinweise zum Stil

- Reden in normalen Saetzen, keine Bullet-Points-Walls.
- Direkte Sprache, kein Smalltalk.
- Bei Ergebnissen kompakte Tabellen wo Tabellen Sinn machen.
- Bei Ungewissheit: explizit sagen "unklar weil...".
- Sparringspartner: wenn Deniz einen Fix vorschlaegt und du Zweifel hast, sag das mit Begruendung.