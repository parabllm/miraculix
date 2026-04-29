---
typ: wissen
domain: vault-architektur
status: aktiv
erstellt: 2026-04-29
zuletzt_aktualisiert: 2026-04-29
vertrauen: extrahiert
quelle: konsolidierung-aus-vault-system-vault-mcp-architektur-und-eingang-verarbeiten-2026-04-29
prioritaet: hoch
---

# Vault-Topologie

Karte des Miraculix-Vaults: wo lebt was, wer schreibt dorthin, wie fließt es. Zentrale Referenz für jeden Claude (Code, Desktop, Mobile) der mit dem Vault arbeitet.

Komplementär zu:
- [[vault-system]] - Grundregeln, Naming, Vertrauensstufen
- [[vault-mcp-architektur]] - Mobile-Capture über Hetzner-MCP
- [[vault-schreibkonventionen]] - Encoding, Umlaute, ASCII-Zonen
- [[vault-schreibregeln]] - sichere Schreibmethoden, Hex-Verify

---

## Drei Capture-Kanäle, drei Eingänge

Jeder Input in den Vault läuft über einen von drei Kanälen. Jeder Kanal hat einen eigenen Eingangsordner. Direkte Edits am echten Vault-Inhalt gehen nur lokal vom PC.

| Kanal | Wer schreibt | Eingang | Verarbeitung | Trust |
|---|---|---|---|---|
| **PC direkt** | Claude Code, Claude Desktop, Obsidian, Filesystem-Tools | (kein Eingang, direkter Edit) | live | extrahiert |
| **Klassische Inbox** | Voice-Recorder, Drive-Sync, manuelle Drops, E-Mail-Forward | `00-eingang/{audio,transkripte,chat-exports,unverarbeitet}/` | Skill `eingang-verarbeiten` | rohinput, Triage Pflicht |
| **Mobile via Vault-MCP** | Claude Mobile App über `https://miraculix.thalor.de/mcp` | `00-vault-mcp-eingang/` | Skill `eingang-verarbeiten` Sektion "MCP-Eingang Merge" | strukturierter Vorschlag, Plausibilitätscheck Pflicht |

Mobile-Claude darf **niemals** direkt in echte Vault-Files schreiben. Der MCP-Server blockt das auf System-Ebene.

---

## Heimatorte

Wo dauerhafte Vault-Inhalte leben. Jeder Ordner hat einen klaren Zweck, daran orientiert sich die Konvention beim Anlegen neuer Files.

### 01-projekte/

Über-Projekte und Sub-Projekte, max 2 Schachtelungs-Ebenen.

```
01-projekte/
├── pulsepeptides/
│   ├── pulsepeptides.md           # Über-Projekt-File mit Sub-Projekt-Liste
│   ├── logs/                       # Meeting-Notes, Call-Logs (eigene Files pro Termin)
│   ├── coo-aufgaben.md
│   ├── eppelheim-lager.md
│   └── lager-tschechien/           # Sub-Projekt
│       └── lager-tschechien.md
├── thalor/
│   ├── thalor.md
│   └── bellavie/                   # Sub-Projekt
├── hdwm/
│   ├── hdwm.md
│   ├── semester-5/
│   └── semester-6/
│       ├── innovationsmanagement.md   # Vorlesungs-File mit Sektionen pro Termin
│       ├── it-systeme.md
│       └── ...
└── ...
```

Konventionen variieren pro Über-Projekt:

| Über-Projekt | Konvention für Termin-Notes |
|---|---|
| Pulsepeptides | eigener File pro Call: `logs/YYYY-MM-DD-thema.md` mit `typ: meeting-note` |
| Thalor (+Sub-Projekte) | eigener File: `{sub-projekt}/logs/YYYY-MM-DD-thema.md` |
| HDWM | Sektionen IN `semester-X/{vorlesung}.md` unter `## Zusammenfassungen`, KEIN logs-Ordner |
| Bachelor-Thesis | eigener File pro Session: `logs/YYYY-MM-DD-thema.md` |
| HAYS | eigener File: `logs/YYYY-MM-DD-thema.md` |
| Persönlich | meist Sektionen, je nach Sub-Projekt |

