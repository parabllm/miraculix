# Skript: lgm-push.mjs (Attio → LGM)

Created: 9. April 2026 11:34
Doc ID: DOC-38
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 11:34
Lifecycle: Active
Notes: lgm-push.mjs: Dienstag 7 Uhr, pusht enrichte Leads aus 4 Attio-Listen in 8 LGM Audiences (DE+EN). Ersetzt n8n WF2 wegen 60s Timeout. Pre-Filter: enriched_by_clay/manually_enriched + sequence_status leer. Lead Quality 4-stufig. Telefon aus Custom-Feld telefon (NICHT phone_numbers). KEIN identity Feld in LGM Body.
Pattern Tags: Enrichment, Sync
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Stable
Stack: Attio, LGM, Python
Verified: No

## Scope

`lgm-push.mjs` ist das wöchentliche Outbound-Routing-Skript. Es liest die 4 Attio-Listen, filtert die enrichten Personen die noch nicht kontaktiert wurden, und pusht sie in die richtigen LGM Audiences (DE oder EN, je nach Sprache). Ersetzt das frühere n8n WF2 (das wegen 60s Timeout nicht zuverlässig genug war).

## Architecture / Constitution

- **Speicherort:** `/opt/hero/lgm-push.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 7 * * 2` (Dienstag 07:00 Uhr Berlin-Zeit)
- **DRY RUN:** `node lgm-push.mjs --dry`
- **Quelle:** Attio (4 Listen mit enrichten Companies + People)
- **Ziel:** LGM (8 Audiences, 4 Listen × 2 Sprachen)
- **Ersetzt:** n8n WF2 (`RHJQfaRuXGJPkUpM`, noch in n8n Cloud als Backup vorhanden)

## Logik

1. **Lädt alle 4 Attio-Listen** parallel
2. **Pro Liste die Companies** in 10er-Batches
3. **Pre-Filter Company:** nur Companies mit `enriched_by_clay = true` ODER `manually_enriched = true`
4. **Pro Company alle People laden**
5. **Pro Person 3 Checks:**
    - (1) Email vorhanden
    - (2) `sequence_status` ist leer / "Not Started" / "Not Activated"
    - (3) `contact_language` ist DE oder EN
6. **Routing:** DE → DE Audience, EN → EN Audience (pro Liste eigenes Mapping)
7. **Lead Quality berechnen:**
    - Email + Phone + LinkedIn = **Priority**
    - Email + LinkedIn = **Standard**
    - Nur Email = **Basic**
8. **LGM Push:** POST `/flow/leads` mit `audience` (NICHT `audienceId`!) und KEIN `identity` Feld im Body
9. **Duplikat-Check:** wenn LGM "duplicate" zurückgibt → Attio wird NICHT geupdated
10. **Attio Person Update:** `sequence_status = Started`, `contacted_at = now`, `lgm_sequence`, `lead_quality`
11. **Attio Company Update:** `outbound_status_2 = In Sequence`

## Datenfeld-Konventionen (kritisch)

- **Telefon:** Attio Custom-Feld `telefon` (Text), NICHT `phone_numbers` (Standard, immer leer)
- **Name:** `name[0].first_name` und `name[0].last_name` (zusammengesetztes Feld) — NICHT `first_name[0].value`
- **LGM Lead Body:** KEIN `identity` Feld (sonst 404 "body.identity is not allowed")
- **LGM `audience` Feld:** heißt `audience`, NICHT `audienceId`

## Sequence-Mapping (Attio-Liste → LGM Audiences)

| Attio-Liste | Attio List ID | DE Audience | EN Audience |
| --- | --- | --- | --- |
| AddressHero Cold Outreach | `1f1b1391-26ab-41fa-a91b-d538852acc45` | `69cbf0fd3babe8c4841520a5` | `69cbf108e85f1c39aa069272` |
| AddressHero Churns | `f2bfe4a9-884c-44e5-bb63-0268747ba2a5` | `69cbfc03d569e98918319793` | `69cbfc17502e78e1d92e7358` |
| AddressHero Cross-Sell from PH | `08f3afae-33a5-405f-afdd-d5bf4146f463` | `69cbfc2c3dd5d354f6fff18d` | `69cbfc35e8cf2c0cba39a694` |
| AddressHero Upsell Lite to Pro | `2c828709-00a9-4c5f-921c-132e4760e121` | `69cbfc48caa217acf97dd09d` | `69cbfc503babe8c4841525ba` |

## Lead Quality System (4 Stufen)

| Quality | Daten | LGM Sequence? |
| --- | --- | --- |
| Priority | Email + Phone + LinkedIn | Ja (alle 3 Kanäle) |
| Standard | Email + LinkedIn | Ja (Email + LinkedIn) |
| Basic | Nur Email | Ja (nur Email) |
| Low | Nur LinkedIn | Nein |

## Retry & Rate-Limits

- 3x Retry bei `429` oder `500`
- 300ms Pause zwischen Leads
- Pro Lauf wird ein Summary-Log geschrieben (Anzahl pushed, skipped, failed pro Liste)

## Edge Cases

- **LinkedIn-only Person:** Lead Quality = Low → wird NICHT gepusht (LGM braucht Email)
- **Person bereits in Sequence:** `sequence_status ≠ Not Started` → Skip ohne Update
- **Sprache fehlt:** weder DE noch EN → Skip mit Log
- **Manueller LGM-Import durch Robin (CSV):** `lgm-status-sync.mjs` erkennt diese Leads später trotzdem via Email-Match
- **LGM Duplikat (LinkedIn-Match):** LGM dedupliziert automatisch über LinkedIn URL, Attio wird in dem Fall nicht geändert

## Bekannte LGM API-Bugs (workaround drin)

- `POST /flow/leads` mit `identity` Feld → 404 "body.identity is not allowed" → Body sendet KEIN identity
- `GET /audiences` gibt `{ audiences: [] }` zurück, NICHT `{ data: [] }` → Response-Parser muss `res.audiences` lesen

## Logging

```
0 7 * * 2 cd /opt/hero && node lgm-push.mjs >> /var/log/hero/lgm-push.log 2>&1
```

## Open Questions

- Aktuell keine — erster Push lief erfolgreich durch