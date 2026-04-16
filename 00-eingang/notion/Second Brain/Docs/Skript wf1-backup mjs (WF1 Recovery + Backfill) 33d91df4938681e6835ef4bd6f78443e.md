# Skript: wf1-backup.mjs (WF1 Recovery + Backfill)

Created: 9. April 2026 11:34
Doc ID: DOC-40
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 11:34
Lifecycle: Active
Notes: wf1-backup.mjs: jeden 2. Sonntag 1 Uhr, repliziert komplette WF1-Logik gegen alle Mantle Customers. Disaster Recovery + Backfill-Werkzeug. Initialer Backfill abgeschlossen. Idempotent (skip wenn sync heute). Activity Notes mit source=backfill_run.
Pattern Tags: Backfill, Sync
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Stable
Stack: Attio, Python
Verified: No

## Scope

`wf1-backup.mjs` ist das Recovery- und Backfill-Skript für WF1. Es repliziert die komplette WF1-Logik gegen alle Mantle Customers (statt nur auf einzelne Webhook-Events zu reagieren). Schutzfunktion für den Fall dass n8n Cloud ausfällt oder Webhooks verloren gehen — plus initialer Backfill-Lauf wenn neue Datenfelder hinzukommen.

Wurde bereits einmal als kompletter Backfill ausgeführt (alle Mantle Customers → Attio).

## Architecture / Constitution

- **Speicherort:** `/opt/hero/wf1-backup.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 1 * * 0/2` (jeden zweiten Sonntag 01:00 Uhr Berlin-Zeit)
- **Quelle:** Mantle Customer API (paginiert, alle Customers)
- **Ziel:** Attio Companies + People + Activity Notes
- **Logik:** identisch zu WF1, aber als sequenzielles Node.js Skript statt n8n-Pipeline

## Was das Skript macht

Für jeden Mantle Customer durchläuft es die gleiche Match-Strategie wie WF1:

1. **Mantle Customer fetchen** (paginiert, Batch-Größe konfigurierbar)
2. **Transform** — gleiche Plan-Normalisierung wie WF1 Node 4
3. **Search by Shopify URL** → Match? → Update Company
4. **Search by Domain** (mit `.myshopify.com` Filter) → Dup-Check → Update
5. **Search by Name** (cleanCompanyName + exakter Match) → Dup-Check → Update
6. **Create new Company** mit 3-Versuch-Race-Condition-Logik
7. **Set Extra Fields** (Plans, Owner, Commission, Downgrade-Erkennung)
8. **Create People** (Contacts upsert per Email)
9. **Link Team** (Company ↔ People dedupliziert)
10. **Create Activity Note** (markiert mit `source: backfill` statt Webhook-Event)

## Unterschiede zu WF1

| Aspekt | WF1 | wf1-backup |
| --- | --- | --- |
| Trigger | Mantle Webhook | Cron (jeden 2. Sonntag 01:00) |
| Quelle | Einzelner Customer aus Webhook | Alle Mantle Customers (paginiert) |
| Activity Note Source | `Event: customers/upgraded` | `Event: backfill_run`, Date = Lauf-Datum |
| Wait-Logic | 15s Wait + Wait for Note | Kein Wait nötig (kein Race mit Mantle) |
| Race Condition | Hoch (parallele Webhooks) | Sequenziell, kaum Race |
| Idempotenz | Per Match-Strategie | Per Match-Strategie + Skip wenn `sync` heute |

## Idempotenz

- Skript prüft pro Company ob `sync = heutiges Datum`. Wenn ja → Skip (wurde durch WF1 oder vorherigen daily-sync schon gefangen)
- Alle Updates sind idempotent (gleicher Input ergibt gleichen Output in Attio)
- Activity Notes werden bei Backfill nur einmal pro Lauf-Datum erstellt (kein Spam)

## Use Cases

1. **Disaster Recovery:** n8n Cloud fällt aus, Webhooks gehen verloren → wf1-backup fängt das beim nächsten Sonntag-Lauf ab
2. **Backfill bei neuen Feldern:** Wenn ein neues Attio-Feld hinzukommt das aus Mantle gefüllt werden soll — einmal manuell ausführen
3. **Initialer Massen-Import:** Wurde bereits einmal verwendet um alle bestehenden Mantle-Kunden in Attio zu befüllen — abgeschlossen
4. **Konsistenzprüfung:** Alle 14 Tage als routinemäßige Sicherheits-Re-Sync

## Performance

- Sequenziell, 1 Customer nach dem anderen
- 300ms Pause zwischen Customers (Rate-Limit-Schutz)
- Bei ~6.500 Customers: ca. 30-40 Minuten Laufzeit
- Logs werden alle 100 Customers ge-flushed

## Logging

```
0 1 * * 0/2 cd /opt/hero && node wf1-backup.mjs >> /var/log/hero/wf1-backup.log 2>&1
```

Log enthält: Start-Timestamp, Anzahl Mantle Customers, pro Customer ein Status (updated/created/skipped/error), End-Timestamp + Summary.

## Edge Cases

- **Mantle Customer existiert nicht mehr:** Wenn eine Customer-ID weg ist, wird sie skipped (kein Attio-Löschen)
- **Attio Company existiert ohne Mantle-Bezug:** Wird nicht berührt (Skript geht nur von Mantle aus, nicht von Attio)
- **Cron-Lauf während WF1 Webhook läuft:** Idempotent — wer zuerst PATCHt gewinnt, beim nächsten Lauf wird's egalisiert
- **Activity Note Spam vermeiden:** Pro Customer pro Tag nur eine Backfill-Note

## Open Questions

- Aktuell keine — läuft erfolgreich. Initialer Backfill ist abgeschlossen.