---
typ: forensik
phase: 0
datum: 2026-04-26
zeitpunkt: 19:35
---

# Phase 0 - Vorgeschichte

## Zusammenfassung

Die Korruption ist **NICHT historisch** sondern **AKTIV**. Heute zwischen 16:53 und 17:19 wurden 13 Files modifiziert, einige davon mit dem klassischen Korruptions-Pattern (Tabelle kollabiert, Email auto-linked, Block-Quote zerstoert, Datenverlust in Frontmatter). Das passierte parallel zu Obsidian-Start (16:56) und mehreren laufenden AI-Sessions.

## Was harmlos ist

**Auto-Push-Skript (`_migration/auto-push.ps1`):** Tut nur `git status` -> `git add -A` -> `git commit` -> `git push`. Beruehrt KEINE Datei-Inhalte. Der 11:41-Auto-Push-Commit hat die bereits-kaputten Files committet, war aber nicht der Verursacher. Scheduled Task laeuft korrekt, Last Result = 0.

**`dash-replacer.py`:** Macht `content.replace(EM_DASH, '-')` - harmlos, aendert nur Zeichen.

**Git-Hooks:** Keine installiert (nur `.sample` Files).

**`.gitattributes`:** Existiert nicht.

**Obsidian Community-Plugins:** `community-plugins.json` existiert nicht, `plugins/` Ordner existiert nicht. Keine Community-Plugins installiert.

## Was potentiell relevant ist

| Komponente | Status | Verdacht |
|---|---|---|
| Obsidian Properties Plugin (`properties: true`) | aktiv | mittel - parst Frontmatter |
| Obsidian Bases Plugin (`bases: true`) | aktiv | mittel - neuer Typ |
| Obsidian File-Recovery (`file-recovery: true`) | aktiv | niedrig - nur Snapshots in IndexedDB |
| `alwaysUpdateLinks: true` in app.json | aktiv | niedrig - nur Wikilink-Updates |
| `core.autocrlf = true` (lokal git) | aktiv | indirekt - alle aktuellen Korruptionen sind LF, deutet auf Cross-Platform-Tool hin |

## Was hochverdaechtig ist

**Mehrere AI-Tools laufen JETZT:**

```
claude.exe (Claude Desktop) - PID 17992 + 15 Subprozesse
  Eingebettete node.mojom.NodeService Subprozesse als MCP-Servers
  
claude --dangerously-skip-permissions (Claude Code) - 2 Instanzen
  PID 11952 (Parent 20948)
  PID 10644 (Parent 16080)
  
Aktive MCP-Servers (npm-cached):
  @upstash/context7-mcp
  @21st-dev/magic
  shadcn-ui-mcp-server
```

Die `--dangerously-skip-permissions` Sessions koennen ohne Confirmation Files schreiben. Wenn dort ein Skript-Run mit kaputten str_replace/Write-Operationen lief, wuerde das genau die beobachteten Patterns erzeugen.

## Korruptions-Cluster (Zeitstempel-Analyse)

Aus `Get-ChildItem -Recurse | Where-Object LastWriteTime >= 2026-04-25 12:00`:

**Cluster A - 25.04 zwischen 20:51 und 20:53 (5 Files in 64s):**
- `03-kontakte/christian-pulse.md` (20:51:44)
- `03-kontakte/kai-pulse.md` (20:52:09)
- `03-kontakte/german-pulse.md` (20:52:15)
- `03-kontakte/patrick-pulse.md` (20:52:42)
- `03-kontakte/lizzi-pulse.md` (20:52:48)

Alle 5 sind aktuell noch kaputt (Pattern A: Frontmatter zu einer Zeile mit `## ` Prefix, Backslash-Escapes auf Klammern, kaputte Wikilink-Arrays). Identischer Mass-Edit-Run.

**Cluster B - 26.04 zwischen 16:53 und 17:19 (13 Files in 26 Min):**
- 16:53: firmenstruktur.md, lab-workflow-janoshik.md, produkte.md
- 16:55: kalani-call-orderprozess.md, janoshik-ocr.md, kalani-coo-call.md
- 16:58: zy-peptides.md, 2026-04-26.md
- 17:00: lab-peptides.md, lieferanten.md, 2026-04-16-kalani-onboarding-firmenstruktur.md, 2026-04-20-kalani-call.md, 2026-04-24-kalani-call.md, 2026-04-25-kalani-call.md
- 17:19: bestellprozess.md, clickup-pulse-entwurf.md