**Vor neuem File: Konvention via `vault_list_directory` + `vault_read_file` checken, nicht raten.** Siehe Skill `vault-mcp-artefakt-erstellen` Sektion "Pfad finden, nie raten".

### 02-wissen/

Cross-Project Transferable Skills. Was nicht zu einem Projekt gehört sondern allgemein gültig ist.

```
02-wissen/
├── architektur/
├── claude-prompting/
├── claude-workflow/
├── crm-integration/
├── design/
├── health/
├── integration/
├── lexware/
├── marketing/
├── n8n/
├── power-automate/
├── react-native/
├── supabase/
├── vault-system.md
├── vault-mcp-architektur.md
├── vault-topologie.md          # dieses File
├── vault-schreibkonventionen.md
└── vault-schreibregeln.md
```

Wann landet was hier: Pattern hat sich 2× wiederholt, lessons learnt sind übertragbar auf neue Situationen.

### 03-kontakte/

Ein File pro Person. `kontakt-slug.md`, snake-case-frei (kein Underscore im Namen, kebab-case wie alles andere).

```
03-kontakte/
├── kalani-ginepri.md
├── maddox-yakymenskyy.md
├── christoph-sandbrink.md
└── ...
```

Frontmatter pflichtfelder: `typ: kontakt`, `aliase`, `projekte`, `kommunikations_kanaele`.

Personen ohne Projekt-Bezug: trotzdem hier, nicht weglassen.

### 04-tagebuch/

Daily Notes nach Pfad-Pattern `YYYY/MM/YYYY-MM-DD.md`. Strikt chronologisch.

```
04-tagebuch/
└── 2026/
    └── 04/
        ├── 2026-04-28.md
        └── 2026-04-29.md
```

Inhalt pro Tag: Kapazität (Energie + Zeit), Fokus-Projekte, Kalender-Snapshot, Tages-Review. Wird vom Skill `tages-start` angelegt und gepflegt.

Tagebuch ist **kein** Sammelbecken für Projekt-Inhalte - die gehören in `01-projekte/`. Tagebuch hält nur den Tages-Kontext.

### 05-archiv/

Abgeschlossenes. Inhalt wird verschoben (nicht kopiert), Status auf `archiviert` gesetzt, Dateiname **bleibt gleich** (Wikilinks würden sonst brechen).

```
05-archiv/
├── thalor/                                       # Über-Projekte beim Abschluss
├── vault-mcp-eingang-verarbeitet/                # gemergede Mobile-Artefakte
│   └── 2026-04/
│       ├── 2026-04-29-1210-kalani-maman-lager-neue-datei.md
│       └── 2026-04-29-1500-innovationsmanagement-test-neue-datei.md.verworfen
└── ...
```

Speziell: `vault-mcp-eingang-verarbeitet/YYYY-MM/` ist die Archiv-Zone für gemergede Mobile-Artefakte. Suffix `.verworfen` markiert Artefakte die nicht gemerged sondern verworfen wurden (z.B. Test-Notes).

---

## Eingänge im Detail

### 00-eingang/

Klassische Inbox. Vier Subfolders mit unterschiedlichen Dateiarten:

```
00-eingang/
├── audio/                          # Voice-Dumps von Telefon, Recorder
│   └── kalani-call-2026-04-25.m4a
├── transkripte/                    # Whisper/Otter-Output, manuell oder via Skill
│   └── heinrich-innovationsmanagement-hdwm-2026-04-29.md
├── chat-exports/                   # Claude/ChatGPT Konversations-Exports
└── unverarbeitet/                  # Alles andere - Notizen, Scans, Drops
```

