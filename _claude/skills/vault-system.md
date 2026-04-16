---
name: miraculix-vault-system
description: Always-on context for working with Deniz Özbek's Obsidian Second Brain "Miraculix". Use this skill whenever Deniz mentions his vault, projects, Obsidian, his personal knowledge base, or asks anything about his work context (Thalor, Coralate, HAYS, BellaVie, HeroSoftware, Resolvia, PulsePeptides, Bachelor-Thesis, Terminbuchungs-App). Also trigger when Deniz uses trigger words like "tages-start", "log", "eingang verarbeiten", "abgleich", "vault prüfen". Contains vault structure, active projects, knowledge domains, naming conventions, and provenance rules. This skill is the foundation - read it first before any vault operation.
---

# Miraculix Vault-System

Deniz Özbeks Obsidian-Vault ist die Single Source of Truth für alle Projekte, Wissen, Kontakte und Logs. Dieser Skill enthält die Grundstruktur und Regeln.

**Vault-Pfad:** `C:\Users\deniz\Documents\miraculix\`

**Kommunikationsstil mit Deniz:** Deutsch, direkt, kein Smalltalk, kritischer Sparringspartner. Fachbegriffe auf Englisch. Strukturiert, scanbar, keine Prosa-Wände.

---

## Ordnerstruktur

```
00-eingang/           Inbox (Voice-Dumps, Transkripte, Chat-Exports, Dateien)
01-projekte/          Über-Projekte > Sub-Projekte (max 2 Ebenen)
02-wissen/            Cross-Project Transferable Skills
03-kontakte/          Ein File pro Person
04-tagebuch/          Daily Notes (YYYY/MM/YYYY-MM-DD.md)
05-archiv/            Abgeschlossenes
_api/                 Generierte JSONs (read-only)
_anhaenge/            Große Dateien (PDFs, Excel, PPTX) - nicht im Git
_claude/skills/       Master-Version der Skills (ist dort UND im Account-Skill-UI)
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
| Persönlich | `01-projekte/persoenlich/` | persoenlich | aktiv |
| Terminbuchung-App | `01-projekte/terminbuchung-app/` | produkt | pausiert bis nach Thesis |

Tabelle wird manuell gepflegt wenn neue Über-Projekte entstehen. Deniz sagt dann explizit "neues Über-Projekt: X".

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

## Schreibstil für Vault-Content

Wenn Miraculix Content in Vault-Files schreibt (Logs, Projekt-Stände, Wissens-Einträge, Meetings, Frontmatter-Werte): lade den `miraculix-schreibstil` Skill. Der enthält 10 Regeln gegen AI-Slop (keine Gedankenstriche, keine Wichtigkeits-Inflation, keine Rule of Three etc.).

Gilt NICHT für Chat-Antworten an Deniz. Nur für Content der in `.md` Files landet.

## Was NIE tun

- `_api/` manuell editieren (werden generiert)
- `_meta/` oder `CLAUDE.md` ändern ohne Anweisung
- Frontmatter-Schema erfinden das nicht in `_meta/schema.md` steht
- Mehrere Files gleichzeitig ändern ohne vorher Plan zu zeigen
- Informationen zwischen Projekten kopieren - stattdessen Wikilinks
- API-Keys im Klartext
