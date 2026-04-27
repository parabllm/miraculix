---
name: miraculix-vault-system
description: Always-on context for working with Deniz Özbek's Obsidian Second Brain "Miraculix". Use this skill whenever Deniz mentions his vault, projects, Obsidian, his personal knowledge base, or asks anything about his work context (Thalor, Coralate, HAYS, BellaVie, HeroSoftware, Resolvia, PulsePeptides, Bachelor-Thesis, Terminbuchungs-App). Also trigger when Deniz uses trigger words like "tages-start", "log", "eingang verarbeiten", "abgleich", "vault prüfen". Contains vault structure, active projects, knowledge domains, naming conventions, and provenance rules. This skill is the foundation - read it first before any vault operation.
---

# Miraculix Vault-System

Deniz Özbeks Obsidian-Vault ist die Single Source of Truth für alle Projekte, Wissen, Kontakte und Logs. Dieser Skill enthält die Grundstruktur und Regeln.

**Vault-Pfad:** `C:\Users\deniz\Documents\miraculix\`

**Kommunikationsstil mit Deniz:** Deutsch, direkt, kein Smalltalk, kritischer Sparringspartner. Fachbegriffe auf Englisch. Strukturiert, scanbar, keine Prosa-Wände.

---

## VAULT-SCHREIBREGELN (PFLICHT, immer beachten)

Bevor irgendein .md-File im Vault geschrieben oder editiert wird:

1. NIE Desktop Commander `write_file` oder `edit_block` fuer .md mit YAML-Frontmatter (Pretty-Printer-Roundtrip-Bug korruptiert Frontmatter, Pattern A).
2. Sichere Methoden: PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 NoBOM, Filesystem-MCP `write_file`/`edit_file`, Claude-Code Write-Tool.
3. Hex-Verify nach JEDEM Write Pflicht. Erste 8 Bytes muessen `2D 2D 2D 0A 74...` ergeben, NICHT `2D 2D 2D 0A 0A 23 23` (Pattern A).

Pflicht-Lektuere VOR jedem Vault-Write (kein Optional):

| Datei | Regelt |
|---|---|
| [[vault-schreibkonventionen]] | **WAS** in Files steht (Encoding, Umlaute, Naming, Gedankenstriche) |
| [[vault-schreibregeln]] | **WIE** Files geschrieben werden (Tools, Verify, Rollback, Bug-Patterns) |

Wenn diese Files nicht im aktuellen Kontext sind: read jetzt. Annahme "kenne ich schon" ist Quelle vergangener Bugs.

---

## Ordnerstruktur

```
00-eingang/           Inbox (Voice-Dumps, Transkripte, Chat-Exports, Dateien)
01-projekte/          Über-Projekte > Sub-Projekte (max 2 Ebenen)
02-wissen/            Cross-Project Transferable Skills
03-kontakte/          Ein File pro Person
04-tagebuch/          Daily Notes (YYYY/MM/YYYY-MM-DD.md)
05-archiv/            Abgeschlossenes
_api/                 API-Keys (.env), Templates, Doku, generierte JSONs
                      Komplett gitignored ausser .env.example und *.md
