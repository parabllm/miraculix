---
typ: forensik
phase: 1
datum: 2026-04-26
zeitpunkt: 19:55
---

# Phase 1 - System-Forensik

## Backup-Status

| Artefakt | Pfad | Groesse | Status |
|---|---|---|---|
| Git-Bundle (komplette History) | `02-vault.bundle` | 25.23 MB | OK |
| Working-Tree-Diff | `02-working-tree-changes.patch` | 67.2 KB | OK |
| Working-Tree-Status | `02-working-tree-status.txt` | 3.3 KB | OK |
| Untracked-Files | `02-untracked/` | 7 Files | OK |
| Vault-Zip | `02-vault-backup.zip` | 23.6 KB (NUTZLOS) | FEHLGESCHLAGEN: pulsepeptides.md gesperrt |

**Wichtiger Lock-Befund:** Beim Versuch das Vault per `Compress-Archive` zu zippen war `01-projekte/pulsepeptides/pulsepeptides.md` von einem anderen Prozess gehalten ("Der Prozess kann nicht auf die Datei zugreifen, da sie von einem anderen Prozess verwendet wird"). Das ist ein direkter Hinweis dass etwas die Datei aktiv haelt - vermutlich Obsidian.

## Obsidian-Plugin-Status

`.obsidian/plugins/` Ordner existiert NICHT. Keine Community-Plugins. Bestaetigt.

`.obsidian/core-plugins.json` (alle aktiven Core-Plugins relevant fuer Frontmatter):

| Plugin | Aktiv | Risiko |
|---|---|---|
| `properties` | true | hoch - reserialisiert YAML beim Open/Save |
| `bases` | true | hoch - neues Feature, parst Frontmatter fuer DB-Views |
| `file-recovery` | true | mittel - Snapshots in IndexedDB |
| `outline`, `tag-pane`, `backlink`, `outgoing-link` | true | niedrig - read-only |
| `sync` | false | safe |

Obsidian-Version laut workspace.json-Title: **1.12.7**.

## Claude Desktop Extensions

