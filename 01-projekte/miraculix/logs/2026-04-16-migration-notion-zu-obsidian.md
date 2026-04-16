---
typ: log
projekt: "[[miraculix]]"
datum: 2026-04-16
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["obsidian", "claude-code", "git"]
---

**Obsidian-Migration gestartet.** Zwei Chats heute: "Migration von Notion zu Obsidian als zentrale Wissensbasis" (42 Messages, 462k chars) + "Obsidian Second Brain Setup implementieren" (29 Messages, 204k chars).

## Warum Migration

Notion-Setup aus 2026-04-08 wurde als zu komplex/gefangen empfunden. Obsidian-Vault bietet:

- **SSOT als lokale Markdown-Files** (Git-versionierbar)
- **Wikilinks** statt verschachtelter Notion-Relationen
- **Plain-Text-Portabilität** (kein API-Lock-in)
- **Claude-Code als Live-Editor** für alle Files
- **Schneller Scannbar** in Obsidian UI

## Architektur-Entscheidungen

- **Vault-Struktur:** `00-eingang/`, `01-projekte/`, `02-wissen/`, `03-kontakte/`, `04-tagebuch/`, `05-archiv/`, `_api/`, `_anhaenge/`, `_claude/skills/`, `_meta/`, `_migration/`
- **Frontmatter-Schema** in `_meta/schema.md`
- **Operations-Skills** in `_claude/skills/` (tages-start, eingang-verarbeiten, abgleich, vault-pruefung, wissens-destillation)
- **`_api/` JSONs** generiert (read-only für n8n/MCP/Telegram-Bot)
- **Capture-Architektur:** Desktop direkt in Files, Unterwegs nur in `00-eingang/unverarbeitet/`

## Framework-Artefakte erstellt

- `CLAUDE.md` (Boot-Instruction)
- `MIGRATION.md` (dieser Auftrag)
- `START-HERE.md` (Setup-Anleitung)
- `_meta/schema.md`, `_meta/glossar.md`, `_meta/endpunkte.md`
- Schemata in `_meta/schema.md` für alle Entitäten

## Migrations-Run

Heute läuft der Migrations-Run durch Claude Code:
- Phase A: Inventur (128 Notion-Files, 112 Claude-Chats)
- Phase B: 20 Kontakte
- Phase C: 7 Über-Projekte, 9 Sub-Projekte
- Phase D: Logs + Meetings (läuft)
- Phase E+: Wissen, Quality-Gate, Report

## Quelle

Claude-Chats heute: "Migration von Notion zu Obsidian als zentrale Wissensbasis" + "Obsidian Second Brain Setup implementieren".
