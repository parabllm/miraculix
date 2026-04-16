# Migrations-Report

**Datum:** 2026-04-16
**Dauer:** ~1 Session
**Auftrag:** [[MIGRATION]] — Notion-Export + Claude-Chats → Obsidian-Vault

---

## Zahlen

| Kategorie | Anzahl |
|---|---:|
| Über-Projekte | 7 |
| Sub-Projekte | 5 |
| Kontakte | 20 |
| Logs (destilliert) | 44 |
| Meetings | 1 |
| Wissens-Einträge (cross-project) | 5 |
| Git-Commits | 11 |

**Quellen:**
- 128 Notion-Files (Markdown + CSV) verarbeitet
- 112 Claude-Conversations gesichtet, ~75 mit destillierbarem Content
- 83 MB Conversations-JSON + 107 KB Projects-JSON als Fallback behalten unter `00-eingang/`

---

## Projekt-Hierarchie

```
01-projekte/
  thalor/                   (Umbrella, client_work)
    herosoftware/           Robin Kronshagen, größter aktiver Client
    bellavie/               Maddox, in Abrechnungs-Phase
    pulsepeptides/          Kalani, PulseBot n8n
    resolvia/               David, blockiert durch Domain-in-Stripe
  coralate/                 (Produkt, Jann+Lars Co-Founder)
    food-scanner/           Nährwert-Pipeline, Production-Ready 2026-04-13
  hays/                     Werkstudent-Job, 7 Power Automate Flows
  bachelor-thesis/          HdWM, KI-Compliance, Abgabe 2026-06-15 (KRITISCH)
  miraculix/                KI-Orga-Persönlichkeit + dieser Vault
  persoenlich/              Health / Supplements / Career / Travel
  terminbuchung-app/        Eigenes SaaS, PAUSIERT bis nach Thesis
```

## Wissens-Einträge (`02-wissen/`)

5 Cross-Project-Patterns destilliert:

- `crm-integration/attio-match-kaskade.md` — Domain → Email → Name → Create (Hero + Resolvia)
- `architektur/attio-als-ssot.md` — Attio als SSOT über alle Thalor-Clients
- `claude-workflow/continuity-doc-pattern.md` — Chat-Handover via Markdown-File (Cora + Food Scanner)
- `n8n/webhook-timeout-hetzner-cron-pattern.md` — Split n8n/Hetzner für Realtime vs. Batch
- `integration/slack-3s-timeout-async-pattern.md` — Sofort-ACK + Worker (Pulse)

## Review-Punkte für Deniz

Siehe `_migration/issues.md` für Details. Kurz:

1. **Schema-Abweichung:** `_projekt.md` wurde zu `{slug}.md` umbenannt (Obsidian-Wikilinks funktionieren sonst nicht). Schema in `_meta/schema.md` ggf. anpassen.
2. **"Metorik Flow"** Chat 2026-03-19 — PulsePeptides-Zuordnung als `angenommen` markiert. Bitte kurz bestätigen.
3. **"Kalender"** Chat 2026-03-24 — Miraculix-Zuordnung als `angenommen` markiert.
4. **37 leere Claude-Chats** (msgs > 0, chars = 0) übersprungen — Image-Only oder Tool-Stubs. Fallback im Source-JSON.
5. **Notion-Docs (~55)** wurden NICHT einzeln migriert. Schlüssel-Infos in `_projekt.md`/Logs absorbiert. Detail-Specs bleiben als Fallback unter `00-eingang/notion/Second Brain/Docs/`.

## Ambiguitäten aktiv

Keine. Alle Entscheidungen wurden getroffen; keine AMBIG-Files in `00-eingang/unverarbeitet/` nötig.

---

## Was fehlt (nächste Sessions)

### Hohe Priorität
- [ ] Schema-Abweichung `_projekt.md` → `{slug}.md` in `_meta/schema.md` korrigieren (oder Gegenlösung etablieren)
- [ ] Obsidian Community-Plugins einrichten: Dataview, Templater, Calendar, obsidian-git
- [ ] Claude-Desktop-Skills aus `_claude/skills/` hochladen (vault-system Always On)
- [ ] Kontaktbasis E-Mail/Telefon befüllen (alle Kontakte haben leere `email:`/`telefon:` Felder — keine Quelldaten vorhanden)

### Mittel
- [ ] Aufgaben-Files (`aufgaben/` pro Projekt) für die 7 Notion-Tasks erstellen, falls gewünscht (aktuell nur als Checkbox-Liste in `_projekt.md`)
- [ ] `_api/` JSON-Generator-Skript aufsetzen (Cron auf Hetzner oder lokales Node-Skript)
- [ ] Phase-F Daily Notes ab heute starten (Template via Templater)

### Niedrig
- [ ] Review: Habe ich irgendein Projekt oder Kontakt übersehen?
- [ ] Telegram-Bot für Unterwegs-Capture (Phase 2-3)
- [ ] Wissens-Destillation erweitern sobald neue Cross-Project-Patterns auftauchen

## Tages-Modus Ready

Nach Migration kann Miraculix im Tages-Modus arbeiten. Trigger:
- `tages-start` → Daily Note + Übersicht
- `eingang verarbeiten` → Inbox-Digest (aktuell leer)
- `abgleich {projekt}` → Projekt-Reconcile nach Input-Welle
- `log` → Session-Erkenntnisse speichern
- `vault prüfen` → wöchentlicher Lint

---

## Empfehlung für erste Session nach Migration

```
tages-start
```

Dann Kapazität setzen und mit aktivem Projekt starten. Kritischster Kontext aktuell: **Thesis-Interviews terminieren** (Abgabe 2026-06-15, 10 Wochen) parallel zu [[food-scanner]] Multi-Layer-Matching-Build.