Obsidian wurde 16:56 gestartet. Vor Obsidian-Start sind 3 Files modifiziert (16:53), nach Start die anderen. Der Cluster ist zeitlich an Obsidian-Aktivitaet gekoppelt.

`lab-peptides.md` ist aktuell sichtbar kaputt (git diff zeigt Korruption seit letztem Commit):
- Email zu `[lily@lab-peptides.com](mailto:lily@lab-peptides.com)` auto-linked
- Tabelle kollabiert: `| Kanal | Wert |...` zu `KanalWertEmail...`
- Block-Quote-Zeilen zusammengeklatscht
- **Datenverlust:** `quelle: pdf_pricelist + voice_dump` zu `quelle: pdf_pricelist`

## Korruptions-Patterns (klare Fingerabdruecke)

Alle Patterns sind konsistent mit einem **Markdown-zu-Markdown-Roundtrip ueber HTML-AST** wie Pandoc, Marked.js oder eine CommonMark-basierte Library:

1. **Pattern A (Frontmatter `## ` Prefix):** YAML wurde im AST als HR + Plain-Text-Block gelesen, beim Reserialisieren als H2 ausgegeben.
2. **Tabellen-Kollaps:** Tabellen wurden als Plain-Text gelesen, ohne Markdown-Strukturerkennung.
3. **Backslash-Escapes:** `[`, `]` werden im Markdown-Output systematisch escaped, weil das Tool im Konversions-Schritt jedes Zeichen als potentiell Link-Syntax behandelt.
4. **Auto-Linking:** URLs und Email-Adressen werden zu Markdown-Links - Standard-Verhalten von Markdown-Convertern mit aktivem Auto-Link.
5. **Block-Quote-Reflow:** Hard-Wrapped Quotes werden auf eine Zeile zusammengezogen, weil der Renderer Soft-Wrapping erwartet.
6. **LF statt CRLF:** Trotz Windows-System schreibt das Tool LF. Cross-Platform-Library oder Web-Tool.

## Hypothesen-Ranking nach Phase 0

| ID | Hypothese | Evidenz | Confidence |
|---|---|---|---|
| H1 | Auto-Push-Task | Skript inspiziert, kein Content-Touch | WIDERLEGT |
| H2 | Umlaut-Fix-Skript am 25.04 | dash-replacer.py harmlos, dieselben Files heute neu betroffen | TEILWEISE WIDERLEGT (war nicht Einzel-Event) |
| H3 | Properties Plugin | Pattern A passt nicht zu Properties-Output | UNWAHRSCHEINLICH |
| H4 | Bases Plugin | Kein Beweis | UNKLAR |
| H5 | File-Recovery | Snapshot-Ordner existiert nicht | WIDERLEGT |
| H6 | OneDrive/externe Sync | OneDrive nicht im Pfad | WIDERLEGT |
| H7 | Community-Plugin | Keine installiert | WIDERLEGT |
| **H8 (NEU)** | **AI-Tool Schreib-Roundtrip (Claude Desktop oder Claude Code Session)** | Mehrere AI-Prozesse laufen, --dangerously-skip-permissions aktiv, Cluster B faellt zeitlich mit Obsidian/Claude-Aktivitaet zusammen, Korruptions-Pattern matcht typischen Markdown-AST-Roundtrip | **HOCH** |
| H9 (NEU) | MCP-Server (Filesystem-Tool) | Mehrere MCP-Server laufen, einer koennte Files lesen+schreiben mit Reformatierung | mittel |

## Naechste Schritte (vor Phase 1)

Drei Eingaben vom User noetig:

1. **Was war/ist im Claude Desktop oder Claude Code Chat aktiv heute?** Speziell ab 16:00. Hat eine Session Files in pulsepeptides angefasst?
2. **Welche MCP-Servers sind in Claude Desktop konfiguriert?** Dort koennte ein Filesystem-MCP sein der Markdown-Roundtrip macht.
3. **Erlaubnis fuer Watch-Test:** Hex-Snapshot der noch-kaputten `christian-pulse.md` jetzt, dann 5 Min idle (ohne Obsidian/AI-Aktion) - aendert sich was = laufender Watcher, aendert sich nichts = Trigger-basiert.
