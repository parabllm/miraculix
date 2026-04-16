---
typ: log
projekt: "[[herosoftware]]"
datum: 2026-03-25
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["hetzner", "n8n", "node"]
---

Hetzner-Server eingerichtet (`204.168.188.228`). Thalor-Infrastruktur live.

## Ergebnis

- **Hetzner VPS** für 4,15€/Monat (Ubuntu 24.04, Helsinki)
- **Eigenes n8n** auf `https://n8n.thalor.de`, SSL via Let's Encrypt, passwortgeschützt, 24/7 online
- **SSL-Auto-Renewal** bis Juni 2026, dann automatisch
- **`daily-sync.mjs`** Cron-Job läuft täglich 04:00 — synct Mantle → Attio
- Alles auf einem Server

## Kontext

Motivation war: Daten aktiver aktualisieren als nur Webhook-basiert. Batch-Sync-Pattern etabliert sich für die späteren Scripts (`lgm-push`, `lgm-status-sync`, `wf1-backup`).

## Quelle

Claude-Chat "Hetzner Hero", 222 Messages, 221k Zeichen.
