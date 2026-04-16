# n8n Debug & Fix Tracker

Created: 9. April 2026 12:05
Doc ID: DOC-44
Doc Type: Reference
Gelöscht: No
Last Edited: 9. April 2026 12:05
Lifecycle: Active
Notes: Lebender Bug-Tracker für alle n8n-Probleme im HeroSoftware-Kontext. Komplement zum hero-n8n Skill: Skill hält statische Workflow-Specs, Doc hält gelernte Bugs + Fixes. 14 Initial-Bugs aus dem alten n8n-workflows Skill extrahiert. Bei wiederkehrenden Patterns: in den hero-n8n Skill als statische Regel übernehmen.
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Volatile
Stack: n8n
Verified: No

## Anweisung an Claude (zuerst lesen!)

Dieses Doc ist ein **lebender Bug-Tracker** für alle n8n-Probleme die im HeroSoftware-Kontext auftreten. Es ist das externe Gedächtnis für alles was im `hero-n8n` Skill nicht statisch dokumentiert ist.

**Bei jedem neuen Bug:** Eintrag in der Tabelle unten hinzufügen mit Symptom, Ursache, Fix, Datum.

**Bei jedem Fix der nicht funktioniert:** Eintrag aktualisieren mit der neuen Erkenntnis. Alte Lösungen nicht löschen — als "überholt" markieren und neue darunter hängen.

**Bei wiederkehrenden Bugs:** Wenn ein Pattern dreimal aufgetaucht ist, in den `hero-n8n` Skill als statische Regel übernehmen und hier mit "→ jetzt im Skill" markieren.

**Bei generischen n8n Bugs (nicht HS-spezifisch):** Direkt in den `n8n` Skill schreiben, nicht hier.

## Scope

Nur n8n-Probleme. Hetzner-Skript-Bugs, Clay-Tabellen-Probleme, Attio-API-Caveats gehören NICHT hier rein — die haben eigene Sammlungs-Orte (oder kommen später dazu wenn der Test mit n8n erfolgreich ist).

## Architecture / Constitution

- **Kontext:** HeroSoftware n8n Workflows (`herosoftware.app.n8n.cloud`)
- **Workflows die hier abgedeckt sind:** WF1 (Mantle→Attio Webhook), WF4 (Reverse Lookup), WF6 (Activity Notes — ist Node 17 in WF1), WF2 (Attio→LGM Push, n8n Backup), WF3 (LGM→Attio Status, n8n Backup)
- **Live-Specs:** in den jeweiligen Workflow-Docs unter dem HeroSoftware Project (Skript-Specs sind separat)
- **Komplement zum `hero-n8n` Skill:** Der Skill hält die statischen Specs ("so ist es designt"), dieses Doc hält die gelernten Bugs ("das haben wir zwischenzeitlich repariert")

---

## Bekannte Bugs & Fixes

### Bug 01 — Race Condition bei parallelen Mantle Webhooks

- **Datum entdeckt:** Session 6 (vor Migration)
- **Symptom:** Mantle feuert bei neuer Installation mehrere Events fast gleichzeitig (`installed` + `subscribed` innerhalb weniger Sekunden). Beide n8n Executions laufen parallel, beide suchen Attio, beide finden nichts, beide versuchen Create → zweite crasht mit Domain Uniqueness Conflict.
- **Ursache:** Mantle hat keine eingebaute Webhook-Serialisierung pro Customer. n8n Cloud Executions sind unabhängig.
- **Fix:** Zwei-Stufen-Schutz in WF1:
    1. **Wait Node 15 Sekunden** nach dem Webhook (gibt erster Execution Vorsprung, behandelt auch Mantle API Propagation Delay)
    2. **Create New Company als Code Node** mit 3-Versuch-Conflict-Retry: (a) Create mit Domain, (b) bei Conflict Re-Search per shopify_url + PATCH statt POST, (c) Fallback Create ohne Domain
- **Status:** ✅ Fix LIVE in WF1

### Bug 02 — Search by Name als HTTP Request Node liefert zu viele Treffer

- **Datum entdeckt:** Session 6
- **Symptom:** Attio `$contains` macht Substring-Matching, nicht Exact-Match. "CK Store" matcht auch "TopPick Store" (weil "ck Store" Substring ist). HTTP Request Node kann das nicht nachfiltern → Name Match wird FALSE obwohl ein exakter Treffer dabei wäre.
- **Ursache:** HTTP Request Node liefert die rohe API-Response ohne lokale Filterung.
- **Fix:** Search by Name als **Code Node** mit `helpers.httpRequest` umbauen, der die `$contains`-Suche macht und danach lokal exakt filtert mit `cleanCompanyName().toLowerCase() === matchName.toLowerCase()`. Nur wenn genau 1 exakter Treffer + `name_matchable = true` → Match.
- **Status:** ✅ Fix LIVE in WF1

### Bug 03 — Mantle 404 bei sofortigem Fetch nach Webhook

