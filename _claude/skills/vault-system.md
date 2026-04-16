# Vault-System Skill

Bei jeder Interaktion geladen. Enthält Struktur, Entities, Grundregeln.

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
_anhaenge/            Große Dateien (PDFs, Excel, PPTX)
_claude/skills/       Operations-Skills
_meta/                Schema + Glossar + Endpoints
_migration/           Migrations-Artefakte
```

---

## Aktive Über-Projekte

| Über-Projekt | Pfad | Bereich | Status |
|---|---|---|---|
| Thalor | `01-projekte/thalor/` | client_work | aktiv (4 Sub-Projekte: herosoftware, bellavie, pulsepeptides, resolvia) |
| Coralate | `01-projekte/coralate/` | produkt | aktiv (Sub: food-scanner) |
| HAYS | `01-projekte/hays/` | intern | aktiv |
| Bachelor-Thesis | `01-projekte/bachelor-thesis/` | studium | aktiv (Abgabe 2026-06-15 — KRITISCH) |
| Miraculix | `01-projekte/miraculix/` | intern | aktiv (dieser Vault + KI-Orga) |
| Persönlich | `01-projekte/persoenlich/` | persoenlich | aktiv |
| Terminbuchung-App | `01-projekte/terminbuchung-app/` | produkt | pausiert (bis nach Thesis) |

Tabelle wird manuell gepflegt wenn neue Über-Projekte entstehen.

### Wichtige Konvention
Projekt-Haupt-Files heißen `{slug}.md` (nicht `_projekt.md`), damit Obsidian-Wikilinks funktionieren.
Beispiel: `01-projekte/thalor/thalor.md`, `01-projekte/thalor/herosoftware/herosoftware.md`

---

## Wissens-Domains

| Domain | Pfad | Typische Inhalte |
|---|---|---|
| Architektur | `02-wissen/architektur/` | System-Design, SSOT-Patterns |
| Claude Prompting | `02-wissen/claude-prompting/` | Skill-Design, Vault-Patterns |
| Claude Workflow | `02-wissen/claude-workflow/` | Continuity-Docs, Chat-Handover |
| CRM-Integration | `02-wissen/crm-integration/` | Attio, Match-Kaskaden |
| Design | `02-wissen/design/` | UI-Patterns, Branding |
| Integration | `02-wissen/integration/` | Slack-Patterns, Timeout-Handling |
| Marketing | `02-wissen/marketing/` | SEO, Outreach |
| n8n | `02-wissen/n8n/` | Webhook-Patterns, Race-Conditions |
| Power Automate | `02-wissen/power-automate/` | HAYS Flows, SharePoint |
| React Native | `02-wissen/react-native/` | Expo, Zustand, Navigation |
| Supabase | `02-wissen/supabase/` | Edge Functions, RLS |

Neue Domains einfach als Ordner anlegen. Kein Gate.

---

## Standard-Workflow bei Projekt-Arbeit

1. **Vor dem Arbeiten:** Lies `_projekt.md` des relevanten Projekts. Prüfe letzte Logs. Prüfe offene Aufgaben.
2. **Während der Arbeit:** Dokumentiere live. Wenn transferables Pattern entsteht → nach `02-wissen/` destillieren.
3. **Nach der Arbeit:** Bei "log" oder "fortschritt speichern" → Session-Log schreiben, Task-Status updaten.

---

## Wissen zuerst prüfen

**Bevor du ein technisches Problem löst**, prüfe:
1. Gibt es in `02-wissen/{domain}/` eine Lösung?
2. Gibt es in Logs ähnliche Probleme?

Wenn ja → referenziere. Wenn nein → löse, dann destilliere.

---

## Entity-Matching bei Inputs

Wenn Deniz Namen / Projekte / Themen erwähnt, matche gegen:
- `03-kontakte/*.md` → Frontmatter `aliase`
- `01-projekte/**/_projekt.md` → Frontmatter `aliase`
- `02-wissen/**/*.md` → Frontmatter `aliase` und `domain`

Bei Unsicherheit: fragen, nicht raten. "Meinst du [[maddox]] oder jemand anderes?"

---

## Skill-Location

Skills in `_claude/skills/` sind Master-Version. Claude Desktop lädt Skills aus Account-Level UI.

**Bei Skill-Änderung:**
1. Im Vault editieren
2. In Claude Desktop → Settings → Skills → neu hochladen
3. Vault-Version und UI-Version müssen identisch sein

`vault-system.md` muss immer geladen sein. Andere nur bei Trigger.
