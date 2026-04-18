---
name: miraculix-drive-eingang-holen
description: Triggered when Deniz says "hol den eingang aus dem drive", "drive pull", "drive eingang holen", "zieh den drive eingang", "sync drive inbox", or similar. Pulls all files from the Google Drive folder `Miraculix_Eingang/` down to the local vault `00-eingang/unverarbeitet/`, deletes them from Drive (so the Drive inbox ends up empty), reports what was moved, and offers to chain directly into the `eingang-verarbeiten` digest skill. Works only on PC (Claude Code or Claude Desktop App with filesystem+shell MCPs). From Claude Mobile this skill explains that the pull is not possible from the phone and advises to trigger the pull at the PC.
---

# Drive-Eingang holen

Zieht Files aus Google Drive `Miraculix_Eingang/` nach `00-eingang/unverarbeitet/`, loescht Drive-Seite. Danach Chain in `eingang-verarbeiten`.

## Voraussetzungen

- rclone installiert (unter Windows via `winget install Rclone.Rclone`)
- rclone-Remote `gdrive` konfiguriert (via `rclone config`, scope = drive)
- Drive-Ordner-Struktur:
  - `Miraculix_Eingang/` (Top-Level, fuer `.md`-Files aus Claude Mobile)
  - `Miraculix_Eingang/Images/` (Unterordner, fuer Binaries/Fotos die Deniz direkt via Drive-App hochlaedt)

## Wie der Skill ausgefuehrt wird

### Fall A: Claude Code im Vault (Bash verfuegbar)

1. Pruefe ob `rclone` im PATH oder ueber Winget-Pfad aufrufbar ist.
2. Fuehre das Skript aus:
   ```bash
   powershell -ExecutionPolicy Bypass -File "_claude/scripts/drive-inbox-pull.ps1"
   ```
3. Das Skript:
   - `rclone move gdrive:Miraculix_Eingang <vault>/00-eingang/unverarbeitet --max-depth 1` (Top-Level-Files)
   - `rclone move gdrive:Miraculix_Eingang/Images <vault>/00-eingang/unverarbeitet/_originale` (Binaries)
   - Zeigt Report was gezogen wurde, prueft dass Drive-Seite leer ist
4. Nach erfolgreichem Pull: **frage Deniz, ob direkt `eingang verarbeiten` triggern**. Wenn ja, sofort den Digest-Skill starten (er ist in `_claude/skills/eingang-verarbeiten.md`).

### Fall B: Claude Desktop App mit MCP (Shell + Filesystem verfuegbar)

Gleiche Logik wie Fall A, nur dass der Shell-Aufruf via Shell-MCP geht statt direkt Bash.

### Fall C: Claude Mobile oder Web-Chat (nur Drive-Connector)

Pull ist **nicht** moeglich, weil kein Zugriff auf Deniz' lokales Filesystem. Antwort:
> "Ich bin gerade nur in der Cloud, kein Zugriff auf dein lokales Laufwerk. Oeffne Claude Code oder die Desktop App auf deinem PC und sag dort 'eingang vom drive holen'. Willst du stattdessen nur sehen was gerade in Drive `Miraculix_Eingang` liegt?"

Optional: via Drive-Connector die Files auflisten und Preview zeigen.

## Fehlerfaelle

- **rclone nicht gefunden:** Anweisung geben `winget install Rclone.Rclone`, danach PowerShell neu starten.
- **Remote `gdrive` nicht konfiguriert:** Anweisung geben `rclone config` auszufuehren, oder Deniz fragen ob die Config aus Versehen geloescht wurde (`%APPDATA%\rclone\rclone.conf`).
- **Drive-Ordner umbenannt:** Skript macht `rclone lsd gdrive:` und zeigt was vorhanden ist; Deniz entscheidet.
- **Name-Collision beim Move (gleicher Dateiname schon lokal):** rclone haengt `-1`, `-2` etc. an; im Report explizit zeigen.

## Regeln

- **Move, nicht Copy.** Drive-Seite muss nach Pull leer sein (bis auf den `Images/`-Ordner selbst, der bleibt als Struktur).
- **Ordner `Images/` nicht loeschen.** Nur Inhalt movern.
- **Frage vor eingang-verarbeiten.** Nicht automatisch chainen, erst Report zeigen, dann "Soll ich direkt `eingang verarbeiten` triggern?".
- **Kein Auto-Commit.** Der existierende auto-push Hook kuemmert sich ums Committen, nicht der Skill selbst.

## Mobile-Schreib-Seite (zum Kontext)

Der Skill deckt nur die **Pull-Seite** ab. Die **Schreib-Seite** (Claude Mobile legt Notizen in `Miraculix_Eingang/`) wird ueber **globale Custom Instructions in claude.ai** geregelt oder ueber einen spaeter als Anthropic-Skill registrierten Eintrag. Siehe separate Doku im Vault.

Namensschema fuer Files die Mobile in die Drive-Inbox legt:
```
YYYY-MM-DD-HHMM-{kurztitel}.md
```
mit Frontmatter:
```yaml
---
status: unverarbeitet
quelle: claude-mobile
datum: YYYY-MM-DD
---
```
