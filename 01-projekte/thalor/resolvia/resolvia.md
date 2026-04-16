---
typ: sub-projekt
name: "Resolvia AI"
aliase: ["Resolvia", "Resolvia AI"]
ueber_projekt: "[[thalor]]"
bereich: client_work
umfang: geschlossen
status: aktiv
lieferdatum: ""
kapazitaets_last: niedrig
kontakte: ["[[david-schreiner]]"]
tech_stack: ["n8n", "attio", "stripe"]
notion_url: ""
erstellt: 2026-04-16
notizen: "Stripe→Attio Sync. 500€ fix. Pattern-Wiederholung von Hero-WF1 (Mantle→Attio). Blockiert durch David (Domain-in-Stripe-Metadata)."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

**Stripe→Attio CRM Sync** für Resolvia AI. Billing-Events aus Stripe (Checkout, Subscription, Payment) werden nach Attio gespiegelt — gleiches Pattern wie [[herosoftware]] WF1 (Mantle→Attio), adaptiert für Stripe.

- **Auftraggeber:** [[david-schreiner]] — vermittelt von [[robin-kronshagen]]
- **Budget:** 500 € fix, bezahlter Freelance-Auftrag
- **Tech:** n8n, Attio, Stripe
- **Primary Match Key:** Domain (muss David in Stripe-Metadata einbauen)
- **Lock-In:** `stripe_customer_id` auf Attio-Company nach erstem Match

## Aktueller Stand

Stand 2026-04-07 (letzter Log: "Call mit David Schreiner — Stripe→Attio Scope + Domain-Implementierung"): Scope geklärt. **Blockiert durch David** — muss Domain-in-Stripe-Metadata backend-seitig einbauen und API-Zugänge bereitstellen, bevor Implementierung starten kann.

## Offene Aufgaben

- [ ] Warten auf David: Domain in Stripe-Metadata + API-Zugänge #niedrig
- [ ] Sobald freigegeben: n8n-Workflow bauen (Pattern von Hero-WF1 adaptieren) #mittel

## Out of Scope (Phase 1)

- Attio→Stripe (Invoice aus Attio)
- Trial-Management
- Dunning-Automatisierung
- Deal-Won-Trigger

## Kontakte

- [[david-schreiner]] — Entscheider, vermittelt durch [[robin-kronshagen]]
