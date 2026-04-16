---
typ: wissen
name: "n8n Webhook für Echtzeit, Hetzner-Cron für Batch"
aliase: ["n8n Cloud Timeout", "Hetzner Cron Pattern", "Batch-vs-Realtime Split"]
domain: ["n8n", "hetzner", "architektur"]
kategorie: pattern
vertrauen: bestaetigt
quellen:
  - "[[01-projekte/thalor/herosoftware/logs/2026-03-25-hetzner-setup-daily-sync]]"
  - "[[01-projekte/thalor/herosoftware/logs/2026-04-13-production-ready-refactor-4-scripts]]"
  - "[[01-projekte/thalor/herosoftware/_projekt]]"
projekte: ["[[herosoftware]]", "[[thalor]]"]
zuletzt_verifiziert: 2026-04-16
widerspricht: null
erstellt: 2026-04-16
---

## Problem

n8n Cloud hat **60s Execution-Timeout** und begrenztes Execution-Limit pro Plan. Für Batch-Jobs die Tausende Datensätze durchgehen (Backfill, Reconciliation, tägliche Sync-Läufe) ist das ungeeignet.

## Lösung: Split-Architektur

| Job-Typ | Platform | Beispiel |
|---|---|---|
| **Echtzeit-Webhook** | n8n Cloud | WF1 Mantle→Attio (17 Nodes) |
| **Geplanter Batch** | Hetzner-Cron (Node.js) | `daily-sync.mjs` 06:00 |
| **Outbound-Push** | Hetzner-Cron | `lgm-push.mjs` Di 07:00 |
| **Status-Sync** | Hetzner-Cron | `lgm-status-sync.mjs` 12:00 |
| **Disaster Recovery** | Hetzner-Cron | `wf1-backup.mjs` / `mantle-reconcile.mjs` alle 2 Wochen |

## Hetzner-Setup

- **VPS:** Ubuntu 24.04, Helsinki
- **Preis:** ~4.15€/Monat (HeroSoftware)
- **Scripts:** unter `/opt/hero/` (pro Kunde eigener Ordner)
- **Auth:** STRATO-SMTP für Notify-Emails + Slack-Webhooks parallel, Fallback stdout
- **SSL:** Let's Encrypt, Auto-Renewal via certbot
- **n8n self-hosted:** zusätzlich auf `n8n.thalor.de` als Backup für n8n Cloud

## Script-Design-Pattern (aus Hero-Refactor)

- **Single-File Scripts**, bewusst keine Shared Modules — Code-Duplikation mit `// SYNC:`-Kommentaren markiert
- **Standardisierte Flags:** `--help`, `--check`, `--dry` in jedem Script
- **Schreibende Scripts (CREATE-Ops):** Default `--dry`, Live-Lauf nur mit `--execute`
- **`.env` in 3 Kategorien:** Secrets / Operative / Domain-Konstanten (letztere hardcoded im Script)
- **Notify-System:** Email + Slack parallel, beide optional
- **Anti-Spam:** Lock-Files, bei zweitem Crash → "Notify übersprungen"
- **Node 20 LTS minimum** (Server hat aktuell v22/v24)
- **Windows-Assertion-Bug auf Node 22/24:** `await delay(100)` vor `process.exit()` als Workaround

## Wo angewendet

- [[herosoftware]] — 4 Scripts produktiv + `wf1-backup`/`mantle-reconcile` als Disaster Recovery
- [[thalor]] — Website-Hosting auf gleichem Hetzner-Server

## Wann n8n Cloud reicht

Nur bei:
- Single-Record-Webhooks (< 60s Execution)
- Trigger-Response Pattern
- Daten-Volumen pro Call im 2-stelligen Bereich

Sobald **Collections** (Fetch-All, Match-All) involviert sind → Hetzner.