**Verarbeitung:** Skill `eingang-verarbeiten`. Routet pro Subfolder:
- audio → `audio-verarbeiten`
- transkripte mit `status: unverarbeitet` → `transkript-verarbeiten`
- chat-exports + unverarbeitet → klassische Triage (klassifizieren, Wikilinks, in Heimatort verschieben)

**Trust-Niveau:** Rohinput. Nichts ist verifiziert, alles braucht Klassifizierung und Provenance-Felder.

### 00-vault-mcp-eingang/

Drop-Zone für Mobile-Artefakte. Eigener Top-Level-Ordner, nicht unter `00-eingang/`.

```
00-vault-mcp-eingang/
├── README.md                       # Dokumentation, system-marker
├── .gitkeep
└── 2026-04-29-1530-pulse-status-update-ergaenzung.md  # Beispiel-Artefakt
```

**Wer schreibt:** ausschließlich der Vault-MCP-Server auf Hetzner über `vault_create_artefakt` und `vault_update_artefakt`.

**Wie kommt's zum PC:** Syncthing pusht von Hetzner zum PC binnen Sekunden. PC-Folder ist `Receive Only`, kann also keine Änderungen zurückdrücken. Master für diesen Folder ist Hetzner.

**Verarbeitung:** Skill `eingang-verarbeiten` Sektion "MCP-Eingang Merge" (M.1-M.8). PC-Claude validiert Header + Hashes, zeigt Dry-Run, fragt OK, merged in Heimatort, archiviert nach `05-archiv/vault-mcp-eingang-verarbeitet/YYYY-MM/`.

**Trust-Niveau:** strukturierter Vorschlag. Mobile-Claude hat schon recherchiert (Pfad-Konvention, Wikilinks, Hashes). Aber: Token-Besitz beweist nicht inhaltliche Korrektheit. Plausibilitätscheck Pflicht.

**Filename-Pattern:** `YYYY-MM-DD-HHMM-{slug}-{aktion}.md` mit `aktion ∈ {neue-datei, ergaenzung, ersetzen-sektion}`.

---

## System-Ordner

Nicht Vault-Content, sondern Infrastruktur. Großteils gitignored oder mit Sonderregeln.

### _api/

API-Keys, Templates, Doku, generierte JSONs. Gitignored bis auf `.env.example` und `*.md`.

```
_api/
├── .env                            # gitignored, echte Secrets
├── .env.example                    # committed, Schema
├── env-konfiguration.md            # committed, Variablen-Tabelle
└── (generierte JSONs)              # gitignored
```

**Sperrzone für Vault-MCP** - sowohl Read als auch Write geblockt durch Pfad-Policy. Begründung: Read-only schützt nicht vor Secret-Leak. Falls jemand `.env` liest, ist sie kompromittiert.

### _claude/

Operations-Skills und lokale Skripte.

```
_claude/
├── skills/                         # Master-Version der Skills
│   ├── tages-start.md
│   ├── eingang-verarbeiten.md
│   ├── vault-system.md
│   ├── vault-mcp-artefakt-erstellen.md
│   └── ...
└── scripts/                        # Lokale Skripte (vault-health, backups, etc.)
    └── vault-mcp-merge-backups/    # Backup-Zone vor riskanten Merges
```

**Wichtig:** `.claude/` (mit Punkt) im Vault-Root ist Claude-Code-Worktree-State und gitignored. `_claude/` (mit Underscore) ist Vault-Inhalt und committed.

### _meta/

Schema, Glossar, Endpoint-Übersicht.

```
_meta/
├── schema.md                       # Frontmatter-Typen und Pflichtfelder
├── glossar.md                      # Begriffe, Aliase
└── endpoints.md                    # API-Endpunkte (intern + extern)
```

Wird **nicht** über Mobile-MCP geändert. Nur PC-Claude mit expliziter Anweisung.

### _migration/

Einmalige Migrations-Artefakte (Notion-Migration, Cleanup-Phasen). Nach Abschluss meist statisch.