- **Datum entdeckt:** Session 6
- **Symptom:** `GET /v1/customers/{id}` kann 404 geben selbst 15+ Sekunden nach dem Webhook. Manchmal existiert der Kunde tatsächlich (per manuellem cURL erreichbar), aber die n8n Execution bekommt 404.
- **Ursache:** API-Propagation-Delay bei Mantle, nicht immer Timing-bedingt.
- **Fix:** **Retry on Fail** auf der HTTP Request Node aktivieren: 3x mit 5s Pause zwischen Versuchen.
- **Status:** ✅ Fix LIVE in WF1 Node 3

### Bug 04 — Node-Referenz kaputt nach Delete + Recreate

- **Datum entdeckt:** Session 6
- **Symptom:** Wenn eine HTTP Request Node gelöscht und durch eine Code Node mit gleichem Namen ersetzt wird, behalten nachfolgende Nodes manchmal eine kaputte `$()` Referenz. Beispiel: `$('Search by Name').item.json.data[0].id.record_id` wird zu `$('1').item...` nach dem Austausch.
- **Ursache:** n8n speichert intern eine Node-ID und der Display-Name ist nur ein Alias. Beim Delete+Recreate wird die ID neu vergeben aber alte Referenzen aktualisieren sich nicht.
- **Fix:** Nach jedem Node-Austausch ALLE nachfolgenden Nodes öffnen und alle `$()` Referenzen prüfen die den alten Node-Namen verwenden — in URL-Expressions, JSON Body Expressions, Code Node Aufrufen.
- **Status:** ⚠️ Kein automatischer Schutz, nur manuelles Prüfen. Wenn das nochmal passiert: überlegen ob ein Linter-Skript möglich ist.

### Bug 05 — [myshopify.com](http://myshopify.com) Domain-Filter fehlte und führte zu falschen Domain-Matches

