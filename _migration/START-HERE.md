# START HERE - So setzt du Miraculix auf

Deine Reihenfolge. Exakt, Schritt für Schritt.

---

## Voraussetzungen (hast du bereits)

- ✅ Node.js installiert
- ✅ Git installiert
- ✅ Claude Code installiert (`npm install -g @anthropic-ai/claude-code`)
- ✅ Notion-Export unter `C:\Users\deniz\Documents\notion\`
- ✅ Claude-Export unter `C:\Users\deniz\Documents\claude\`

---

## Schritt 1 - Framework platzieren (2 Min)

1. Diese ZIP entpacken nach `C:\Users\deniz\Documents\`
2. **Ergebnis-Check:** Im Ordner `miraculix\` liegt direkt `CLAUDE.md` und `MIGRATION.md`. Nicht verschachtelt!
3. Wenn doch doppelt verschachtelt (`miraculix\miraculix\...`): Inhalt eine Ebene hoch ziehen, leeren äußeren Ordner löschen.

Jetzt sollte deine Ordnerstruktur so aussehen:

```
C:\Users\deniz\Documents\
├── notion\          ← deine Notion-Exporte (CSV + Markdown)
├── claude\          ← deine Claude-Conversations (JSON)
└── miraculix\       ← das frische Framework
    ├── CLAUDE.md
    ├── MIGRATION.md
    ├── START-HERE.md (dieses File)
    ├── 00-eingang/
    ├── 01-projekte/
    ├── 02-wissen/
    ├── 03-kontakte/
    ├── ...
    └── _claude/skills/
```

---

## Schritt 2 - Git initialisieren (1 Min)

PowerShell öffnen (Windows-Taste → "powershell"):

```powershell
cd C:\Users\deniz\Documents\miraculix
git init
git add .
git commit -m "initial: miraculix framework"
```

Wichtig - das Initial-Commit. Dein Rollback-Punkt falls was schiefgeht.

---

## Schritt 3 - Claude Code starten (1 Min)

In derselben PowerShell:

```powershell
claude
```

Erster Start: Browser öffnet sich für Auth. Mit Claude Pro Account anmelden.

Wenn du wieder im Terminal bist, siehst du einen Prompt. Jetzt gib den Migrations-Prompt:

---

## Schritt 4 - Der Migrations-Prompt

**Copy-paste genau das:**

```
Du bist Miraculix. Lies zuerst CLAUDE.md und MIGRATION.md.

Quellen:
- C:\Users\deniz\Documents\notion\
- C:\Users\deniz\Documents\claude\

Führe Migration gemäß MIGRATION.md durch. Arbeite autonom.
Zeig nur bei wirklich ambigen Entscheidungen oder Widersprüchen.
Commit nach jedem Projekt in Git.
Neueste Version gewinnt bei Widersprüchen - Timestamps nutzen.

Start.
```

---

## Schritt 5 - Warten (1-3 Stunden)

Claude Code arbeitet jetzt:
- Phase A: Inventur (15-30 Min)
- Phase B: Kontakte (10-20 Min)
- Phase C: Projekte (30-60 Min)
- Phase D: Logs & Meetings (30-60 Min)
- Phase E: Wissen (15-30 Min)
- Phase F: Tagebuch (5-10 Min)
- Phase G: Quality Gate (10 Min)
- Phase H: Report (5 Min)

**Du kannst:**
- Den Computer laufen lassen, was anderes machen
- Gelegentlich reinschauen - er loggt in `_migration/progress.md`
- Bei Bedarf unterbrechen mit `Ctrl+C` und später wieder starten

**Was er NICHT tut:**
- Schläft nicht von selber
- Macht nichts destruktives ohne Grund
- Bricht auch nicht mit Fehlern ab - bei Problemen meldet er zurück

---

## Schritt 6 - Nach Abschluss

Wenn Claude Code sagt "Migration abgeschlossen":

1. **Git-History anschauen:**
   ```powershell
   git log --oneline
   ```

2. **Report lesen:**
   - Öffne `_migration/report.md`
   - Siehst: X Projekte angelegt, Y Kontakte, Z Logs
   - Ambiguitäten die du reviewen musst

3. **Obsidian öffnen:**
   - Obsidian → "Open folder as vault" → `C:\Users\deniz\Documents\miraculix\`
   - Community Plugins installieren: Dataview, Templater, Calendar, obsidian-git
   - Templater-Path setzen: `.obsidian/templates`

4. **Skills in Claude Desktop hochladen:**
   Files aus `_claude/skills/` als Account-Level Skills in Claude Desktop.
   - vault-system.md → Always On
   - tages-start, eingang-verarbeiten, abgleich, vault-pruefung, wissens-destillation

5. **Reality-Check mit Miraculix:**
   In Claude Desktop:
   > "Du bist Miraculix. Lies CLAUDE.md und gib mir einen Stand-Überblick über alle meine Projekte."

---

## Schritt 7 - Erste echte Nutzung

```
tages-start
```

Und du bist drin. Der Vault lebt.

---

## Wenn was schiefgeht

### Claude Code wirft Fehler
- `Ctrl+C` → PowerShell-Session killen
- `git status` → was ist aktuell modifiziert?
- `git reset --hard HEAD` wenn ganz zurück, oder `git log --oneline` → dann `git reset --hard <commit>` um zum letzten guten Stand
- `claude` neu starten, gleichen Prompt wieder

### Migration läuft zu lange / hängt
- `Ctrl+C`
- Schau `_migration/progress.md` an: wo ist er stehengeblieben?
- Neu starten mit: "Setze Migration fort ab Phase X"

### Results sind total schrottig
- `git reset --hard <initial-commit>` → alles wieder leer
- Prompt überarbeiten
- Nochmal starten

### Claude Code fragt dauernd nach
- Der Prompt war zu unklar. Sag nochmal: "autonom arbeiten, nur bei echten Widersprüchen fragen"

---

## Wichtige Dateien im Vault

| File | Zweck |
|---|---|
| `CLAUDE.md` | Boot-Instruction für jede KI die auf Vault zugreift |
| `MIGRATION.md` | Auftrag für Claude Code (wird nach Migration archiviert) |
| `_meta/schema.md` | Frontmatter-Specs - wie Files aussehen müssen |
| `_meta/glossar.md` | Begriffsdefinitionen |
| `_claude/skills/*.md` | Die 6 Operations-Skills |
| `_migration/report.md` | Abschluss-Bericht nach Migration |
| `_migration/progress.md` | Live-Progress während Migration |
| `_migration/issues.md` | Ambiguitäten die du reviewen musst |

---

Viel Erfolg. Pace.
