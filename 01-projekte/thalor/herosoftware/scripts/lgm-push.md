---
typ: aufgabe
name: "Skript lgm-push.mjs (Attio → LGM)"
projekt: "[[herosoftware]]"
status: erledigt
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: []
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Wöchentliches Outbound-Routing. Liest die 4 Attio-Listen, filtert enrichte Personen die noch nicht kontaktiert wurden, pusht sie in die richtigen LGM Audiences (DE oder EN je nach Sprache). Ersetzt n8n WF2 (wegen 60s Timeout nicht zuverlässig genug).

## Architektur

- **Speicherort:** `/opt/hero/lgm-push.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 7 * * 2` (Dienstag 07:00 Berlin)
- **DRY RUN:** `node lgm-push.mjs --dry`
- **Quelle:** Attio (4 Listen mit enrichten Companies + People)
- **Ziel:** LGM (8 Audiences, 4 Listen × 2 Sprachen)
- **Ersetzt:** n8n WF2 (`RHJQfaRuXGJPkUpM`, noch als Backup in n8n Cloud)

## Logik

1. Lädt alle 4 Attio-Listen parallel
2. Pro Liste die Companies in 10er-Batches
3. **Pre-Filter Company:** nur mit `enriched_by_clay = true` ODER `manually_enriched = true`
4. Pro Company alle People laden
5. **Pro Person 3 Checks:**
   - Email vorhanden
   - `sequence_status` leer / "Not Started" / "Not Activated"
   - `contact_language` DE oder EN
6. **Routing:** DE → DE Audience, EN → EN Audience (pro Liste eigenes Mapping, siehe [[lgm-integration]])
7. **Lead Quality berechnen:**
   - Email + Phone + LinkedIn = Priority
   - Email + LinkedIn = Standard
   - Nur Email = Basic
8. **LGM Push:** POST `/flow/leads` mit `audience` (NICHT `audienceId`), KEIN `identity` Feld
9. **Duplikat-Check:** bei LGM "duplicate" → Attio NICHT geupdatet
10. **Attio Person Update:** `sequence_status = Started`, `contacted_at = now`, `lgm_sequence`, `lead_quality`
11. **Attio Company Update:** `outbound_status_2 = In Sequence`

## Datenfeld-Konventionen (kritisch)

- **Telefon:** Attio Custom-Feld `telefon` (Text), NICHT `phone_numbers` (Standard, immer leer)
- **Name:** `name[0].first_name` und `name[0].last_name` (zusammengesetzt) - NICHT `first_name[0].value`
- **LGM Lead Body:** KEIN `identity` Feld (sonst 404 "body.identity is not allowed")
- **LGM `audience` Feld:** heißt `audience`, NICHT `audienceId`

## Lead Quality System

| Quality | Daten | LGM Sequence? |
|---|---|---|
| Priority | Email + Phone + LinkedIn | Ja (alle 3 Kanäle) |
| Standard | Email + LinkedIn | Ja (Email + LinkedIn) |
| Basic | Nur Email | Ja (nur Email) |
| Low | Nur LinkedIn | Nein |

## Retry & Rate-Limits

- 3x Retry bei `429` oder `500`
- 300ms Pause zwischen Leads
- Pro Lauf Summary-Log (pushed, skipped, failed pro Liste)

## Edge Cases

- **LinkedIn-only Person:** Lead Quality = Low → wird NICHT gepusht (LGM braucht Email)
- **Person bereits in Sequence:** `sequence_status ≠ Not Started` → Skip ohne Update
- **Sprache fehlt:** weder DE noch EN → Skip mit Log
- **Manueller CSV-Import durch Robin:** `lgm-status-sync.mjs` erkennt diese Leads später via Email-Match
- **LGM Duplikat (LinkedIn-Match):** LGM dedupliziert automatisch über LinkedIn URL, Attio wird nicht geändert

## Bekannte LGM API-Bugs (workaround drin)

- `POST /flow/leads` mit `identity` → 404 → Body sendet KEIN identity
- `GET /audiences` gibt `{ audiences: [] }`, NICHT `{ data: [] }` → Response-Parser muss `res.audiences` lesen
