---
typ: wissen
name: "Slack 3s-Timeout Pattern (Sofort-ACK + Worker)"
aliase: ["Slack Timeout", "Slash Command Async", "Slack Interactivity Pattern"]
domain: ["slack", "n8n", "async-patterns"]
kategorie: pattern
vertrauen: abgeleitet
quellen:
  - "[[01-projekte/thalor/pulsepeptides/logs/2026-03-19-pulse-restrukturierung]]"
  - "[[01-projekte/thalor/pulsepeptides/_projekt]]"
projekte: ["[[pulsepeptides]]"]
zuletzt_verifiziert: 2026-04-16
widerspricht: null
erstellt: 2026-04-16
---

## Problem

Slack gibt Slash-Commands + Button-Klicks genau **3 Sekunden** Zeit für die initiale Antwort. Länger → "operation_timeout" Error, User sieht rote Fehlermeldung.

Bei komplexen Workflows (DB-Lookup, OpenAI-Call, Google-Sheet-Write) ist 3s unrealistisch.

## Lösung

**Zwei-Phasen-Response:**

1. **Phase 1 (< 3s):** n8n-Webhook antwortet Slack sofort mit `response_url`-ACK (z.B. `{"text": "⏳ Verarbeite…"}`). Slack zeigt das als Ephemeral-Message.
2. **Phase 2 (async):** n8n-Worker arbeitet weiter, POSTed fertiges Ergebnis an Slacks `response_url`. User sieht die finale Antwort als Update derselben Message.

## Implementation-Detail (PulseBot)

- **Router-WF** (synchron): parsed Slash-Command, schickt sofort ACK
- **Interactivity-WF** (async): macht die eigentliche Arbeit, nutzt `response_url` aus Payload für Rückmeldung

## Wo angewendet

- [[pulsepeptides]] PulseBot Router + Interactivity Workflows

## Verwandte Patterns

- **Gmail-Send als Reliability-Gate**: bevor Status-Update in Google Sheet gemacht wird, muss Email-Send erfolgreich sein → bei Fehler bleibt State unverändert, Retry greift beim nächsten Lauf
- **Batch-ID-Schema** `{SupplierCode}{YY}{Q#}{Seq}{ProductCode}` — z.B. `LP26Q11BPC`: eindeutig, sortierbar, menschenlesbar

## Grenzen

Pattern transferierbar auf andere Chat-Bot-Integrationen (Telegram, Discord, Teams). Ähnliche Timeout-Limits dort — Prinzip "erst ACK, dann Arbeit" gilt überall.
