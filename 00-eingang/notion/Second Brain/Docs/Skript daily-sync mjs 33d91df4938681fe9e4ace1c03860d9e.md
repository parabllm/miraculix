# Skript: daily-sync.mjs

Created: 9. April 2026 11:34
Doc ID: DOC-37
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 11:34
Lifecycle: Active
Notes: daily-sync.mjs: täglich 6 Uhr, aktualisiert MRR + Plan-Status + sync-Datum aller bekannten Mantle-Kunden in Attio. Ergänzt WF1 (das nur webhook-getriggert ist). Speicherort /opt/hero/daily-sync.mjs auf Hetzner.
Pattern Tags: Sync
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Stable
Stack: Attio, Python
Verified: No

## Scope

`daily-sync.mjs` ist das tägliche Wartungs-Skript für alle bestehenden Companies in Attio die einen Mantle-Bezug haben. Es hält MRR, Plan-Status und Sync-Datum aktuell ohne Mantle-Webhooks abzuwarten. Ergänzt WF1 (das nur auf Webhook-Events reagiert).

## Architecture / Constitution

- **Speicherort:** `/opt/hero/daily-sync.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 6 * * *` (täglich 06:00 Uhr Berlin-Zeit)
- **Trigger:** Cron, kein manueller Lauf vorgesehen außer Debug
- **Quelle:** Mantle Customer API (`last30Revenue`, Subscription-Felder)
- **Ziel:** Attio Companies (MRR, Plan-Felder, Sync-Datum)

## Was das Skript macht

1. **Companies aus Attio laden** — alle Companies die einen `shopify_url` haben (= bekannte Mantle-Kunden)
2. **Pro Company:** Mantle Customer via API holen (suche per `shopifyDomain`)
3. **MRR aktualisieren:** `customer.last30Revenue` → Attio `mrr`
4. **Plan-Status prüfen:** `appInstallations` durchgehen, pro App den aktuellen Plan-Status berechnen (gleiche Logik wie WF1 Node 4)
5. **Sync-Datum updaten:** Attio `sync` auf heutiges Datum setzen
6. **PATCH auf Company:** alle geänderten Felder in einem PATCH

## Logik im Detail

- Verwendet die gleichen Plan-Normalisierungs-Funktionen wie WF1 (`normalizeAH`, `normalizePH`, `normalizeDH`)
- Skip wenn Mantle-Customer nicht mehr existiert (gelöscht oder nie da gewesen) — wird im Log markiert
- Skip wenn Attio-Company keine Shopify-URL hat (= nicht via Mantle gepflegt)
- Bei API-Fehlern: 3-fach Retry mit 5s Pause
- Rate-Limit-Schutz: 300ms Pause zwischen Companies

## Logging

Log-Datei: `/var/log/hero/daily-sync.log`

```
0 6 * * * cd /opt/hero && node daily-sync.mjs >> /var/log/hero/daily-sync.log 2>&1
```

Entries enthalten: Timestamp, Anzahl Companies, Anzahl Updates, Anzahl Skips, Anzahl Fehler.

## Edge Cases

- **Mantle Customer nicht gefunden:** Skip mit Log-Eintrag, kein Attio-Update
- **MRR ist null/undefined:** Wert bleibt unangetastet (kein Überschreiben mit 0)
- **Plan-Wechsel zwischen Calls:** Downgrade-Erkennung wie in WF1 (Suffix `(Downgraded)`)
- **Race Condition mit WF1:** Wenn WF1 gerade eine Company aktualisiert, kann daily-sync 0 Änderungen erkennen — das ist OK, beim nächsten Lauf wird's gefangen

## Beziehung zu WF1

- **WF1** = reaktiv, läuft pro Mantle-Event
- **daily-sync** = proaktiv, holt MRR-Snapshots für alle Companies einmal täglich (auch wenn kein Webhook kam)
- **wf1-backup.mjs** = Disaster Recovery, replikiert die ganze WF1-Pipeline alle 14 Tage

Alle drei Skripte teilen die gleichen Helper-Funktionen für Plan-Normalisierung und Attio-PATCHes.

## Open Questions

- Aktuell keine — läuft stabil im Cron