---
typ: log
projekt: "[[herosoftware]]"
datum: 2026-03-20
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["attio", "mantle", "n8n", "lgm", "clay"]
---

Projekt-Kickoff HeroSoftware. Claude-Chat "Session 0 Hero" (1.26M Zeichen). API-Zugänge für Mantle, Attio, LGM, Clay sind da. n8n Cloud-Login vorhanden. Attio Custom Fields größtenteils angelegt. Screenshots von Dashboards verfügbar.

## Kickoff-Umfang

- CRM-Automation Projekt starten
- 3 Wissens-Dateien gelesen: `01_prd.md`, `02_plan.md`, `03_offen.md`
- Pipeline definiert: Mantle (Billing) → n8n → Attio (CRM) → Clay (Enrichment) → LGM (Outreach)
- 3 Shopify-Apps (AddressHero, DiscountHero, PaymentHero), 10.000+ Kunden

## Output

- Initialer WF1-Entwurf (Mantle→Attio Webhook)
- Matching-Kette definiert: Shopify-URL → Domain → Name → Create

## Quelle

Claude-Chat UUID: siehe `00-eingang/claude/conversations.json`, Titel "Session 0 Hero", 492 Messages
