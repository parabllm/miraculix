# Thalor — Übersicht & Architektur-Prinzipien

Created: 9. April 2026 01:22
Doc ID: DOC-34
Doc Type: Briefing
Gelöscht: No
Last Edited: 9. April 2026 01:22
Lifecycle: Active
Notes: Übergreifender Thalor-Kontext: Brand, rechtlicher Status, Stack, Architektur-Prinzipien, Active Clients, Betriebsausgaben-System. Bewusst minimal angelegt, wächst wenn Thalor konkreter wird.
Project: Thalor Agency (../Projects/Thalor%20Agency%2033c91df49386818ba849e1b8bdbafaa8.md)
Stability: Volatile
Stack: Attio, Supabase, n8n
Verified: No

## Scope

Übergreifender Kontext zu Thalor — Deniz' Freelance-Agency-Brand. Alle strukturellen, rechtlichen und operativen Infos die über einzelne Client-Projekte hinausgehen. Client-spezifische Details (HeroSoftware, Resolvia, PulsePeptides, BellaVie) leben in den jeweiligen Projekt-Seiten, nicht hier.

## Architecture / Constitution

### Brand & Identity

- **Name:** Thalor
- **Domain:** gesichert
- **Positionierung:** AI Automation Agency — Fokus auf Workflow Automation, CRM-Integration, Billing-Workflows, Custom Tools
- **Inhaber:** Deniz Özbek (alleiniger Freiberufler)

### Rechtlicher Status

- **Rechtsform:** Freiberufler (Einzelperson)
- **Steuerregelung:** Kleinunternehmer nach §19 UStG (keine Umsatzsteuer ausweisen)
- **ELSTER-Anmeldung:** offen — muss als Freiberufler registriert werden
- **Steuer-Tracking:** Betriebsausgaben werden unter diesem Projekt dokumentiert (eigener Tracker)

### Website & Infrastruktur

- **Website Repo:** `paralm/thalor-website`
- **Hosting:** Hetzner VPS
- **Deployment Status:** deployed
- **Andere Infrastruktur:** n8n self-hosted auf Hetzner (für CRM Automation, insb. HeroSoftware)

## Stack & Tooling

### Automatisierung

- **n8n** — zwei Umgebungen: Hetzner self-hosted (prod-kritisch) und n8n Cloud (kleinere Projekte)
- **Power Automate** — nur für HAYS-Kontext (nicht Thalor-Client-Work)

### CRM & Sales

- **Attio** — Single Source of Truth für alle Client-CRMs
- **Clay** — Waterfall Enrichment nur für "Outbound Ready" Leads (Token-bewusst)
- **La Growth Machine (LGM)** — Outbound Sequences, Events werden zurück in Attio geschrieben

### Billing & Payments

- **Stripe** — Subscription-Kunden (z.B. Resolvia)
- **Mantle** — Shopify-Apps Billing (z.B. HeroSoftware)

### Backend & Tools

- **Supabase** — Auth, Postgres, Storage, Edge Functions
- **Python** — Scripts, OCR-Pipelines, Data-Transforms (z.B. PulsePeptides Janoshik)
- **Node.js** — lokale Bulk-Scripts wenn n8n wegen Timeout nicht geeignet ist
- **Desktop Commander / Filesystem MCP** — lokale Dev-Umgebung

### Web & Design

- **Framer** — Client-Websites (z.B. BellaVie)
- **Figma** — UI/UX

## Architektur-Prinzipien (über alle Client-Projekte)

Diese Prinzipien gelten projektübergreifend und sind die Grundlage für jede neue Client-Architektur:

1. **Attio ist immer Single Source of Truth.** Andere Tools (Clay, LGM, Stripe, Mantle) schreiben in Attio rein, lesen aus Attio raus, aber Attio entscheidet.
2. **Clay wird sparsam eingesetzt.** Nur für gezielte Enrichment von "Outbound Ready" Leads, nicht als breites Batch-Tool. Token-Budget ist knapp.
3. **LGM Events (Replies, Clicks, Conversions) schreiben zurück in Attio.** Als Notes oder Tasks auf dem entsprechenden Record.
4. **Backfill via CSV-Import, nicht Workflow.** Für bestehende Kundenbasen ist ein einmaliger CSV-Upload besser als ein kontinuierlicher Sync-Workflow.
5. **Lokale Node.js Scripts für Bulk-Operationen** wenn n8n wegen Timeout nicht geeignet ist. Typischer Fall: > 1000 Records updaten.
6. **Domain als Matching-Key** (nicht Email) in Multi-User-Kontexten — Email kann pro User variieren, Domain ist die Company-Identität.
7. **SEO/GEO-Philosophie:** Direkter Outreach an Blogs, Micro-Influencer, lokale Partner. **Keine Link-Marktplätze** (nur als Backup).

## Active Clients (Kurz-Übersicht)

Details jeweils in den eigenen Notion-Projekten — hier nur der Zweck im Thalor-Kontext:

| Client | Ansprechpartner | Kern-Auftrag | Stack |
| --- | --- | --- | --- |
| **HeroSoftware** | Robin Kronshagen | CRM Automation, LGM Integration, n8n auf Hetzner | n8n, Clay, LGM, Hetzner |
| **Resolvia AI** | David Schreiner | Stripe→Attio Workflow (500€ fix) | n8n, Stripe, Attio |
| **PulsePeptides** | Kalani Ginepri | PulseBot n8n Workflows, Janoshik OCR Pipeline | n8n Cloud, Python |
| **BellaVie** | Maddox Yakymenskyy | Website (Framer), Fresha Setup, SEO-Portale | Framer |

## Betriebsausgaben-System

Alle Ausgaben die unter Thalor laufen werden für die Steuererklärung getrackt:

- Domain-Kosten
- Hetzner VPS (monatlich)
- n8n Cloud Subscription
- Attio Subscription
- Clay Credits
- LGM Subscription
- Sonstige Tool-Subscriptions
- Hardware / Arbeitsmittel (anteilig)

Struktur folgt noch — aktuell als Open Point festgehalten, wird wenn akut gemacht.

## Open Points (nicht ausgearbeitet, nur festgehalten)

- ELSTER-Anmeldung als Freiberufler
- Website-Feinschliff
- Betriebsausgaben-Tracker strukturieren (Sheet oder Notion-DB)
- Rechnungsvorlage standardisieren
- Ggf. separates Geschäftskonto

---

*Dieses Doc ist bewusst minimal gehalten. Es wächst mit wenn Thalor konkreter wird.*