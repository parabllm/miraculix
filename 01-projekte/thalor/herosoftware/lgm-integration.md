---
typ: aufgabe
name: "HeroSoftware LGM Integration"
projekt: "[[herosoftware]]"
status: erledigt
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[robin-kronshagen]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

La Growth Machine (LGM) = Multi-Channel Outreach-Tool für HeroSoftware (Email + LinkedIn + Call). Stand 2026-04-09.

## Architektur

- **Routing-Prinzip:** Attio-Liste = LGM Sequence. Robin sortiert manuell, Skripte routen automatisch.
- **8 Audiences total** (4 Listen × 2 Sprachen DE/EN)
- **Push-Skript:** [[lgm-push]] (Hetzner)
- **Status-Sync-Skript:** [[lgm-status-sync]] (Hetzner)
- **Backup:** n8n WF2 + WF3 existieren noch in n8n Cloud, nicht produktiv

## API Details

- **Base URL:** `https://apiv2.lagrowthmachine.com/flow`
- **Auth:** Query Parameter `?apikey=[KEY]`
- **Lead erstellen:** `POST /flow/leads` mit Feld `"audience"` (NICHT `"audienceId"`). KEIN `identity` Feld im Body (→ 404 "body.identity is not allowed")
- **Lead suchen:** `GET /flow/leads/search?email=X`
- **Audience Leads:** `GET /flow/audiences/{id}/leads?limit=100&skip=0` (max limit=100, Pagination via skip)
- **Campaigns:** `GET /campaigns?limit=20`
- **Audiences-Liste:** `GET /audiences` - Response-Format: `{ statusCode: 200, audiences: [...] }` (NICHT `data`)

## Members & Identities

### Members

| Person | ID |
|---|---|
| Calvin Blick | `69bbfabceab11380394bd45e` |
| Robin Kronshagen | `69bd20a3eb26c79ca9e618d1` |

### Identities (Absender)

| Person | Identity ID |
|---|---|
| Robin | `69bbfccff6d5a1f81a79bfcd` |
| Calvin | `69bbfac26919f2f7a96046fb` |

## Campaigns (erstellt 2026-03-31)

| Campaign | ID | Status |
|---|---|---|
| AddressHero Cold Outreach_DE | `69cbde5fdf828b715b901c10` | READY |
| AddressHero Cold Outreach_EN | `69cbe4d8edbbe60e5fe46f88` | READY |
| AddressHero Upsell Lite to Pro_EN | `69cbe84086fe111c360d156f` | READY |
| AddressHero Cross-Sell from PH_DE 16 | `69cbe8623babe8c484151e5b` | READY |

Alte Campaign-IDs (69c11d...) sind veraltet - Robin hat neue erstellt.

## Audiences (8 total)

| Audience | ID |
|---|---|
| Cold Outreach DE | `69cbf0fd3babe8c4841520a5` |
| Cold Outreach EN | `69cbf108e85f1c39aa069272` |
| Churns DE | `69cbfc03d569e98918319793` |
| Churns EN | `69cbfc17502e78e1d92e7358` |
| Cross-Sell from PH DE | `69cbfc2c3dd5d354f6fff18d` |
| Cross-Sell from PH EN | `69cbfc35e8cf2c0cba39a694` |
| Upsell Lite to Pro DE | `69cbfc48caa217acf97dd09d` |
| Upsell Lite to Pro EN | `69cbfc503babe8c4841525ba` |

Alte Cold Outreach Audience (`69cad325...`) gelöscht.

## Sequence-Mapping (Attio-Liste → LGM Audiences)

| Attio-Liste | Attio List ID | DE Audience | EN Audience |
|---|---|---|---|
| AddressHero Cold Outreach | `1f1b1391-26ab-41fa-a91b-d538852acc45` | `69cbf0fd3babe8c4841520a5` | `69cbf108e85f1c39aa069272` |
| AddressHero Churns | `f2bfe4a9-884c-44e5-bb63-0268747ba2a5` | `69cbfc03d569e98918319793` | `69cbfc17502e78e1d92e7358` |
| AddressHero Cross-Sell from PH | `08f3afae-33a5-405f-afdd-d5bf4146f463` | `69cbfc2c3dd5d354f6fff18d` | `69cbfc35e8cf2c0cba39a694` |
| AddressHero Upsell Lite to Pro | `2c828709-00a9-4c5f-921c-132e4760e121` | `69cbfc48caa217acf97dd09d` | `69cbfc503babe8c4841525ba` |

## Regeln

- **Attio-Liste = Sequence-Routing** - Robin sortiert manuell, Skripte routen automatisch
- **Duplikat-Schutz:** `sequence_status` ≠ "Not Started" / "Not Activated" → Person wird NICHT nochmal gepusht
- **Neue Personen bei enriched Companies** werden gepusht, bestehende übersprungen
- **Manueller LGM-Import:** Robin kann CSV aus Attio importieren. `lgm-status-sync.mjs` erkennt diese Leads und synct Status zurück
- **Telefon-Feld:** Attio Custom-Feld `telefon` (Text), NICHT `phone_numbers` (Standard, immer leer)
- **Name-Feld:** Attio `name[0].first_name` / `.last_name` (zusammengesetztes Feld, NICHT `first_name[0].value`)
- **LGM API Lead-Body:** KEIN `identity` Feld (gibt 404)
- **LGM Audiences API Response:** `{ statusCode: 200, audiences: [...] }` - NICHT `data`
- **Phone NUR bei `Language = DE`** (spart Credits)
- **Dienstags-Rhythmus:** Clay enriched täglich → Dienstag morgens `lgm-push.mjs` → LGM Push

## Bekannte API-Bugs (in Skripten gefixt)

- LGM `POST /flow/leads` mit `identity` → 404 "body.identity is not allowed"
- LGM `GET /audiences` gibt `{ audiences: [] }`, NICHT `{ data: [] }`
- Attio `telefon` ist Custom Text-Feld, `phone_numbers` ist Standard und immer leer
- Attio People `name` ist zusammengesetztes Feld mit `first_name`, `last_name`, `full_name` als Sub-Properties
- LGM dedupliziert intern über LinkedIn URL - gleiche LinkedIn = gleicher Lead, wird ignoriert
- LGM `audience` Feld heißt `audience`, NICHT `audienceId`
- Attio Select-Werte case-sensitive: "Ready to Buy" nicht "Ready To Buy", "Out of Office" nicht "Out Of Office"

## Edge Cases

- Cold Outreach Campaign wurde versehentlich gelöscht - Robin neu erstellt, daher neue IDs vom 31.03.
- Manueller CSV-Import durch Robin: wird vom Status-Sync-Skript via Email-Match trotzdem gefangen
- Person ohne LGM Match (LinkedIn-Match dedup): Attio wird nicht geändert, nur Log-Eintrag

## Beziehungen

- **Quelle:** Clay-enrichte Companies + People in Attio (`enriched_by_clay = true`)
- **Push:** [[lgm-push]]
- **Status-Rückkanal:** [[lgm-status-sync]]
- **Sequence-Owner:** Robin (sortiert Companies in Attio-Listen, System routet)
