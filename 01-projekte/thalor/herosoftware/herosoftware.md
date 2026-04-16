---
typ: sub-projekt
name: "HeroSoftware"
aliase: ["HeroSoftware", "Hero", "Hero Software", "HS"]
ueber_projekt: "[[thalor]]"
bereich: client_work
umfang: offen
status: aktiv
kapazitaets_last: hoch
kontakte: ["[[robin-kronshagen]]"]
tech_stack: ["n8n", "attio", "clay", "lgm", "mantle", "hetzner", "node"]
notion_url: ""
erstellt: 2026-04-16
notizen: "Größter aktiver Thalor-Client. Mantle→Attio→Clay→LGM Pipeline. 1 n8n Cloud Workflow (WF1) + 4 Hetzner-Scripts."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

Client-Projekt von Robin Kronshagen (Founder HeroSoftware GmbH). Vollständiges CRM- und Outreach-Automation-System für drei Shopify-Apps: **AddressHero, DiscountHero, PaymentHero**.

**Pipeline:** Mantle (Shopify-Billing) → Attio (CRM/SSOT) → Clay (Enrichment Outbound-Ready) → La Growth Machine (Multi-Channel-Outreach: Email + LinkedIn + Call).

**Architektur gelocked** (siehe [[thalor]] für projektübergreifende Prinzipien):
- Attio = SSOT, alle Systeme schreiben rein/lesen raus
- Clay nur "Outbound Ready" Leads
- Batch-Jobs als Hetzner-Scripts (kein 60s-Timeout)
- n8n Cloud nur für Echtzeit-Webhooks (WF1)
- Attio-Liste = LGM-Sequence (Robin sortiert manuell in Listen, Scripts routen)
- Duplikat-Schutz: `sequence_status` ≠ "Not Started"/"Not Activated" → nie doppelt pushen
- Domain als Matching-Key (`.myshopify.com` ausgeschlossen)

**Technische Identifier:**
- n8n Cloud: `herosoftware.app.n8n.cloud`
- Hetzner-Server: Ubuntu 24.04 Helsinki, self-hosted n8n auf `n8n.thalor.de`, Scripts unter `/opt/hero/`
- Attio-Workspace-Members: Calvin Blick `5a60de25-...`, Robin `e9930d23-005e-4318-b26c-c49487b39b51`
- Mantle App-IDs: AddressHero `8321775d-...`, DiscountHero `c8cd397c-...`, PaymentHero `e65dd559-...`

## Aktueller Stand

Stand 2026-04-13 (letzter Log): **Production-Ready Refactor abgeschlossen** — alle 4 Scripts gebaut, daily-sync + LGM-Auth-Checks validiert. Repo auf GitHub privat gesichert. Phase 2 komplett validiert.

**Komponenten live:**
- **WF1 (n8n Cloud, 17 Nodes)** — Mantle→Attio Echtzeit-Webhook, Activity Notes in Node 17 integriert
- **`daily-sync.mjs`** — täglich 06:00, MRR/Plans-Update aller Attio-Companies
- **`lgm-push.mjs`** — Dienstag 07:00, pusht aus 4 Attio-Listen in 8 LGM-Audiences (DE+EN)
- **`lgm-status-sync.mjs`** — täglich 12:00, LGM-Status zurück nach Attio
- **`wf1-backup.mjs`** — jeden zweiten Sonntag 01:00, WF1-Logik gegen alle Mantle-Customers (Disaster Recovery + Backfill)
- **Clay:** 2 Templates live (Executive Leadership + Churns), pro Attio-Liste eigenes Template

**Scripts laufen aktuell noch lokal bei Deniz**, nicht auf dem Hetzner-Server — Cron-Setup ist offene Task.

## Offene Aufgaben

- [ ] Cron auf Hetzner für die 4 Scripts einrichten (TK-4, High) #hoch
- [ ] Prozess-Doku endkundenfertig für Robin/Calvin (Loom + schriftlich) (TK-6, Low — ans Ende) #niedrig
- [ ] Abrechnung Hero+Maddox — Projekte beenden und abrechnen (TK-7, High, 2026-04-14) #hoch

## Abgeschlossene Meilensteine

- ~~Neue API-Keys getauscht (Mantle, Attio, LGM, Clay) in allen Env + n8n WF1~~ 2026-04-13 (TK-3)
- ~~WF Error Slack — Error-Notification + Reply-Push~~ (TK-5)
- ~~Production-Ready Refactor alle 4 Scripts~~ 2026-04-13
- ~~Phase 2 validiert, Repo privat gesichert~~ 2026-04-13

## Out of Scope

- WF5 Billing Sync (verworfen)
- WF6 (Activity Notes in WF1 Node 17 erledigen das)
- n8n WF2/WF3 (Backup, nicht produktiv)
- `lgm-phone-update.mjs` (einmaliges Backfill, nicht mehr relevant)

## Kontakte

- [[robin-kronshagen]] — Founder, Entscheider
- Calvin Blick — Co-Worker im Attio-Workspace (nicht als eigener Kontakt angelegt)
