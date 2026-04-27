---

## typ: sub-projekt name: "HeroSoftware" aliase: \["HeroSoftware", "Hero", "Hero Software", "HS"\] ueber_projekt: "[[thalor]]" bereich: client_work umfang: offen status: aktiv kapazitaets_last: hoch kontakte: \[[robin-kronshagen]]", "[[calvin-blick]]", "[[martin-herd]]"\] tech_stack: \["n8n", "attio", "clay", "lgm", "mantle", "digitalocean", "node"\] notion_url: "" erstellt: 2026-04-16 notizen: |- Größter aktiver Thalor-Client. Mantle→Attio→Clay→LGM Pipeline. 1 n8n Cloud Workflow (WF1) + 4 Node-Scripts. Infrastructure migriert vom Thalor-Hetzner auf eigenes DigitalOcean-Droplet in Blick Solutions' DO-Space (Entscheidung Martin-Call 2026-04-21). quelle: notion_migration vertrauen: extrahiert

## Kontext

Client-Projekt von Robin Kronshagen (Founder HeroSoftware GmbH). Vollständiges CRM- und Outreach-Automation-System für drei Shopify-Apps: **AddressHero, DiscountHero, PaymentHero**.

**Pipeline:** Mantle (Shopify-Billing) → Attio (CRM/SSOT) → Clay (Enrichment Outbound-Ready) → La Growth Machine (Multi-Channel-Outreach: Email + LinkedIn + Call).

**Architektur gelocked** (siehe [[thalor]] für projektübergreifende Prinzipien):

- Attio = SSOT, alle Systeme schreiben rein/lesen raus
- Clay nur "Outbound Ready" Leads
- Batch-Jobs als Node.js-Scripts auf Linux-Server (kein n8n 60s-Timeout)
- n8n Cloud nur für Echtzeit-Webhooks (WF1)
- Attio-Liste = LGM-Sequence (Robin sortiert manuell in Listen, Scripts routen)
- Duplikat-Schutz: `sequence_status` ≠ "Not Started"/"Not Activated" → nie doppelt pushen
- Domain als Matching-Key (`.myshopify.com` ausgeschlossen)

**Technische Identifier:**

- n8n Cloud: `herosoftware.app.n8n.cloud`
- **Aktuelle Infrastructure (Migration 2026-04-21):** DigitalOcean-Droplet `68.183.222.21` (Hostname `hero-software-sync-automation`), Ubuntu 24.04, Scripts-Pfad `/opt/crm-sync/`. Details siehe [[digitalocean-droplet]]
- **Alte Infrastructure (wird abgeschaltet):** Thalor-Hetzner `204.168.188.228`, `/opt/crm-sync/` (alte Script-Version mit hardcoded Keys)
- Attio-Workspace-Members: Calvin Blick `5a60de25-f010-4f60-81bf-8e0a03930db1`, Robin Kronshagen `e9930d23-005e-4318-b26c-c49487b39b51`
- Mantle App-IDs: AddressHero `8321775d-...`, DiscountHero `c8cd397c-...`, PaymentHero `e65dd559-...`
- GitHub-Repo: `HeroSoftware-GmbH/hero-software-sync` (PRIVATE, Owner HeroSoftware-GmbH-Org, Martin Herd hat angelegt)

## Aktueller Stand

Stand 2026-04-21 nach Martin-Call ([[2026-04-21-martin-call]]): **Infrastructure-Migration entschieden.** Eigenes DigitalOcean-Droplet statt Thalor-Hetzner. Droplet ist aufgesetzt, SSH-Zugang steht, Deployment steht an.

**Komponenten live:**

- **WF1 (n8n Cloud, 17 Nodes)** Mantle→Attio Echtzeit-Webhook, Activity Notes in Node 17 integriert
- **Clay:** 2 Templates live (Executive Leadership + Churns), pro Attio-Liste eigenes Template
- **Alte Sync-Scripts auf Thalor-Hetzner** `/opt/crm-sync/` laufen weiter bis Cutover (alte Version mit hardcoded API-Keys)

**Scripts im neuen Repo** `HeroSoftware-GmbH/hero-software-sync` **(production-ready):**

- `daily-sync.mjs` täglich 03:00 UTC, Mantle→Attio MRR/Plans-Update
- `lgm-push.mjs` Dienstag 06:00 UTC, Attio-Listen → 8 LGM-Audiences
- `lgm-status-sync.mjs` täglich 12:00 UTC, LGM-Status zurück nach Attio
- `mantle-reconcile.mjs` (ex `wf1-backup`) Sonntag 01:00 UTC, Recovery + Backfill