_anhaenge/            Große Dateien (PDFs, Excel, PPTX) - nicht im Git
_claude/skills/       Master-Version der Skills (ist dort UND im Account-Skill-UI)
_claude/scripts/      Lokale Skripte (lesen Keys aus _api/.env)
_meta/                Schema + Glossar + Endpoints
_migration/           Migrations-Artefakte (Progress, Report)
```

---

## Aktive Über-Projekte

| Über-Projekt | Pfad | Bereich | Status |
|---|---|---|---|
| Thalor | `01-projekte/thalor/` | client_work | aktiv - 4 Sub: herosoftware, bellavie, pulsepeptides, resolvia |
| Coralate | `01-projekte/coralate/` | produkt | aktiv - Sub: food-scanner |
| HAYS | `01-projekte/hays/` | intern | aktiv - Werkstudent CEMEA License Management |
| Bachelor-Thesis | `01-projekte/bachelor-thesis/` | studium | aktiv - Abgabe 2026-06-15 KRITISCH |
| Miraculix | `01-projekte/miraculix/` | intern | aktiv - dieser Vault + KI-Orga |
| Persönlich | `01-projekte/persönlich/` | persoenlich | aktiv - Sub: familie, zukunftsplaene, personal-development, kommunikation-referenzen |
| Terminbuchung-App | `01-projekte/terminbuchung-app/` | produkt | pausiert bis nach Thesis |

Tabelle wird manuell gepflegt wenn neue Über-Projekte entstehen. Deniz sagt dann explizit "neues Über-Projekt: X".

**Umlaut-Hinweis Persönlich:** Der Ordner heißt `persönlich/` mit echtem Umlaut. Encoding-Regeln (welche Zonen UTF-8 vs ASCII) stehen in [[vault-schreibkonventionen]]. Tool-Sicherheit (welche Schreibmethoden sicher sind, Hex-Verify-Pflicht) steht in [[vault-schreibregeln]]. Beide IMMER konsultieren bei Operationen auf Files mit Umlauten im Pfad.

---

## File-Naming-Konvention

Projekt-Haupt-Files heißen `{slug}.md` (nicht `_projekt.md`), damit Obsidian-Wikilinks funktionieren.

Beispiel:
- `01-projekte/thalor/thalor.md`
- `01-projekte/thalor/herosoftware/herosoftware.md`

---

## Wissens-Domains

| Domain | Pfad |
|---|---|
| Architektur | `02-wissen/architektur/` |
| Claude Prompting | `02-wissen/claude-prompting/` |
| Claude Workflow | `02-wissen/claude-workflow/` |
| CRM-Integration | `02-wissen/crm-integration/` |
| Design | `02-wissen/design/` |
| Integration | `02-wissen/integration/` |
| Marketing | `02-wissen/marketing/` |
| n8n | `02-wissen/n8n/` |
| Power Automate | `02-wissen/power-automate/` |
| React Native | `02-wissen/react-native/` |
| Supabase | `02-wissen/supabase/` |

---

## Sub-Projekt: Kommunikation-Referenzen

**Pfad:** `01-projekte/persönlich/kommunikation-referenzen/`

**Zweck:** Zentrales Rohmaterial-Archiv für archivierte Kommunikations-Threads (E-Mail, Slack, WhatsApp, Teams). Projekt-übergreifend. Dient als Pool für spätere Skill-Destillation.

**Struktur:**
```
kommunikation-referenzen/
├── kommunikation-referenzen.md     # Master-File mit Schema + Regeln
├── email/
├── slack/
├── whatsapp/
└── teams/
```

**Ablage-Regel (wichtig):** Threads werden NUR hier archiviert wenn Deniz es explizit sagt. Keine proaktive Archivierung. Wenn E-Mails im Eingang landen, nicht automatisch dorthin sortieren ohne Rücksprache.

**Dateinamens-Konvention:** `YYYY-MM-DD_kontakt-slug_thema.md` (Datum = Thread-Start, kontakt-slug = Wikilink-Form).

**Frontmatter-Schema für Thread-Files:**
```yaml
typ: kommunikation-thread
kanal: email | slack | whatsapp | teams
projekt: <projekt-tag>
kontakte: ["[[kontakt-slug]]"]
herkunft: gmail_export | slack_screenshot | whatsapp_export | etc.
richtung: outbound | inbound | beidseitig
status: aktiv | abgeschlossen | wartend
thema: "Kurze Beschreibung"
datum_start: YYYY-MM-DD
datum_ende: YYYY-MM-DD
```

**HAYS-Vertraulichkeit:** Deniz behandelt HAYS-interne Threads gesondert, keine spezielle Kennzeichnung im Vault nötig. Darauf nicht mehr hinweisen.

**Destillations-Ziel:** Bei 5+ Threads pro Kommunikationstyp kann ein Skill gebaut oder ein bestehender erweitert werden (z.B. `hays-email-kommunikation`, `pulse-slack-schreibstil`).

---

## Grundprinzipien

1. **Obsidian ist SSOT.** Google Calendar/Tasks sind operative Ansichten, nie Quelle.
2. **Nie raten, immer fragen.** Lieber Rückfrage als falsch einsortiert.
3. **Jede Aussage braucht Provenance:** `quelle:` + `vertrauen:` Felder im Frontmatter.
4. **Inbox ist der einzige Eingang** für externes Material.
5. **Wissen wächst mit.** Bei gelöstem Problem zuerst `02-wissen/` prüfen, dann ggf. destillieren.

## Vertrauens-Stufen (Pflicht)

- `extrahiert` - direkt aus Quelle
- `abgeleitet` - logisch geschlossen mit Begründung
- `angenommen` - Vermutung, braucht Prüfung
- `bestaetigt` - nach expliziter Bestätigung hochgestuft

## Operations-Trigger

| Trigger | Was passiert |
|---|---|
| "tages-start" | Daily Note, Kalender, Tasks, Kapazität |
| "eingang verarbeiten" | Inbox durchgehen, klassifizieren |
| "abgleich X" | Projekt X mit neuen Inputs abgleichen |
| "vault prüfen" | Konsistenz-Check |
| "log" | Session-Erkenntnisse speichern |
| "leg das in kommunikation-referenzen" | Thread im passenden Kanal-Unterordner ablegen |

## Schreibstil für Vault-Content

Wenn Miraculix Content in Vault-Files schreibt (Logs, Projekt-Stände, Wissens-Einträge, Meetings, Frontmatter-Werte): lade den `miraculix-schreibstil` Skill. Der enthält 10 Regeln gegen AI-Slop (keine Gedankenstriche, keine Wichtigkeits-Inflation, keine Rule of Three etc.).

Gilt NICHT für Chat-Antworten an Deniz. Nur für Content der in `.md` Files landet.

## Was NIE tun

- Generierte JSONs in `_api/` manuell editieren (werden generiert)
- `_meta/` oder `CLAUDE.md` ändern ohne Anweisung
- Frontmatter-Schema erfinden das nicht in `_meta/schema.md` steht
- Mehrere Files gleichzeitig ändern ohne vorher Plan zu zeigen
- Informationen zwischen Projekten kopieren - stattdessen Wikilinks
- API-Keys im Klartext (immer über `_api/.env` und `_api/env-konfiguration.md`)
- Threads proaktiv nach `kommunikation-referenzen/` archivieren - nur auf expliziten Anstoß
- **Dateinamen beim Archivieren oder Verschieben ändern.** Beim Verschieben nach `05-archiv/` oder zwischen Ordnern bleibt der Dateiname exakt gleich. Status-Indikatoren ("verschoben", "archiviert", "alt") gehören ins Frontmatter (`status: archiviert`), niemals in den Dateinamen. Umbenennung bricht alle Wikilinks.

## Skripte und Secrets

Der `_api/` Ordner ist die zentrale Stelle für alles API-bezogene: Keys, Templates, Doku, generierte JSON-Endpoints. Komplett gitignored, nur `.env.example` und `*.md` werden committed.

- Echte Werte: `_api/.env`, NICHT committed
- Template: `_api/.env.example`, committed
- Doku mit Variablen-Liste, Status-Tabelle, Code-Snippets: `_api/env-konfiguration.md`, committed
- Skripte selbst: `_claude/scripts/`
- Audio-Drops für Transkription: `00-eingang/audio/`

Wenn ein neuer Key gebraucht wird oder eine neue Variable angelegt werden soll: erst `_api/env-konfiguration.md` lesen, dort die Status-Tabelle pflegen, dann `_api/.env` und `_api/.env.example` parallel updaten.

Wenn ein Skript gebraucht wird das einen externen API-Key nutzt: Skript in `_claude/scripts/` ablegen, Key über `python-dotenv` oder PowerShell-Loader aus `_api/.env` laden, Variablen-Name muss in `_api/.env`, `_api/.env.example` und `_api/env-konfiguration.md` existieren.
