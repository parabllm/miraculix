---
typ: aufgabe
name: "Skript daily-sync.mjs"
projekt: "[[herosoftware]]"
status: erledigt
benoetigte_kapazitaet: niedrig
kontext: ["desktop"]
kontakte: []
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Tägliches Wartungs-Skript für alle bestehenden Companies in Attio mit Mantle-Bezug. Hält MRR, Plan-Status und Sync-Datum aktuell ohne Mantle-Webhooks abzuwarten. Ergänzt [[wf1-mantle-attio]] (das nur auf Webhook-Events reagiert).

## Architektur

- **Speicherort:** `/opt/hero/daily-sync.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 6 * * *` (täglich 06:00 Berlin)
- **Trigger:** Cron, kein manueller Lauf vorgesehen außer Debug
- **Quelle:** Mantle Customer API (`last30Revenue`, Subscription-Felder)
- **Ziel:** Attio Companies (MRR, Plan-Felder, Sync-Datum)

## Was das Skript macht

1. **Companies aus Attio laden** - alle mit `shopify_url` (bekannte Mantle-Kunden)
2. **Pro Company:** Mantle Customer via API holen (Suche per `shopifyDomain`)
3. **MRR aktualisieren:** `customer.last30Revenue` → Attio `mrr`
4. **Plan-Status prüfen:** `appInstallations` durchgehen, pro App Plan-Status berechnen (gleiche Logik wie WF1 Node 4)
5. **Sync-Datum updaten:** Attio `sync` auf heutiges Datum
6. **PATCH auf Company:** alle geänderten Felder in einem PATCH

## Logik im Detail

- Verwendet gleiche Plan-Normalisierungs-Funktionen wie WF1 (`normalizeAH`, `normalizePH`, `normalizeDH`)
- Skip wenn Mantle-Customer nicht mehr existiert (gelöscht oder nie da gewesen) - im Log markiert
- Skip wenn Attio-Company keine Shopify-URL hat (nicht via Mantle gepflegt)
- Bei API-Fehlern: 3-fach Retry mit 5s Pause
- Rate-Limit-Schutz: 300ms Pause zwischen Companies

## Logging

Log-Datei: `/var/log/hero/daily-sync.log`. Entries: Timestamp, Anzahl Companies, Updates, Skips, Fehler.

## Edge Cases

- **Mantle Customer nicht gefunden:** Skip mit Log, kein Attio-Update
- **MRR null/undefined:** Wert bleibt unangetastet (kein Überschreiben mit 0)
- **Plan-Wechsel zwischen Calls:** Downgrade-Erkennung wie in WF1 (Suffix `(Downgraded)`)
- **Race Condition mit WF1:** Wenn WF1 gerade eine Company aktualisiert, kann daily-sync 0 Änderungen erkennen - OK, beim nächsten Lauf gefangen

## Beziehung zu anderen Komponenten

- **WF1** - reaktiv, läuft pro Mantle-Event
- **daily-sync** - proaktiv, holt MRR-Snapshots einmal täglich
- **wf1-backup.mjs** - Disaster Recovery, replikiert WF1-Pipeline alle 14 Tage

Alle drei teilen Helper-Funktionen für Plan-Normalisierung und Attio-PATCHes.
