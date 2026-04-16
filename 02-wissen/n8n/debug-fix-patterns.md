---
typ: wissen
name: "n8n Debug & Fix Patterns (HeroSoftware)"
aliase: ["n8n Bugs", "n8n Fixes", "Mantle-Attio Bugs"]
domain: ["n8n", "attio", "mantle", "lgm"]
kategorie: debug_fix
vertrauen: bestaetigt
quellen:
  - "[[wf1-mantle-attio]]"
  - "[[lgm-push]]"
  - "[[lgm-status-sync]]"
projekte: ["[[herosoftware]]"]
zuletzt_verifiziert: 2026-04-09
widerspricht: null
erstellt: 2026-04-16
---

Lebender Bug-Tracker für n8n-Probleme im HeroSoftware-Kontext. 14 Initial-Bugs. Alle Fixes sind LIVE in WF1, WF2, WF3 oder den Hetzner-Skripten.

## Bei neuen Bugs

- Eintrag hinzufügen mit Symptom, Ursache, Fix, Datum
- Bei wiederkehrenden Patterns (3×): als statische Regel notieren und hier mit "→ jetzt im Skill" markieren
- Generische n8n Bugs (nicht HS-spezifisch): direkt in generische n8n-Wissens-Einträge, nicht hier

## Bekannte Bugs & Fixes

### Bug 01 - Race Condition bei parallelen Mantle Webhooks

- **Symptom:** Mantle feuert bei neuer Installation mehrere Events fast gleichzeitig (`installed` + `subscribed` innerhalb weniger Sekunden). Beide n8n Executions laufen parallel, beide suchen Attio, beide finden nichts, beide versuchen Create → zweite crasht mit Domain Uniqueness Conflict.
- **Ursache:** Mantle hat keine eingebaute Webhook-Serialisierung pro Customer. n8n Cloud Executions sind unabhängig.
- **Fix:** Zwei-Stufen-Schutz in WF1:
  1. Wait Node 15 Sekunden nach Webhook (erster Execution Vorsprung, behandelt auch Mantle API Propagation Delay)
  2. Create New Company als Code Node mit 3-Versuch-Conflict-Retry: (a) Create mit Domain, (b) bei Conflict Re-Search per `shopify_url` + PATCH statt POST, (c) Fallback Create ohne Domain
- **Status:** LIVE in WF1

### Bug 02 - Search by Name als HTTP Request Node liefert zu viele Treffer

- **Symptom:** Attio `$contains` macht Substring-Matching, nicht Exact-Match. "CK Store" matcht auch "TopPick Store" (weil "ck Store" Substring ist). HTTP Request Node kann nicht nachfiltern → Name Match wird FALSE obwohl exakter Treffer dabei wäre.
- **Ursache:** HTTP Request Node liefert rohe API-Response ohne lokale Filterung.
- **Fix:** Search by Name als Code Node mit `helpers.httpRequest` umbauen. `$contains`-Suche, danach lokal exakt filtern mit `cleanCompanyName().toLowerCase() === matchName.toLowerCase()`. Nur bei genau 1 exaktem Treffer + `name_matchable = true` → Match.
- **Status:** LIVE in WF1

### Bug 03 - Mantle 404 bei sofortigem Fetch nach Webhook

- **Symptom:** `GET /v1/customers/{id}` gibt 404 selbst 15+ Sekunden nach Webhook. Manchmal existiert Kunde tatsächlich (cURL erreichbar), aber n8n Execution bekommt 404.
- **Ursache:** API-Propagation-Delay bei Mantle.
- **Fix:** Retry on Fail auf HTTP Request Node: 3x mit 5s Pause.
- **Status:** LIVE in WF1 Node 3

### Bug 04 - Node-Referenz kaputt nach Delete + Recreate

- **Symptom:** Wenn HTTP Request Node gelöscht und durch Code Node mit gleichem Namen ersetzt wird, behalten nachfolgende Nodes kaputte `$()` Referenz. Beispiel: `$('Search by Name').item.json.data[0].id.record_id` wird zu `$('1').item...`.
- **Ursache:** n8n speichert intern Node-ID, Display-Name ist nur Alias. Beim Delete+Recreate wird ID neu vergeben, alte Referenzen aktualisieren sich nicht.
- **Fix:** Nach Node-Austausch ALLE nachfolgenden Nodes öffnen und alle `$()`-Referenzen prüfen (URL-Expressions, JSON Body Expressions, Code Node Aufrufe).
- **Status:** Kein automatischer Schutz, nur manuelles Prüfen

### Bug 05 - myshopify.com Domain-Filter fehlte

- **Symptom:** WF1 hat `customer.domain` direkt in Domain-Match geschickt. Mantle liefert manchmal `xyz.myshopify.com` → Suche in Attio matcht falsch oder crasht beim Create wegen Domain Uniqueness Conflict.
- **Ursache:** Mantle `domain`-Feld ist unzuverlässig: kann null, echte Custom-Domain, oder myshopify.com URL sein.
- **Fix:** `isMyshopifyDomain()` Helper im Transform Node. Wenn Domain auf `.myshopify.com` endet ODER leer ist → `match_domain = ""`. Search by Domain wird mit Fallback `SKIP_NO_DOMAIN_00000000` aufgerufen → garantiert kein Match. Create New setzt `domains: []` → kein Uniqueness-Conflict.
- **Status:** LIVE in WF1 Transform Node

### Bug 06 - Generische Firmennamen matchen auf falsche Companies

