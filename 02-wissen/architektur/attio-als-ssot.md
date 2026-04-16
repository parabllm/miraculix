---
typ: wissen
name: "Attio als Single Source of Truth für Client-CRMs"
aliase: ["Attio SSOT", "CRM SSOT Pattern"]
domain: ["attio", "architektur", "crm-integration"]
kategorie: entscheidung
vertrauen: bestaetigt
quellen:
  - "[[01-projekte/thalor/_projekt]]"
  - "[[01-projekte/thalor/herosoftware/_projekt]]"
  - "[[01-projekte/thalor/resolvia/_projekt]]"
projekte: ["[[herosoftware]]", "[[resolvia]]", "[[thalor]]"]
zuletzt_verifiziert: 2026-04-16
widerspricht: null
erstellt: 2026-04-16
---

## Prinzip

Über alle Thalor-Client-Projekte hinweg gilt: **Attio ist Single Source of Truth.** Alle anderen Systeme (Billing, Enrichment, Outreach, Support, Sheets) schreiben rein und lesen raus, aber Attio entscheidet.

## Warum

- **Kein CRM-Fork** — Clay, LGM, Mantle, Stripe haben eigene Kunden-Views, aber nur Attio sieht den vollen Kunden
- **Konsistenz für Reporting** — Robin/David können EINE Stelle anschauen und wissen den Status
- **Einfache Troubleshooting-Reihenfolge** — wenn Daten falsch: "Ist es falsch in Attio? Dann upstream fixen. Ist es in Attio richtig aber downstream falsch? Dann downstream-Script fixen."

## Konsequenzen (gelten projektübergreifend)

- **LGM-Events (Replies, Clicks, Conversions)** schreiben zurück nach Attio als Notes/Tasks
- **Clay nur für "Outbound Ready" Leads** — kein Mass-Enrichment in Attio, Token-Budget knapp
- **Attio-Liste = LGM-Sequence** — Kunden-Sortierung nach Attio-Listen triggert automatische LGM-Routing
- **Backfill via CSV-Import**, nicht Workflow (performanter, debugbarer, reversibel)
- **Lokale Node-Scripts für Bulk-Operationen** wenn n8n wegen Timeout nicht geeignet ist

## Wo angewendet

- [[herosoftware]] — Mantle/Clay/LGM schreiben in Attio, Attio = SSOT für Robin
- [[resolvia]] — Stripe schreibt in Attio, Attio = SSOT für David (MRR, Zahlungsstatus, Plan, Churn)
- [[thalor]] — Prinzip auf Umbrella-Ebene festgelegt

## Nicht-Anwendung

- [[pulsepeptides]] — Kalanis SSOT ist Google Sheet (17 Spalten). Attio ist dort nicht im Stack. Kleineres System, anderes Pattern.
