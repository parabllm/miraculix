---
typ: log
projekt: "[[herosoftware]]"
datum: 2026-04-13
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["attio", "mantle", "n8n", "hetzner", "lgm", "github"]
---

**Handover-Vorbereitung für HeroSoft-Backend-Team.** Chat "HeroSoftware Übergabe" (233 Messages, 876k chars). Vorstufe zum Production-Ready-Refactor (siehe [[2026-04-13-production-ready-refactor-4-scripts]]).

## Architektur in Kurzform (für Übergabe dokumentiert)

```
Mantle (Shopify Billing)
├── Webhooks → n8n WF1 → Attio (Echtzeit-Sync, 24 Nodes)
└── API → daily-sync.mjs → Attio (Nachtsync, Cron auf Hetzner)

Attio (Single Source of Truth)
├── lgm-push.mjs → LGM (Outbound, Dienstag)
└── lgm-status-sync.mjs → LGM-Status zurück (täglich 12:00)

+ mantle-reconcile.mjs (Disaster Recovery, alle 2 Wochen)
```

## Kritische Findings für Übergabe

- **Code-Review-Ergebnis:** CHANGELOG.md, `package.json` v1.1.0, Node ≥20.10, `.env.example` komplett, `.gitignore` filtert `*.lock` und `missing-analysis.csv`
- **Nachzubessern vor Donnerstag-Übergabe:**
  1. `mantle-reconcile-diag.mjs` nachliefern (kritisch — Doku verweist darauf)
  2. `deniz@thalor.de` und `Roman Staempfli` aus OPERATIONS.md anonymisieren (auf `backend@herosoftware.com` / `Max Mustermann`)

## Quelle

Claude-Chat "HeroSoftware Übergabe" 2026-04-13.
