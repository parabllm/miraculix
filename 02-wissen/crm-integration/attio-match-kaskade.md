---
typ: wissen
name: "Attio Match-Kaskade (Domain → Email → Name → Create)"
aliase: ["Attio Matching", "Domain Match Cascade", "Match Chain"]
domain: ["attio", "crm-integration"]
kategorie: pattern
vertrauen: bestaetigt
quellen:
  - "[[01-projekte/thalor/herosoftware/logs/2026-03-27-wf1-domain-match-create-fehler-fix]]"
  - "[[01-projekte/thalor/resolvia/logs/2026-03-31-resolvia-ai-projekt-planung]]"
  - "[[01-projekte/thalor/herosoftware/logs/2026-03-26-clay-integration-templates-tier-system]]"
projekte: ["[[herosoftware]]", "[[resolvia]]"]
zuletzt_verifiziert: 2026-04-16
widerspricht: null
erstellt: 2026-04-16
---

## Problem

Bei jedem Billing-Event (Mantle, Stripe, …) muss die passende Company in Attio gefunden (oder erstellt) werden. Naive Implementierungen erzeugen Duplikate (6 Quellen bei HeroSoftware) oder falsche Matches.

## Match-Kaskade (4 Stufen)

1. **Exakter Shopify-URL-Match** (nur bei Shopify-Kontext) - `shopify_url $contains [shopifyDomain]` → direkt Update
2. **Domain-Match** - `domains $contains [match_domain]` → Dup-Check → Update + `shopify_url` setzen
3. **Name-Match** - `name $contains [match_name]` mit Constraints:
   - ≥ 4 Zeichen
   - **genau 1 Treffer** (sonst Fail)
   - Name nicht generisch ("info", "admin", …)
4. **Kein Match** → Create New Company

## Kritische Regeln

- **Duplikat-Check auf jeder Stufe** - verhindert Merging mit falschen Companies
- **`.myshopify.com` Domains ausschließen** (keine echten Custom-Domains, matchen dutzende unrelated Customers)
- **Domain bei PATCH mitschreiben**, aber `domains: []` in PATCH-Payload = **keine Änderung** (Attio-API-Quirk - nicht: Domain löschen)
- **Create-Fallback NIE auf `statusCode` prüfen** - alle 3 Versuche durchlaufen lassen, HTTP-Status ist nicht verlässlich
- **Lock-In nach Match:** `stripe_customer_id` / `mantle_profile_id` in Attio setzen → nachfolgende Events matchen direkt über ID (Stufe 0)
- **Duplikat-Schutz bei LGM:** Person mit `sequence_status` ≠ "Not Started" / "Not Activated" wird NIE doppelt in Sequence gepusht
- **DUPLICATE-Response von LGM:** Attios `lgm_sequence` trotzdem nachtragen (sonst erneuter Push beim nächsten Cron)

## Wo angewendet

- [[herosoftware]] WF1 (Mantle → Attio, 17 Nodes, produktiv seit 2026-03-27)
- [[resolvia]] (Stripe → Attio, geplant - wartet auf Domain-in-Stripe-Metadata)

## Goldene Regel

**1 Billing-Profil = 1 Attio-Company.** Alle Quellen die Companies in Attio anlegen können (Email-Sync, manuelle Einträge, Workflows) müssen vorher Duplikat-Check durchführen. Aufräumen > Matching bauen.
