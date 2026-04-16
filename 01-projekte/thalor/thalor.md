---
typ: ueber-projekt
name: "Thalor Agency"
aliase: ["Thalor", "Thalor Agency", "Talor Agency"]
bereich: client_work
umfang: offen
status: aktiv
kapazitaets_last: hoch
hauptkontakt: ""
tech_stack: ["n8n", "attio", "clay", "lgm", "stripe", "supabase", "framer", "hetzner", "node"]
erstellt: 2026-04-16
notizen: "Eigene Freelance-Agency-Brand (Freiberufler, §19 UStG). Umbrella über alle Client-Projekte. Attio = SSOT über alle Clients hinweg."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

Thalor ist Deniz' eigene AI-Automation-Agency-Brand. Kein externes Unternehmen, sondern Freiberufler-Identität (Kleinunternehmer §19 UStG). Unter diesem Umbrella laufen alle Client-Aufträge plus Infrastruktur (Website, Hetzner, Tooling).

**Core-Stack** (projektübergreifend): n8n (self-hosted auf Hetzner + n8n Cloud), Attio (CRM/SSOT), Clay (Enrichment, nur Outbound-Ready), La Growth Machine (Outreach), Stripe/Mantle (Billing), Supabase (Backend), Framer (Client-Landingpages), Node.js (Bulk-Scripts).

**Architektur-Prinzipien** (gelten für alle Client-Projekte):
- Attio = Single Source of Truth
- Clay nur für "Outbound Ready" Leads (Token-Budget)
- LGM-Events schreiben zurück nach Attio als Notes/Tasks
- Backfill via CSV-Import, nicht Workflow
- Bulk-Ops via lokale Node-Scripts wenn n8n-Timeout limitiert
- SEO/GEO: Direkter Outreach, keine Link-Marktplätze

## Aktueller Stand

Stand 2026-04-16:
- **Website Repo:** `paralm/thalor-website`, Hosting Hetzner VPS, Domain gesichert
- **Rechtsform:** Freiberufler, Kleinunternehmerregelung §19 UStG
- **ELSTER-Anmeldung:** pending
- Aktive Client-Projekte: 4 (siehe unten)

## Sub-Projekte

- [[herosoftware]] - Robin Kronshagen, CRM-Automation (größter aktiver Client, bezahlt)
- [[bellavie]] - Maddox Yakymenskyy, Website + Fresha + SEO (in Abrechnungs-/Abschluss-Phase)
- [[pulsepeptides]] - Kalani Ginepri, PulseBot n8n + Janoshik OCR (unbezahltes Referenzprojekt)
- [[resolvia]] - David Schreiner, Stripe→Attio Sync (500€, wartet auf Domain-in-Stripe-Metadata von David)

## Offene Aufgaben

- [ ] ELSTER-Anmeldung als Freiberufler #mittel
- [ ] Website-Feinschliff #niedrig
- [ ] Betriebsausgaben-Tracker strukturieren (Steuer) #niedrig

## Kontakte

Alle Client-Entscheider verlinkt auf Sub-Projekt-Ebene. Für Thalor selbst keine externen Kontakte.
