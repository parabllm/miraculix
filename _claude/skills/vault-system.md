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

**Diese Tabelle wird beim Migrations-Abschluss durch Claude Code automatisch befüllt.**

Format:

| Über-Projekt | Pfad | Bereich | Hauptkontakt |
|---|---|---|---|
| ... | ... | ... | ... |

Diese Tabelle wird manuell gepflegt wenn neue Über-Projekte entstehen. Deniz sagt explizit "neues Über-Projekt: X".

---

## Wissens-Domains

| Domain | Pfad | Typische Inhalte |
|---|---|---|
| n8n | `02-wissen/n8n/` | Webhook-Patterns, Code-Nodes, Race-Conditions |
| Supabase | `02-wissen/supabase/` | Edge Functions, RLS, Schema-Patterns |
| React Native | `02-wissen/react-native/` | Expo, Zustand, Navigation |
| Marketing | `02-wissen/marketing/` | SEO, Outreach |
| Power Automate | `02-wissen/power-automate/` | HAYS Flows, SharePoint |
| Claude Prompting | `02-wissen/claude-prompting/` | Skill-Design, Vault-Patterns |
| Design | `02-wissen/design/` | UI-Patterns, Branding |

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