Vier Extensions installiert in `C:\Users\deniz\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\Claude Extensions\`:

| Extension | Enabled | Tools (relevant) | Allowed-Dirs | Risiko |
|---|---|---|---|---|
| `ant.dir.ant.anthropic.filesystem` | **TRUE** | `read_file`, `write_file`, `edit_file`, `move_file` | **`C:\Users\deniz\Documents`** plus 3 weitere | **HOCH** |
| `ant.dir.gh.wonderwhy-er.desktopcommandermcp` | **TRUE** | `read_file`, `write_file`, `edit_block`, `move_file` | unbeschraenkt | **HOCH** |
| `ant.dir.cursortouch.windows-mcp` | false | (disabled) | - | safe |
| `ant.dir.gh.anthropic.pdf-server-mcp` | true | (PDF-only) | - | niedrig |

**Befund:** Filesystem-MCP hat den Vault explizit in `allowed_directories`. Desktop Commander hat keine Beschraenkung. Beide koennen Vault-Files schreiben.

User-Aussage: aktuelle Session benutzt diese MCPs nicht. ABER: Beide werden bei Claude-Desktop-Start automatisch geladen und liefern Tools an den LLM. Wenn ein anderes Skript oder Auto-Trigger sie aufruft (z.B. via cowork/ccd), passiert das ohne User-Bestaetigung.

**Desktop Commander Update-Zeitpunkt: 24.04.2026 19:56** - 24 Stunden vor der ersten dokumentierten Korruption (25.04 20:51).

## Cowork/CCD Scheduled Tasks

`Get-ScheduledTask | Where-Object TaskName -match "cowork|ccd|claude|anthropic"` lieferte **keine Treffer**. Kein Scheduled Task mit Cowork-Bezug auf System-Ebene.

User-Aussage: `ccdScheduledTasksEnabled: true, coworkScheduledTasksEnabled: true` ist als Flag in der Claude-Config. Da kein OS-Task existiert, lebt das vermutlich intern in Claude Desktop (eigener Scheduler in der App). Kein direkter Beweis verfuegbar ohne Zugriff auf Claude-Desktop-Internal-State.

## Sync-Pfad-Pruefung

| Pfad | Status |
|---|---|
| `C:\Users\deniz\OneDrive` | existiert (Personal-Account) |
| `C:\Users\deniz\Documents` | NICHT in OneDrive (kein Reparse Point) |
| `C:\Users\deniz\Documents\miraculix` | nicht symlinked, kein junction |

**Befund:** Vault liegt NICHT in OneDrive-synced Ordner. Documents ist nicht als "Bekannter Ordner" in OneDrive gesichert. Sync-Hypothese (H6) WIDERLEGT.

## Git-Konfiguration

| Setting | Wert | Bewertung |
|---|---|---|
| `core.autocrlf` | true | irrelevant - alle aktuellen Korruptionen sind LF, Git wuerde sie bei Touch konvertieren, hat es aber noch nicht |
| `core.eol` | (unset) | OK |
| `core.safecrlf` | (unset) | OK |
| `.gitattributes` | nicht vorhanden | OK |
| Git-Hooks | nur `.sample` | OK |

## Recently-Modified-Files (24h)

Cluster A (25.04 abends 20:51-20:53): 5 Files alle pulse-Kontakte, Pattern A noch sichtbar
Cluster B (26.04 16:53-17:19): 13 Files alle pulsepeptides, Cluster faellt mit Obsidian-Start (16:56) zusammen

`lab-peptides.md` ist die einzige bestaetigte Korruption von Cluster B (Tabelle kollabiert, Email auto-linked, Block-Quote zerstoert, **Datenverlust** in `quelle:`).

## Aktualisierte Hypothesen

| ID | Hypothese | Status nach Phase 1 | Confidence |
|---|---|---|---|
| H1 | Auto-Push-Task | WIDERLEGT (Skript modifiziert keine Inhalte) | hoch |
| H2 | Umlaut-Fix-Skript | TEILWEISE WIDERLEGT (dash-replacer harmlos, aber zwischen 25.04-26.04 lief was anderes) | hoch |
| H3 | Properties Plugin | UNGEKLAERT - braucht Plugin-Isolations-Test in Phase 4 | mittel |
| H4 | Bases Plugin | UNGEKLAERT - dito | mittel |
| H5 | File-Recovery | unwahrscheinlich (Snapshots in IndexedDB beruehren keine Files) | niedrig |
| H6 | OneDrive | WIDERLEGT (Vault nicht in OneDrive) | hoch |
| H7 | Community-Plugin | WIDERLEGT (Ordner existiert nicht) | hoch |
| **H8a** | **Anthropic Filesystem MCP (Roundtrip)** | **MOEGLICH** - hat Zugriff, aber User sagt nicht aufgerufen | mittel |
| **H8b** | **Desktop Commander MCP** | **HOCH** - User-Memory: hat schon Bug verursacht. Update am 24.04 24h vor erster Korruption | hoch |
| H8c | Cowork/CCD Internal Scheduler | UNGEKLAERT - kein OS-Task, vermutlich App-intern | mittel |
| **H10 (NEU)** | **Obsidian-Trigger plus MCP-Combination** | sehr wahrscheinlich - Cluster B faellt zeitlich mit Obsidian-Start zusammen, aber MCP haelt Schreibrecht | hoch |

## Naechster Schritt

Phase 2: Vault-weiter Bug-Scan. Erkennt **alle** kaputten Files (nicht nur die 5 pulse-Kontakte und lab-peptides.md). Liefert das Daten-Bild fuer Phase 3 (Reproducer).

Erst dann Phase 3 mit User-Beteiligung (Plugin-Isolations-Test plus Trigger-Variation).
