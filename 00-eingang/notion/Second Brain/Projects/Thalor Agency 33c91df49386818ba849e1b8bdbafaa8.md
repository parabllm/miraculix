# Thalor Agency

Agent Instructions: Thalor = Deniz' eigene Freelance-Agency-Brand. Keine externe Firma, kein Client. Umbrella über alle Client-Projekte (HeroSoftware, Resolvia, PulsePeptides, BellaVie). Rechtsform: Freiberufler, Kleinunternehmer §19 UStG. ELSTER-Anmeldung offen. Website auf Hetzner (Repo paralm/thalor-website). Core Stack: n8n, Attio, Clay, LGM, Supabase, Stripe, Framer. Attio ist SSOT für alle Client-CRMs. Details zu Architektur-Prinzipien im Project Body. Minimal angelegt — aktuelle Client-Arbeit gehört in die jeweiligen Client-Projekte, nicht hier.
Areas: Client Work
Created: 9. April 2026 01:21
Docs: Thalor — Übersicht & Architektur-Prinzipien (../Docs/Thalor%20%E2%80%94%20%C3%9Cbersicht%20&%20Architektur-Prinzipien%2033c91df493868160865eeafd4279c331.md)
Gelöscht: No
Last Edited: 9. April 2026 01:21
Priority: 🟧 Aktiv
Project ID: PRJ-8
Status: In Progress
Tech Stack: Attio, Clay, Framer, Hetzner, Python, Stripe, Supabase, n8n
Type: Internal

## Scope

Eigene AI Automation Agency von Deniz. Freelance-Brand unter der alle Client-Projekte (HeroSoftware, Resolvia AI, PulsePeptides, BellaVie) laufen. Plus eigene Produkte, Website, Infrastruktur.

## Constitution

- **Brand:** Thalor
- **Domain:** gesichert
- **Website Repo:** `paralm/thalor-website`
- **Hosting:** Hetzner VPS
- **Rechtsform:** Freiberufler, Kleinunternehmerregelung §19 UStG (Anmeldung via ELSTER noch offen)
- **Steuer-Status:** ELSTER-Freiberufler-Anmeldung pending
- **Fokus:** Workflow Automation, CRM-Systeme, API-Integrationen, Billing-Workflows, Custom Tools

## Stack

Core-Toolkit das bei allen Client-Projekten zum Einsatz kommt:

- **Automatisierung:** n8n (Hetzner self-hosted + n8n Cloud)
- **CRM:** Attio (als SSOT), Clay (Enrichment), La Growth Machine (Outreach)
- **Billing:** Stripe, Mantle (Shopify-Kontext)
- **Backend:** Supabase, Python, Node.js (lokale Bulk-Scripts)
- **Web:** Framer (Client-Landingpages), Figma
- **Infrastruktur:** Hetzner VPS, Desktop Commander, MCP-Connectors

## Architektur-Prinzipien (über alle Client-Projekte hinweg)

- Attio ist immer Single Source of Truth
- Clay nur für gezielte Enrichment von "Outbound Ready" Leads (Token-Budget)
- LGM Events (Replies, Clicks, Conversions) schreiben zurück in Attio als Notes/Tasks
- Backfill bestehender Kunden via CSV Import, nicht Workflow
- Lokale Node.js Scripts für Bulk-Operationen wenn n8n wegen Timeout nicht geeignet ist
- SEO/GEO-Philosophie: Direkter Outreach, keine Link-Marktplätze

## Active Clients

Alle Client-Projekte sind eigene Projects in Notion:

- **HeroSoftware** — Robin Kronshagen, CRM Automation, größter aktiver Client
- **Resolvia AI** — David Schreiner, Stripe→Attio Workflow (500€)
- **PulsePeptides** — Kalani Ginepri, PulseBot n8n Workflows + Janoshik OCR Pipeline
- **BellaVie** — Maddox Yakymenskyy, Website (Framer) + Fresha Setup + SEO-Portale

## Betriebsausgaben

Eigenes System für Steuer-Tracking unter diesem Projekt (als Sub-Doc oder dedizierte Seite). Alle Ausgaben die unter Thalor laufen werden dort dokumentiert für die Steuererklärung.

## Open (nicht weiter ausgearbeitet, nur festgehalten)

- ELSTER-Anmeldung als Freiberufler
- Website-Feinschliff
- Betriebsausgaben-Tracker strukturieren

---

*Dieses Projekt ist absichtlich minimal angelegt. Details kommen dazu wenn sie konkret werden.*