**Deployment-Status:** Scripts laufen noch lokal bei Deniz. Droplet-Deployment steht als nächster Schritt an. Details Droplet siehe [[digitalocean-droplet]].

## Offene Aufgaben

**Droplet-Setup und Deployment:**

- \[ \] Swap-File 1 GB auf Droplet einrichten vor dem ersten `mantle-reconcile` Lauf #hoch
- \[ \] Zeitzone auf Droplet entscheiden (Berlin setzen oder Cron-Zeiten in UTC umrechnen) #hoch
- \[ \] Scripts nach `/opt/crm-sync/` deployen, `.env` befüllen, `--check` plus `--dry` pro Script #hoch
- \[ \] Crontab einrichten plus Notify-Test #hoch
- \[ \] Optional: dedizierten `crm-sync` System-User anlegen (empfohlen laut [DEPLOYMENT.md](http://DEPLOYMENT.md))
- \[ \] Cutover vom Thalor-Hetzner: alte Crons in `/opt/crm-sync/` auf `204.168.188.228` deaktivieren sobald DO stabil läuft #hoch

**Doku-Lieferung an Martin (aus Call 21.04.):**

- \[ \] Saubere Endkunden-Dokumentation schreiben die das HeroSoft-Team versteht #hoch
- \[ \] Loom-Video aufnehmen: Architektur plus Deployment plus Betrieb #hoch
- \[ \] Testing-Phase begleiten bis Scripts auf dem Droplet stabil laufen #hoch

**Business:**

- \[ \] Abrechnung HeroSoftware (Robin) abschließen (TK-7, seit 2026-04-14) #hoch
- \[ \] Code-Ownership langfristig klären (Deniz Retainer oder andere Lösung, separat mit Robin und Calvin) #mittel
- \[ \] Altes Repo `parabllm/hero-software-sync` archivieren oder löschen (ist jetzt obsolet) #niedrig

## Abgeschlossene Meilensteine

- ~~Neue API-Keys getauscht (Mantle, Attio, LGM, Clay) in allen Env + n8n WF1~~ 2026-04-13 (TK-3)
- ~~WF Error Slack - Error-Notification + Reply-Push~~ (TK-5)
- ~~Production-Ready Refactor alle 4 Scripts~~ 2026-04-13
- ~~Phase 2 validiert, Repo privat gesichert~~ 2026-04-13
- ~~Abrechnung BellaVie/Maddox 400 EUR~~ 2026-04-19
- ~~Martin-Call 2026-04-21: Rollen geklärt, Infrastructure-Entscheidung (eigenes DO-Droplet), neues Repo~~ `HeroSoftware-GmbH/hero-software-sync` ~~übernommen~~ 2026-04-21

## Out of Scope

- WF5 Billing Sync (verworfen)
- WF6 (Activity Notes in WF1 Node 17 erledigen das)
- n8n WF2/WF3 (Backup, nicht produktiv)
- `lgm-phone-update.mjs` (einmaliges Backfill, nicht mehr relevant)

## Kontakte

- [[robin-kronshagen]] - Founder, operativ im Projekt, sortiert Attio-Listen und LGM-Sequences
- [[calvin-blick]] - Robin's Chef bei HeroSoftware, Deniz' übergeordneter Ansprechpartner, eigene Firma Blick Solutions
- [[martin-herd]] - Developer, Hauptjob bei DigitalOcean, nebenher bei Blick Solutions angestellt. Stellt die Infrastructure (DO-Droplet) für die CRM-Sync-Scripts

## Rollen und Abhängigkeiten

- **Entscheider-Hierarchie:** Calvin &gt; Robin. Calvin bestimmt strategisch, Robin führt operativ aus.
- **Developer-Ressource:** Martin Herd kommt über Calvins Firma Blick Solutions, nicht als HeroSoftware-Angestellter. Stellt die DigitalOcean-Infrastructure für die Sync-Scripts, ist NICHT laufender Code-Owner.
- **Deniz' Rolle:** Freelancer, kein Developer. Hat die Pipeline mit Claude als Co-Pilot gebaut. Liefert einmaliges Deployment auf dem neuen Droplet plus saubere Doku und Loom-Video. Laufende Code-Maintenance ist offene Frage zwischen Deniz, Robin und Calvin.
- **Infrastructure-Ownership:** Blick Solutions via DigitalOcean-Space, eigenes Projekt für HeroSoft-Sync.
- **Code-Ownership (Repo):** HeroSoftware GmbH via `HeroSoftware-GmbH/hero-software-sync` Org-Repo. Deniz hat Push-Access als Collaborator.
