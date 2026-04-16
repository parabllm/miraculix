# Migrations-Issues & Review-Punkte

## Schema-Abweichungen (bewusst getroffen)

### 1. Projekt-Datei-Benennung - `_projekt.md` → `{slug}.md`

**Schema sagt** (in `_meta/schema.md`): "Über-Projekt (`_projekt.md` im Über-Projekt-Ordner)".

**Umgesetzt:** `{projekt-slug}.md` (z.B. `thalor/thalor.md`, `thalor/herosoftware/herosoftware.md`).

**Grund:** Obsidian-Wikilinks `[[bellavie]]` resolven per Default über Basename. Mit `_projekt.md` wäre jeder Link ambig (mehrere `_projekt.md`-Files). Mit Slug-Namen funktionieren alle Wikilinks aus Logs, Kontakten und Wissen automatisch.

**Empfehlung:** Schema in `_meta/schema.md` bei Gelegenheit anpassen. Zeile "`_projekt.md` im Über-Projekt-Ordner" → "`{slug}.md` im Projekt-Ordner, wobei `{slug}` = Ordnername".

## Ambige Zuordnungen aus Phase A (zu prüfen)

### 2. "Metorik Flow" (2026-03-19) → Pulse?

Chat "Metorik Flow" wurde Pulse zugeordnet (Metorik ist WooCommerce-Analytics, Pulse nutzt WooCommerce). Zuordnung auf `vertrauen: angenommen` gesetzt.

**Check:** Gehört der Flow wirklich zu Pulse oder war es eine separate Integration?

### 3. "SEO-Outreach für Heiran Dänemark" (2026-03-18)

Erstes Keyword-Match schlug auf BellaVie aus (SEO), später Indiz: Heiran ist Pulse-Lab.

**Status:** Kein Log erstellt - zu wenig klare Evidenz. Fallback via `00-eingang/claude/conversations.json` falls später relevant.

### 4. "Kalender" Chat (2026-03-24, 120k chars)

Auf Miraculix zugeordnet (Kapazitäts-/Event-Tracking). `vertrauen: angenommen`.

**Check:** Ist der Chat wirklich zu Miraculix oder z.B. HAYS-Event-Management?

## Nicht destillierte Inhalte (bewusst als Fallback belassen)

### 5. ~37 Claude-Chats ohne Titel/Content

Chat-Messages > 0 aber Textlänge 0 - vermutlich Image-Only, Tool-Output-Stubs oder abgebrochene Sessions. Nicht destillierbar.

**Quelle bleibt:** `00-eingang/claude/conversations.json`. Bei Bedarf manuell nachziehen.

### 6. Notion-Docs (Architektur-Specs)

Die ~55 Notion-Docs (WF1-Specs, Hetzner-Setup, Cora-AI-Architecture, Food-Scanner-Master-Docs, etc.) wurden **NICHT** einzeln in den Vault migriert. Sie sind:

- Inhaltlich in `_projekt.md` + Logs absorbiert (Key-Infos)
- Als Fallback-Referenz unter `00-eingang/notion/Second Brain/Docs/` verfügbar

**Grund:** Projekt-Files sollen < 80 Zeilen bleiben (MIGRATION.md Regel). Detail-Specs gehören zur Implementierung (Code, nicht Vault).

**Empfehlung:** Bei Bedarf gezielt einzelne Docs nach `01-projekte/{projekt}/referenz/` ziehen. Aktuell: Overkill.

## Kontakte ohne eigene Files (erwähnt, nicht angelegt)

- **Simea** - interne HAYS-Ansprechpartnerin (im HAYS-Projekt erwähnt). Keine Nachname/Details in Quelle.
- **Calvin Blick** - Co-Worker im HeroSoftware Attio-Workspace (Robin-Team). Attio-Member-ID vorhanden, aber nicht als externer Kontakt relevant.
- **Natalia, Andrej** - Maddox' Geschwister (im BellaVie-Kontext erwähnt, nicht als Kontakte relevant).

Falls diese Personen später aktiv werden → eigene Kontakt-Files anlegen.

## Keine echten AMBIG-Files in `00-eingang/unverarbeitet/`

Während der Migration sind keine Entscheidungen so ambig gewesen dass sie hätten als `AMBIG_*.md` geparkt werden müssen. Alle Zuordnungen wurden mit `vertrauen: angenommen` markiert wo unsicher.
