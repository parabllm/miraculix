---
typ: ueber-projekt
name: "Miraculix"
aliase: ["Miraculix", "Second Brain", "Obsidian Vault"]
bereich: intern
umfang: offen
status: aktiv
kapazitaets_last: mittel
hauptkontakt: ""
tech_stack: ["obsidian", "claude-code", "claude-desktop", "n8n", "mcp", "hetzner", "git"]
erstellt: 2026-04-16
notizen: "Deniz' persönlicher KI-Orga-Layer. Obsidian-Vault als Single Source of Truth für alle Projekte, Wissen, Kontakte, Logs. Ersetzt das alte Notion-Second-Brain."
quelle: claude_migration
vertrauen: extrahiert
---

## Kontext

**Miraculix** ist Deniz' KI-Orga-Persönlichkeit und der Vault der diese Persönlichkeit trägt. Der Vault ist **Single Source of Truth** für Projekte, Wissen, Kontakte, Logs, Tages-Orga. Google Calendar / Google Tasks sind nur operative Ansichten.

**Architektur:**
- Obsidian-Vault lokal auf Windows-Desktop
- Git-versioniert
- Claude Code als Schreib-Layer (direkt in Projekt/Wissens/Kontakt-Files)
- Claude Desktop Skills + MCP-Connectors für Operations (tages-start, eingang-verarbeiten, abgleich, vault-pruefung, wissens-destillation)
- Generierte `_api/` JSONs als Read-Only-Schnittstelle für n8n / MCP / Telegram-Bot (später)

**Capture-Architektur:**
- **Desktop:** Live-Chat schreibt direkt an richtige Stellen im Vault
- **Unterwegs (Phase 2-3):** Telegram/Mobile/Email → ausschließlich `00-eingang/unverarbeitet/` → später Digest

## Aktueller Stand

Stand 2026-04-16: **Migration von Notion-Second-Brain in Obsidian läuft** (dieser aktuelle Prozess). Framework steht, CLAUDE.md + Schema + Skills sind platziert, Git ist initialisiert.

Vorgeschichte (Claude-Chats):
- ~~2026-03-11 "Info Agent und Struktur" — erste Ideen für persönlichen KI-Assistenten~~
- ~~2026-03-28 "Externe Speicherverwaltung für Claude" — Memory-Konzept~~
- ~~2026-03-31 "Miraculix — persönlicher KI-Assistent Setup" — Namensgebung + Konzept~~
- ~~2026-04-08 "Notion-Workflow optimieren und Idealsystem entwickeln" — Systemdesign~~
- ~~2026-04-16 "Migration von Notion zu Obsidian als zentrale Wissensbasis" + "Obsidian Second Brain Setup implementieren" — dieses Migrations-Framework entstanden~~

## Offene Aufgaben

- [ ] Migration abschließen (Phase D-H) #hoch
- [ ] Obsidian Community-Plugins einrichten: Dataview, Templater, Calendar, obsidian-git #mittel
- [ ] Templater-Path setzen: `.obsidian/templates` #mittel
- [ ] Claude-Desktop-Skills aus `_claude/skills/` hochladen (vault-system Always On) #mittel
- [ ] `_api/` JSON-Generator-Skript aufsetzen (Hetzner Cron oder lokales Node-Skript) #niedrig
- [ ] Telegram-Bot für Unterwegs-Capture (Phase 2) #niedrig

## Operations-Skills

Siehe `_claude/skills/`:
- tages-start / was steht an
- eingang verarbeiten / digest
- abgleich / reconcile
- vault prüfen / lint
- log / fortschritt speichern
- wissens-destillation (implizit beim log)

## Out of Scope

- Eigene App oder SaaS — Miraculix ist ein persönlicher Vault, keine Produkt
- Multi-User oder Sharing — Single-User-System

## Kontakte

_Keine._