### _anhaenge/

Große Binärdateien (PDFs, Excel, PPTX) die nicht im Git landen.

```
_anhaenge/
├── hays/
├── pulse/
└── thalor/
```

Gitignored, nicht in Syncthing-Mirror (siehe `.stignore`). Vault-MCP-Read gibt bei `_anhaenge/`-Pfaden den Hinweis "nicht im Mirror verfügbar" zurück.

---

## Capture-Flows

Wie Inputs vom Eingang in ihren Heimatort kommen.

### Flow A: Klassische Inbox-Triage

```
Voice-Recorder → 00-eingang/audio/kalani-call-2026-04-25.m4a
                  │
                  ↓ (Skill: audio-verarbeiten)
                  │
              Whisper-Transkription
                  │
                  ↓
              00-eingang/transkripte/kalani-call-2026-04-25.md
                  │
                  ↓ (Skill: transkript-verarbeiten)
                  │
              Inhaltliche Triage
                  │
                  ↓
              01-projekte/pulsepeptides/logs/2026-04-25-kalani-call.md
              + Updates in pulsepeptides.md (Aktuelle Kommunikation)
              + Tasks in Google Tasks
              + Eintrag in 03-kontakte/kalani-ginepri.md
```

### Flow B: Mobile-Artefakt-Merge

```
Mobile-Claude (Handy)
    │
    ├─ vault_list_directory → Pfad-Konvention erkennen
    ├─ vault_read_file → Wikilinks verifizieren
    ├─ vault_search → ähnliche Files finden
    │
    ↓
Artefakt mit zwei Frontmatter-Blöcken bauen:
  - Artefakt-Header (vault-mcp-artefakt + ziel_pfad + body_sha256 + pc_anweisung)
  - Output-File-Frontmatter (typ: meeting-note, projekt etc.)
    │
    ↓
vault_create_artefakt
    │
    ↓
Hetzner /opt/miraculix-vault/00-vault-mcp-eingang/2026-04-29-1530-thema-aktion.md
    │
    ↓ (Syncthing Hetzner→PC, Sekunden)
    │
PC C:\Users\deniz\Documents\miraculix\00-vault-mcp-eingang\
    │
    ↓ (User sagt "eingang verarbeiten")
    │
PC-Claude:
  - Header parsen, body_sha256 checken
  - bei ergaenzung: basis_sha256 gegen Zieldatei prüfen
  - Wikilinks verifizieren
  - pc_anweisung-Block lesen, Mobile-Annahmen ernst nehmen
  - Dry-Run zeigen mit Diff
  - OK von Deniz einholen
  - Merge in Heimatort (z.B. 01-projekte/pulsepeptides/pulsepeptides.md)
  - Hex-Verify nach Write
  - Artefakt → 05-archiv/vault-mcp-eingang-verarbeitet/2026-04/
```

### Flow C: PC-Direkt-Edit

```
Deniz im Claude-Code-Chat oder Obsidian
    │
    ↓
Read/Edit/Write nativ auf
01-projekte/{ueberprojekt}/{file}.md
    │
    ↓ (Syncthing PC→Hetzner, Sekunden)
    │
Hetzner /opt/miraculix-vault/ ist aktuell
    │
    ↓
Mobile-Claude liest später frischen Stand via vault_read_file
```

---

## Trust-Modell zusammengefasst

| Quelle | Trust | Konsequenz |
|---|---|---|
| PC-Direkt-Edit | extrahiert | direkt verfügbar als Wahrheit, Provenance via `quelle: chat_session` |
| Klassische Inbox | rohinput | Triage Pflicht, Frontmatter mit `vertrauen: angenommen` bis bestätigt |
| Mobile MCP-Artefakt | strukturierter Vorschlag | Plausibilitätscheck Pflicht, `pc_anweisung` und Hashes prüfen |
| Externe API (Mantle, Attio, Metorik) | extrahiert mit Quellen-Tag | Generierte JSONs nur in `_api/`, nie in Heimatorten |