- **Datum entdeckt:** Session 6
- **Symptom:** WF1 hat `customer.domain` direkt in den Domain-Match geschickt. Wenn Mantle eine `xyz.myshopify.com` Domain liefert (kommt vor), matcht die Suche in Attio falsch oder crasht beim Create wegen Domain Uniqueness Conflict (verschiedene Companies haben technische [myshopify.com](http://myshopify.com) Subdomains).
- **Ursache:** Mantle `domain` Feld ist unzuverlässig: kann null sein, kann echte Custom-Domain sein, kann [myshopify.com](http://myshopify.com) URL sein.
- **Fix:** `isMyshopifyDomain()` Helper im Transform Node. Wenn Domain auf `.myshopify.com` endet ODER leer ist → `match_domain = ""`. Search by Domain wird dann mit Fallback-String `SKIP_NO_DOMAIN_00000000` aufgerufen → garantiert kein Match. Create New setzt `domains: []` → kein Uniqueness-Conflict.
- **Status:** ✅ Fix LIVE in WF1 Transform Node

### Bug 06 — Generische Firmennamen werden gematcht und linken auf falsche Companies

- **Datum entdeckt:** Session 4-6
- **Symptom:** Mantle hat 90+ Customers mit Namen "Mein Shop", 125+ mit "My Store", einige mit "Test", "Shop". Diese Namen matchten in Attio auf jeweils zufällige andere Companies.
- **Ursache:** Name-Matching ist ohne Blacklist nicht zuverlässig wenn der Name selbst generisch ist.
- **Fix:** `cleanCompanyName()` Funktion + `name_matchable` Flag im Transform Node:
    - Entfernt Rechtsformen (GmbH, AG, Ltd, Inc, UG, e.K., OHG, KG, SE, Co., Corp, LLC, S.L., B.V., Pty, Pvt, S.A.S., S.r.l.)
    - Entfernt Sonderzeichen ™ ® © | · — _
    - Mindestlänge: 4 Zeichen nach Bereinigung
    - Generische Namen Blacklist: "Mein Shop", "My Store", "Test", "Shop" → `name_matchable = false`
- **Status:** ✅ Fix LIVE in WF1 Transform Node + Search by Name Code Node

### Bug 07 — LGM API: Feld heißt `audience` nicht `audienceId`

- **Datum entdeckt:** Session während WF2 Bau
- **Symptom:** `POST /flow/leads` mit `audienceId` im Body → LGM ignoriert das Feld, Lead wird ohne Audience-Zuordnung erstellt oder schlägt fehl.
- **Ursache:** LGM API Doku ist an dieser Stelle missverständlich.
- **Fix:** Body-Feld muss `audience` heißen, nicht `audienceId`.
- **Status:** ✅ Fix LIVE in WF2 + lgm-push.mjs

### Bug 08 — LGM API: KEIN `identity` Feld im Lead-Body

- **Datum entdeckt:** Session während WF2 Bau
- **Symptom:** `POST /flow/leads` mit `identity` Feld im Body → 404 Error "body.identity is not allowed"
- **Ursache:** `identity` ist ein Sequence-Setting, kein Lead-Feld. LGM lehnt das im Lead-Body ab.
- **Fix:** `identity` Feld komplett aus dem Lead-Body weglassen.
- **Status:** ✅ Fix LIVE in WF2 + lgm-push.mjs

### Bug 09 — LGM API: max `limit=100`, Pagination via `skip`

- **Datum entdeckt:** Session während WF3 Bau
- **Symptom:** `GET /flow/audiences/{id}/leads?limit=500` ignoriert `limit` und gibt nur 100 Leads zurück.
- **Ursache:** LGM API Hard-Limit auf 100 pro Request, Pagination muss via `skip` Parameter erfolgen.
- **Fix:** Code Node holt Leads in 100er-Chunks: `limit=100&skip=0`, dann `skip=100`, `skip=200`, etc. bis weniger als 100 zurückkommen.
- **Status:** ✅ Fix LIVE in WF3 + lgm-status-sync.mjs

### Bug 10 — LGM Audiences API Response-Format

- **Datum entdeckt:** Session während WF3 Bau
- **Symptom:** Code Node erwartet `response.data` als Array, bekommt aber `response.audiences`. Result: leeres Array, keine Leads gepollt.
- **Ursache:** `GET /audiences` gibt `{ statusCode: 200, audiences: [...] }` zurück, NICHT das übliche `{ data: [...] }` Format.
- **Fix:** Response-Parser muss `res.audiences` lesen, nicht `res.data`.
- **Status:** ✅ Fix LIVE in WF3 + lgm-status-sync.mjs

### Bug 11 — Attio Select-Felder Case-Sensitivity

- **Datum entdeckt:** Session während WF2 Bau
- **Symptom:** PATCH auf `sequence_status` mit `"Ready To Buy"` (großes "To") führt entweder zu Fehler oder Attio erstellt eine NEUE Select-Option mit dem falschen Casing.
- **Ursache:** Attio Select-Optionen sind case-sensitive. Existierende Option ist exakt `"Ready to Buy"` (kleines "to").
- **Fix:** Immer die exakten Option-Titel verwenden:
    - `"Ready to Buy"` (NICHT `"Ready To Buy"`)
    - `"Out of Office"` (NICHT `"Out Of Office"`)
    - `"Completed: No Reply"` (mit Doppelpunkt)
- **Status:** ✅ Fix LIVE in WF2 + WF3 + lgm-push.mjs + lgm-status-sync.mjs

### Bug 12 — TO_QUALIFY Sonderfall im LGM Status-Sync

- **Datum entdeckt:** Session während WF3 Bau
- **Symptom:** Lead hat im LGM `tag = TO_QUALIFY` was bedeutet "hat geantwortet aber Robin hat noch nicht qualifiziert". Der Tag selbst ist kein Status den Attio abbilden kann.
- **Ursache:** LGM hat ZWEI Status-Felder pro Lead: `tag` (spezifische Qualifizierung wie READY_TO_BUY) und `status` (Kategorie wie REPLIED, WON, LOST). Bei TO_QUALIFY ist das `tag` nicht informativ — die echte Info steckt im `status`-Feld.
- **Fix:** Sync-Logik priorisiert `tag` wenn er nicht TO_QUALIFY ist, sonst Fallback auf `status`-Feld. Mapping: `REPLIED → "Replied"`, `WON → "Interested"`, `LOST → "Not Interested"`.
- **Status:** ✅ Fix LIVE in WF3 + lgm-status-sync.mjs

### Bug 13 — Attio Custom-Feld `telefon` statt Standard `phone_numbers`

- **Datum entdeckt:** Session während WF2 Bau
- **Symptom:** WF2 las Telefonnummern aus `phone_numbers[0].value` und bekam immer leer zurück.
- **Ursache:** HeroSoftware nutzt ein Custom Text-Feld `telefon` für die Telefonnummern, nicht das Standard `phone_numbers` Feld. Das Standard-Feld ist immer leer.
- **Fix:** Telefonnummer aus `telefon` lesen, nicht aus `phone_numbers`.
- **Status:** ✅ Fix LIVE in WF2 + lgm-push.mjs

### Bug 14 — Attio People Name als zusammengesetztes Feld

- **Datum entdeckt:** Session während WF2 Bau
- **Symptom:** WF2 las Namen aus `first_name[0].value` und bekam undefined zurück.
- **Ursache:** Attio People haben `name` als zusammengesetztes Feld mit Sub-Properties: `name[0].first_name`, `name[0].last_name`, `name[0].full_name`. Es gibt keine eigenständigen `first_name` und `last_name` Felder auf Top-Level.
- **Fix:** Namen aus `name[0].first_name` und `name[0].last_name` lesen.
- **Status:** ✅ Fix LIVE in WF2 + lgm-push.mjs

---

## Überholte Fixes (zur Historie behalten)

*Hier landen Fixes die durch eine bessere Lösung ersetzt wurden. Aktuell keine.*

---

## Open Investigations

*Bugs die noch nicht reproduziert oder noch nicht gefixt sind. Aktuell keine.*

---

## Änderungs-Log

- **2026-04-09:** Initial-Erstellung mit 14 bekannten Bugs aus dem alten n8n-workflows Skill extrahiert. Alle Fixes sind LIVE in WF1, WF2, WF3 oder den jeweiligen Hetzner-Skripten.