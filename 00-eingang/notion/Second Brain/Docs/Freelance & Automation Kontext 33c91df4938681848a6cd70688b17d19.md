# Freelance & Automation Kontext

Created: 8. April 2026 21:16
Doc ID: DOC-10
Doc Type: Reference
Gelöscht: No
Last Edited: 8. April 2026 23:53
Lifecycle: Active
Notes: Freelance-Identität und Architektur-Prinzipien. Spiegelung in profile-context Skill.
Project: Personal Life (../Projects/Personal%20Life%2033c91df49386812f809ae080da3c4056.md)
Stability: Stable
Verified: No

## Was Deniz macht

Workflow Automation, CRM-Systeme und API-Integrationen für verschiedene Clients. Zusätzlich eigenes Produkt (coralate Fitness-App).

## Core Stack

- **Automation:** n8n (self-hosted auf Hetzner + n8n Cloud)
- **CRM:** Attio (Single Source of Truth)
- **Billing:** Mantle (Shopify)
- **Outbound:** La Growth Machine, Clay (nur für gezielte Enrichment)
- **Image Generation:** Google Gemini
- **Storage:** Supabase
- **Websites:** Framer

## Architektur-Prinzipien

- Attio ist immer Single Source of Truth
- Clay nur für gezielte Enrichment von "Outbound Ready" Leads — kein Mass-Enrichment (Token-Budget)
- LGM Events (Replies, Clicks, Conversions) schreiben zurück in Attio als Notes/Tasks
- Backfill bestehender Kunden via CSV Import, nicht Workflow
- Lokale Node.js Scripts für Bulk-Operationen wenn n8n wegen Timeout nicht geeignet ist

## SEO/GEO-Philosophie

Direkter Outreach: Blogs, Micro-Influencer, lokale Partner direkt kontaktieren. Keine Link-Marktplätze außer als Backup/Referenz.

## Infrastruktur

- **n8n self-hosted:** Hetzner Server (für Hero Software / CRM Automation)
- **n8n Cloud:** Für PulsePeptides und kleinere Projekte
- **MCP Connectors:** Google Calendar, Gmail, Slack, n8n, Supabase, Notion, Desktop Commander, Filesystem
- **Claude Skills:** Account-Ebene, fortlaufend aktualisiert. Skills für: n8n, Attio API, Clay, Mantle API, HAYS Flows, Google Calendar, Backfill Scripts, etc.