---

## Sperrzonen für Mobile-MCP

Auch wenn Mobile-Claude technisch zugreifen könnte: diese Zonen sind durch Pfad-Policy geblockt oder durch Konvention verboten.

| Pfad | Block-Mechanismus | Grund |
|---|---|---|
| `_api/` | Server-Pfad-Policy | API-Keys / Secrets |
| `.git/` | Server-Pfad-Policy | Git-Internals |
| `.claude/` | Server-Pfad-Policy | Claude-Code-State, kein Vault-Inhalt |
| `_meta/` | Konvention (kein Block, aber Skill-Regel) | Schema-Änderungen brauchen Versionierung |
| `CLAUDE.md` | Konvention | systemweite Regel-Datei, nur PC mit expliziter Anweisung |
| `_migration/` | Konvention | abgeschlossene Migrations-Artefakte |
| `_claude/skills/` | Konvention (lesbar, nicht schreibbar) | Skills brauchen Tests am PC |

Mobile-Claude antwortet bei solchen Anfragen: **"Das muss am PC passieren, nicht über den Vault-MCP."**

---

## Lessons aus echten Verarbeitungen

### 2026-04-29 Kalani-Maman-Lager

Mobile schlug `03-meeting-notes/2026/2026-04-29-kalani.md` vor - der Top-Level-Ordner existiert nicht. Konvention für Pulse-Calls ist `01-projekte/pulsepeptides/logs/YYYY-MM-DD-thema.md`. Korrekt gemerged nach manuellem Pfad-Fix.

Lehre: Pfad-Erkundung via `vault_list_directory` + `vault_search` ist Pflicht vor `ziel_pfad`-Wahl.

### 2026-04-29 Innovationsmanagement-Test

Mobile schlug `01-projekte/hdwm/logs/2026-04-29-...md` vor - HDWM hat keinen `logs/`-Ordner. Konvention ist Sektionen IN `semester-X/{vorlesung}.md`. Test-Artefakt verworfen ohne Merge.

Lehre: Über-Projekt-spezifische Konvention beachten. HDWM nutzt das Sektion-Pattern, Pulsepeptides das Sub-File-Pattern. Skill `vault-mcp-artefakt-erstellen` enthält Tabelle mit aktuellem Stand.

---

## Was zu tun bei neuem Input

Quick-Decision-Tree:

```
Was kommt rein?
│
├─ Voice/Audio → 00-eingang/audio/ → audio-verarbeiten
│
├─ Transkript → 00-eingang/transkripte/ → transkript-verarbeiten
│
├─ Chat-Export → 00-eingang/chat-exports/ → eingang-verarbeiten Triage
│
├─ Unstrukturierter Dump → 00-eingang/unverarbeitet/ → eingang-verarbeiten Triage
│
├─ Strukturierter Vorschlag von Mobile → 00-vault-mcp-eingang/ → eingang-verarbeiten MCP-Merge
│
└─ Live am PC → direkt im Heimatort schreiben (kein Eingang nötig)
```

---

## Cross-Reference

- [[vault-system]] - Grundregeln, Vertrauensstufen, Operations-Trigger
- [[vault-mcp-architektur]] - Mobile-Capture-Architektur (Hetzner-MCP)
- [[vault-schreibkonventionen]] - Encoding, Umlaute, ASCII-Zonen
- [[vault-schreibregeln]] - Sichere Schreibmethoden, Hex-Verify, Bug-Patterns
- [[eingang-verarbeiten]] - Skill: Klassische Inbox + MCP-Merge
- [[tages-start]] - Skill: Daily Note plus Eingang-Status
- [[vault-pruefung]] - Skill: wöchentlicher Konsistenz-Check
- [[vault-mcp-artefakt-erstellen]] - Skill: Mobile baut Artefakte korrekt
