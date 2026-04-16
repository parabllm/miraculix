---
typ: aufgabe
name: "Skript wf1-backup.mjs (Recovery + Backfill)"
projekt: "[[herosoftware]]"
status: erledigt
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: []
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Recovery- und Backfill-Skript für WF1. Repliziert komplette WF1-Logik gegen alle Mantle Customers statt nur auf einzelne Webhook-Events zu reagieren. Schutzfunktion wenn n8n Cloud ausfällt oder Webhooks verloren gehen, plus initialer Backfill-Lauf wenn neue Datenfelder hinzukommen. Initialer Backfill abgeschlossen.

## Architektur

- **Speicherort:** `/opt/hero/wf1-backup.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 1 * * 0/2` (jeden zweiten Sonntag 01:00 Berlin)
- **Quelle:** Mantle Customer API (paginiert, alle Customers)
- **Ziel:** Attio Companies + People + Activity Notes
- **Logik:** identisch zu WF1, aber sequenzielles Node.js-Skript statt n8n-Pipeline

## Was das Skript macht

Für jeden Mantle Customer:

1. Mantle Customer fetchen (paginiert)
2. Transform - gleiche Plan-Normalisierung wie WF1 Node 4
3. Search by Shopify URL → Match? → Update Company
4. Search by Domain (mit `.myshopify.com`-Filter) → Dup-Check → Update
5. Search by Name (cleanCompanyName + exakter Match) → Dup-Check → Update
6. Create new Company mit 3-Versuch-Race-Condition-Logik
7. Set Extra Fields (Plans, Owner, Commission, Downgrade-Erkennung)
8. Create People (Contacts upsert per Email)
9. Link Team (Company ↔ People dedupliziert)
10. Create Activity Note (markiert mit `source: backfill` statt Webhook-Event)

## Unterschiede zu WF1

| Aspekt | WF1 | wf1-backup |
|---|---|---|
| Trigger | Mantle Webhook | Cron (jeden 2. Sonntag 01:00) |
| Quelle | Einzelner Customer aus Webhook | Alle Mantle Customers (paginiert) |
| Activity Note Source | `Event: customers/upgraded` | `Event: backfill_run`, Date = Lauf-Datum |
| Wait-Logic | 15s Wait + Wait for Note | Kein Wait nötig (kein Race mit Mantle) |
| Race Condition | Hoch (parallele Webhooks) | Sequenziell, kaum Race |
| Idempotenz | Per Match-Strategie | Match-Strategie + Skip wenn `sync` heute |

## Idempotenz

- Skript prüft pro Company ob `sync = heutiges Datum`. Wenn ja → Skip (durch WF1 oder daily-sync schon gefangen)
- Alle Updates sind idempotent (gleicher Input → gleicher Output)
- Activity Notes werden bei Backfill nur einmal pro Lauf-Datum erstellt (kein Spam)

## Use Cases

1. **Disaster Recovery:** n8n Cloud fällt aus, Webhooks gehen verloren → wf1-backup fängt das beim nächsten Sonntag-Lauf ab
2. **Backfill bei neuen Feldern:** Neues Attio-Feld aus Mantle füllen → einmal manuell ausführen
3. **Initialer Massen-Import:** bereits einmal genutzt um alle bestehenden Mantle-Kunden in Attio zu befüllen
4. **Konsistenzprüfung:** alle 14 Tage als routinemäßiger Sicherheits-Re-Sync

## Performance

- Sequenziell, 1 Customer nach dem anderen
- 300ms Pause zwischen Customers (Rate-Limit-Schutz)
- Bei ~6.500 Customers: ca. 30-40 Minuten Laufzeit
- Logs alle 100 Customers ge-flushed

## Edge Cases

- **Mantle Customer existiert nicht mehr:** Customer-ID weg → skipped (kein Attio-Löschen)
- **Attio Company ohne Mantle-Bezug:** nicht berührt (Skript geht nur von Mantle aus)
- **Cron-Lauf während WF1 Webhook:** idempotent - wer zuerst PATCHt gewinnt, beim nächsten Lauf egalisiert
- **Activity Note Spam vermeiden:** pro Customer pro Tag nur eine Backfill-Note
