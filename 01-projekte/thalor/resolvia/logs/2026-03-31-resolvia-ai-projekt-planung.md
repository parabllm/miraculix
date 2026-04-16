---
typ: log
projekt: "[[resolvia]]"
datum: 2026-03-31
art: fortschritt
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["attio", "stripe", "n8n"]
---

Resolvia-AI-Projekt-Planung. Chat "Resolvia AI" (29 Messages, 207k chars).

## Scope

Stripe→Attio Sync für Resolvia AI. Pattern adaptiert von [[herosoftware]] WF1 (Mantle→Attio). Match-Kaskade:

1. Primary: **Domain-Match** aus Stripe-Metadata (muss David backend-seitig einbauen)
2. Secondary: Email-Match
3. Lock-In: `stripe_customer_id` auf Attio-Company nach erstem Match

Plus: `sequence_status`-Duplikat-Schutz analog Hero.

## Quelle

Claude-Chat "Resolvia AI" 2026-03-31.
