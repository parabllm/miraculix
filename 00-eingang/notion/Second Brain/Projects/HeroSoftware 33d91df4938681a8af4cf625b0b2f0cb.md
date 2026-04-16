# HeroSoftware

Agent Instructions: HeroSoftware = größter aktiver Thalor-Client von Robin Kronshagen. Pipeline: Mantle (Shopify Billing) → Attio (CRM SSOT) → Clay (Enrichment) → La Growth Machine (Outreach). 1 n8n Workflow (WF1 Webhook in n8n Cloud) + 4 Hetzner Skripte (daily-sync 6h, lgm-push Di 7h, lgm-status-sync 12h, wf1-backup jeden 2. So 1h). Detail-Docs pro Komponente sind separate Docs unter diesem Projekt. Architektur ist gelocked: Attio=SSOT, Clay nur für Outbound-Ready, Batch-Jobs als Hetzner Scripts. WF5 Billing Sync ist VERWORFEN. Activity Notes sind in WF1 Node 17 integriert (kein WF6). Aktueller Status gehört in Logs DB — nicht in den Project Body.
Areas: Client Work
Contacts: Robin Kronshagen (../Contacts/Robin%20Kronshagen%2033d91df49386819ca534ea7fd5570bc1.md)
Created: 9. April 2026 11:26
Docs: WF1 — Mantle → Attio (n8n Cloud Webhook) (../Docs/WF1%20%E2%80%94%20Mantle%20%E2%86%92%20Attio%20(n8n%20Cloud%20Webhook)%2033d91df4938681909b83f52013e0ad0c.md), Skript: daily-sync.mjs (../Docs/Skript%20daily-sync%20mjs%2033d91df4938681fe9e4ace1c03860d9e.md), Skript: lgm-push.mjs (Attio → LGM) (../Docs/Skript%20lgm-push%20mjs%20(Attio%20%E2%86%92%20LGM)%2033d91df4938681fbb26bc412f78dfcbf.md), Skript: lgm-status-sync.mjs (LGM → Attio) (../Docs/Skript%20lgm-status-sync%20mjs%20(LGM%20%E2%86%92%20Attio)%2033d91df4938681bc94b7dcbb1055f4ea.md), Skript: wf1-backup.mjs (WF1 Recovery + Backfill) (../Docs/Skript%20wf1-backup%20mjs%20(WF1%20Recovery%20+%20Backfill)%2033d91df4938681e6835ef4bd6f78443e.md), Clay Integration (Templates, Tables, Tier System) (../Docs/Clay%20Integration%20(Templates,%20Tables,%20Tier%20System)%2033d91df49386812aa865f5f3caeaabef.md), LGM Integration (Audiences, IDs, Mapping) (../Docs/LGM%20Integration%20(Audiences,%20IDs,%20Mapping)%2033d91df49386816c9839cf2126735662.md), Hetzner Server Setup (HeroSoftware) (../Docs/Hetzner%20Server%20Setup%20(HeroSoftware)%2033d91df493868141b5b3ddf1af6c7306.md), n8n Debug & Fix Tracker (../Docs/n8n%20Debug%20&%20Fix%20Tracker%2033d91df4938681fd854ec8c693d06528.md)
Gelöscht: No
Last Edited: 9. April 2026 11:26
Last Log Date: 13. Apr. 2026
Last Log Title: Production-Ready Refactor — alle 4 Scripts gebaut, daily-sync + LGM Auth-Checks validiert,Phase 2 komplett validiert, Repo auf GitHub privat gesichert
Logs: Production-Ready Refactor — alle 4 Scripts gebaut, daily-sync + LGM Auth-Checks validiert (../Logs/Production-Ready%20Refactor%20%E2%80%94%20alle%204%20Scripts%20gebaut,%2034191df4938681da9e32db745b023951.md), Phase 2 komplett validiert, Repo auf GitHub privat gesichert (../Logs/Phase%202%20komplett%20validiert,%20Repo%20auf%20GitHub%20privat%2034291df493868126a998ee63e63c163a.md)
Priority: 🟧 Aktiv
Project ID: PRJ-10
Status: In Progress
Tasks: Neue API Keys erstellen + an alle Positionen einsetzen (Skripte + n8n Workflows + .env) (../Tasks/Neue%20API%20Keys%20erstellen%20+%20an%20alle%20Positionen%20einse%2033d91df49386818abb98e478fd56f02b.md), Cron auf Hetzner Server für HeroSoftware-Skripte einrichten (../Tasks/Cron%20auf%20Hetzner%20Server%20f%C3%BCr%20HeroSoftware-Skripte%20e%2033d91df493868189b95fd0f72d504452.md), WF Error Slack — Error-Notification + Reply-Push nach Slack bauen (../Tasks/WF%20Error%20Slack%20%E2%80%94%20Error-Notification%20+%20Reply-Push%20n%2033d91df4938681f98f41fc45db1c9765.md), Prozessdokumentation HeroSoftware (komplett endkundenfertig für Robin) (../Tasks/Prozessdokumentation%20HeroSoftware%20(komplett%20endkun%2033d91df4938681aab3cbe99e8cd34830.md), Abrechnung Hero+Maddox (../Tasks/Abrechnung%20Hero+Maddox%2034291df49386801ab98bfedb9c10f49e.md)
Tech Stack: Attio, Clay, Hetzner, LGM, Python, n8n
Type: Client

## Scope

Client-Projekt von Robin Kronshagen (Founder HeroSoftware GmbH). Vollständiges CRM- und Outreach-Automation-System für drei Shopify-Apps (AddressHero, DiscountHero, PaymentHero). Pipeline: **Mantle (Billing) → Attio (CRM) → Clay (Enrichment) → La Growth Machine (Outreach)**.

Größter aktiver Client unter Thalor.

## Constitution

- **Auftraggeber:** Robin Kronshagen, Founder HeroSoftware GmbH
- **Typ:** Bezahlter Freelance-Auftrag
- **n8n Cloud:** `herosoftware.app.n8n.cloud`
- **Hetzner Server:** Ubuntu 24.04 in Helsinki, hostet self-hosted n8n auf `n8n.thalor.de` plus die lokalen Sync-Skripte unter `/opt/hero/`
- **Apps & App-IDs (Mantle):**
    - AddressHero: `8321775d-0f05-4239-a7f1-3e99dafb33b1`
    - DiscountHero: `c8cd397c-3945-4c7f-9b61-a72f050cf21e`
    - PaymentHero: `e65dd559-c053-47ad-a1c4-5a9046da1693`
- **Workspace Members (Attio):**
    - Calvin Blick: `5a60de25-f010-4f60-81bf-8e0a03930db1`
    - Robin Kronshagen: `e9930d23-005e-4318-b26c-c49487b39b51`

## Architektur-Entscheidungen (gelocked, projektübergreifend)

- **Attio = Single Source of Truth.** Alle anderen Systeme schreiben rein, lesen raus, aber Attio entscheidet.
- **Clay nur für "Outbound Ready" Leads.** Kein Mass-Enrichment — Token-Budget ist knapp.
- **Batch-Jobs als Hetzner Scripts**, nicht als n8n Cloud Workflows. Grund: kein 60s Timeout, kein Execution-Limit, volle Kontrolle.
- **n8n Cloud nur für Echtzeit-Webhooks** (= WF1 Mantle→Attio).
- **Attio-Liste = LGM Sequence.** Robin sortiert manuell in Listen, Skripte routen automatisch in die richtigen LGM Audiences.
- **Duplikat-Schutz:** Person mit `sequence_status` ≠ "Not Started"/"Not Activated" wird nie doppelt in eine Sequence gepusht.
- **Domain als Matching-Key.** `.myshopify.com` Domains sind keine echten Custom-Domains und werden vom Match ausgenommen.
- **Backfill via Skripte**, nicht via Workflow — sowohl der initiale Mantle→Attio Backfill als auch der Recurring `wf1-backup.mjs` Lauf.

## Tech Stack

- **Mantle** — Shopify Billing SaaS (Webhook-Quelle, REST API für Customer Fetch)
- **Attio** — CRM (SSOT)
- **Clay** — Enrichment Layer (Apollo, BetterContact, Claygent)
- **La Growth Machine (LGM)** — Multi-Channel Outreach (Email + LinkedIn + Call)
- **n8n** — Cloud (`herosoftware.app.n8n.cloud`) für WF1 Webhook + self-hosted (`n8n.thalor.de`) als Backup
- **Hetzner VPS** — Helsinki, Ubuntu 24.04, hostet n8n + Skripte
- **Node.js** — alle Sync-Skripte unter `/opt/hero/`

## Komponenten-Übersicht

**n8n Workflow (Echtzeit):**

- **WF1 — Mantle → Attio** (LIVE, 17 Nodes, Activity Notes integriert)

**Hetzner Skripte (`/opt/hero/`):**

- **`daily-sync.mjs`** — täglich 6:00 Uhr, aktualisiert MRR/Plans aller bestehenden Companies
- **`lgm-push.mjs`** — Dienstag 7:00 Uhr, pusht enrichte Leads aus 4 Attio-Listen in 8 LGM Audiences (DE+EN)
- **`lgm-status-sync.mjs`** — täglich 12:00 Uhr, holt LGM Status über alle Audiences und synct nach Attio
- **`wf1-backup.mjs`** — jeden zweiten Sonntag 1:00 Uhr, repliziert WF1-Logik gegen alle Mantle Customers (Disaster Recovery + Backfill-Werkzeug)

**Clay Tables:**

- 2 Templates live (Executive Leadership / Churns)
- Pro Attio-Liste eigenes Template (gleiche Struktur, andere Source)

## Out of Scope

- **WF5 Billing Sync** — verworfen, wird nicht gebaut
- **WF6** — nicht nötig, Activity Notes sind direkt in WF1 (Node 17) integriert
- **n8n WF2 / WF3** — existieren noch in n8n Cloud als Backup, sind aber nicht produktiv. Produktiv laufen die Hetzner Skripte.
- **lgm-phone-update.mjs** — war nur einmaliges Backfill-Skript, nicht mehr relevant

## Wichtige Skills (Companions)

- `n8n-workflows` — n8n Patterns + Debug
- `attio-api` — Attio API Referenz
- `clay-workflows` — Clay Templates + Claygent
- `mantle-api` — Mantle Customer-Daten + Webhook Events
- `hetzner-server` — Server-Ops + Skript-Deployment
- `backfill-scripts` — lokale Bulk-Sync-Patterns

---

*Detaillierter Stand pro Komponente: siehe die jeweiligen Docs unter diesem Projekt.*