- **Symptom:** Mantle hat 90+ Customers mit "Mein Shop", 125+ mit "My Store", einige mit "Test", "Shop". Diese Namen matchten in Attio auf jeweils zufällige andere Companies.
- **Ursache:** Name-Matching ohne Blacklist unzuverlässig wenn Name generisch.
- **Fix:** `cleanCompanyName()` + `name_matchable` Flag:
  - Entfernt Rechtsformen (GmbH, AG, Ltd, Inc, UG, e.K., OHG, KG, SE, Co., Corp, LLC, S.L., B.V., Pty, Pvt, S.A.S., S.r.l.)
  - Entfernt Sonderzeichen ™ ® © | · — _
  - Mindestlänge: 4 Zeichen nach Bereinigung
  - Generische Namen Blacklist: "Mein Shop", "My Store", "Test", "Shop" → `name_matchable = false`
- **Status:** LIVE in WF1

### Bug 07 - LGM API: Feld heißt `audience` nicht `audienceId`

- **Symptom:** `POST /flow/leads` mit `audienceId` im Body → LGM ignoriert Feld, Lead ohne Audience-Zuordnung erstellt oder schlägt fehl.
- **Ursache:** LGM API Doku missverständlich.
- **Fix:** Body-Feld muss `audience` heißen.
- **Status:** LIVE in WF2 + lgm-push.mjs

### Bug 08 - LGM API: KEIN `identity` Feld im Lead-Body

- **Symptom:** `POST /flow/leads` mit `identity` Feld → 404 "body.identity is not allowed".
- **Ursache:** `identity` ist Sequence-Setting, kein Lead-Feld.
- **Fix:** `identity` Feld komplett aus Lead-Body weglassen.
- **Status:** LIVE in WF2 + lgm-push.mjs

### Bug 09 - LGM API: max limit=100, Pagination via skip

- **Symptom:** `GET /flow/audiences/{id}/leads?limit=500` ignoriert `limit`, gibt nur 100 Leads zurück.
- **Ursache:** LGM API Hard-Limit auf 100 pro Request.
- **Fix:** Code Node holt Leads in 100er-Chunks: `limit=100&skip=0`, dann `skip=100`, `skip=200` bis weniger als 100 zurückkommen.
- **Status:** LIVE in WF3 + lgm-status-sync.mjs

### Bug 10 - LGM Audiences API Response-Format

- **Symptom:** Code Node erwartet `response.data` als Array, bekommt aber `response.audiences`. Result: leeres Array.
- **Ursache:** `GET /audiences` gibt `{ statusCode: 200, audiences: [...] }` zurück, NICHT das übliche `{ data: [...] }`.
- **Fix:** Response-Parser muss `res.audiences` lesen.
- **Status:** LIVE in WF3 + lgm-status-sync.mjs

### Bug 11 - Attio Select-Felder Case-Sensitivity

- **Symptom:** PATCH auf `sequence_status` mit "Ready To Buy" (großes "To") → Fehler oder Attio erstellt NEUE Select-Option mit falschem Casing.
- **Ursache:** Attio Select-Optionen case-sensitive. Existierende Option: "Ready to Buy" (kleines "to").
- **Fix:** Immer exakte Option-Titel: "Ready to Buy" (NICHT "Ready To Buy"), "Out of Office" (NICHT "Out Of Office"), "Completed: No Reply" (mit Doppelpunkt).
- **Status:** LIVE in WF2 + WF3 + lgm-push.mjs + lgm-status-sync.mjs

### Bug 12 - TO_QUALIFY Sonderfall im LGM Status-Sync

- **Symptom:** Lead hat in LGM `tag = TO_QUALIFY` ("hat geantwortet aber Robin hat noch nicht qualifiziert"). Tag selbst kein Status den Attio abbilden kann.
- **Ursache:** LGM hat ZWEI Status-Felder: `tag` (spezifisch: READY_TO_BUY) und `status` (Kategorie: REPLIED, WON, LOST). Bei TO_QUALIFY ist `tag` nicht informativ - Info steckt im `status`-Feld.
- **Fix:** Sync-Logik priorisiert `tag` wenn nicht TO_QUALIFY, sonst Fallback auf `status`. Mapping: REPLIED → "Replied", WON → "Interested", LOST → "Not Interested".
- **Status:** LIVE in WF3 + lgm-status-sync.mjs

### Bug 13 - Attio Custom-Feld `telefon` statt Standard `phone_numbers`

- **Symptom:** WF2 las Telefonnummern aus `phone_numbers[0].value` und bekam immer leer zurück.
- **Ursache:** HeroSoftware nutzt Custom Text-Feld `telefon`, nicht Standard `phone_numbers`. Standard-Feld ist immer leer.
- **Fix:** Telefonnummer aus `telefon` lesen.
- **Status:** LIVE in WF2 + lgm-push.mjs

### Bug 14 - Attio People Name als zusammengesetztes Feld

- **Symptom:** WF2 las Namen aus `first_name[0].value` und bekam undefined zurück.
- **Ursache:** Attio People haben `name` als zusammengesetztes Feld mit Sub-Properties: `name[0].first_name`, `name[0].last_name`, `name[0].full_name`. Keine eigenständigen `first_name`/`last_name` Felder auf Top-Level.
- **Fix:** Namen aus `name[0].first_name` und `name[0].last_name` lesen.
- **Status:** LIVE in WF2 + lgm-push.mjs
