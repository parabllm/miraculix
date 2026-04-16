# WF1 — Mantle → Attio (n8n Cloud Webhook)

Created: 9. April 2026 11:34
Doc ID: DOC-36
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 11:34
Lifecycle: Active
Notes: WF1 = zentraler Echtzeit-Sync Mantle→Attio. 17 Nodes, Activity Notes integriert (Node 17). Match-Strategie: Shopify URL → Domain → Name → Create. 3-Versuch-Race-Condition-Handling. LIVE in n8n Cloud (http://herosoftware.app.n8n.cloud). Backup-Skript wf1-backup.mjs repliziert Logik für Disaster Recovery.
Pattern Tags: Sync, Webhook
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Stable
Stack: Attio, n8n
Verified: No

## Scope

WF1 ist der zentrale Echtzeit-Sync zwischen **Mantle** (Shopify Billing) und **Attio** (CRM). Wird durch Mantle-Webhooks getriggert und stellt sicher, dass jede Billing-Änderung eines HeroSoftware-Kunden vollständig und duplikatfrei in Attio landet. Activity Notes (ehemals separater WF6) sind direkt als Node 17 integriert — ein eigener WF6 ist nicht nötig.

WF1 ist die finale gemergte Version aller vorherigen Flow-Entwürfe.

## Architecture / Constitution

- **Trigger:** n8n Webhook (POST `/mantle-webhook`) in n8n Cloud (`herosoftware.app.n8n.cloud`)
- **17 Nodes** in einer linearen Pipeline mit 4-Wege-Match-Strategie
- **Match-Reihenfolge:** Shopify URL → Domain → Name → Create New
- **Race-Condition-Schutz:** 3-Versuch-Logik beim Create
- **Activity Notes:** in jeden Webhook-Lauf integriert (Node 17)

## Unterstützte Mantle Events

`customers/installed`, `customers/uninstalled`, `customers/subscribed`, `customers/unsubscribed`, `customers/upgraded`, `customers/downgraded`, `customers/resubscribed`, `customers/trial_expired`, `customers/deactivated`, `customers/reactivated`, `customers/refunded`, `customers/payment_failed`, u.a.

Der Webhook-Body enthält mindestens `topic` (Event-Typ), `customer.id` und `app.id`.

---

## Technischer Ablauf (Node für Node)

### Node 1 — Webhook

**Typ:** n8n Webhook  

**Methode:** POST  

**Pfad:** `/mantle-webhook`

Empfängt alle Mantle-Events. Body wird unverändert weitergereicht.

### Node 2 — Wait (15 Sekunden)

**Grund:** Mantle hat eine interne Verarbeitungsverzögerung. Direkt nach dem Webhook-Event sind die Kundendaten noch nicht vollständig via API abrufbar. 15 Sekunden Wartezeit verhindern inkonsistente Datenbeschaffung.

### Node 3 — Fetch Customer from Mantle

**Typ:** HTTP Request GET  

**URL:** `https://api.heymantle.com/v1/customers/{customer.id}`  

**Auth:** Mantle API Key (Header)  

**Retry:** 3x, 5 Sekunden zwischen Versuchen

Holt den vollständigen Kundendatensatz aus Mantle: alle `appInstallations`, Subscription-Details, Plan-Namen, Owner-Infos, Kontakte, Domain.

### Node 4 — Transform Customer Data (Code Node)

Der größte und wichtigste Node. Bereitet alle Daten für die späteren Attio-Writes vor.

**App-ID Mapping:**

```
addresshero:   8321775d-0f05-4239-a7f1-3e99dafb33b1
discounthero:  c8cd397c-3945-4c7f-9b61-a72f050cf21e
paymenthero:   e65dd559-c053-47ad-a1c4-5a9046da1693
```

**Owner-ID Mapping (Attio Workspace Members):**

```
Calvin Blick:      5a60de25-f010-4f60-81bf-8e0a03930db1
Robin Kronshagen:  e9930d23-005e-4318-b26c-c49487b39b51
```

**Plan-Normalisierung pro App:**

| App | Tier-Skala | Logik |
| --- | --- | --- |
| AddressHero | Pro Legacy (4) > Pro (3) > Lite (2) > Enterprise (1) | Substring-Match |
| PaymentHero | Ultra (5) > Premium (4) > Basic (3) > Special Free (2) > Free (1) | Exact-Match |
| DiscountHero | Enterprise / Custom | Simpel |

**`getAppPlanInfo()` — Status-Logik:**

Findet die relevanteste Installation (active > installed > churned) und gibt `{name, tier, status}` zurück.

| Status | Bedeutung |
| --- | --- |
| `active` | Aktives bezahltes Abo |
| `trial` | Aktive Trial (Enddatum in der Zukunft) |
| `trial_expired` | Trial abgelaufen, kein Abo gestartet |
| `installed` | Installiert ohne Subscription |
| `churned` | Deinstalliert oder Abo gekündigt |
| `none` | Nicht installiert |

**FIX 1 — Domain-Bereinigung:**

`.myshopify.com` Domains sind KEINE echten Custom-Domains. `match_domain` wird leer gesetzt wenn die Domain auf `.myshopify.com` endet oder leer ist. Verhindert falsche Domain-Matches in Attio.

**FIX 2 — Company Name Matching:**

`cleanCompanyName()` entfernt Rechtsformen (GmbH, AG, Ltd, Inc, UG, etc.) und Sonderzeichen vor dem Matching. Generische Namen ("My Store", "Test", "Shop") werden nicht gematcht (`name_matchable = false`). Mindestlänge: 4 Zeichen.

**Output des Nodes:**

```json
{
  "mantle_customer_id": "...",
  "shopify_domain": "shop.myshopify.com",
  "company_name": "Acme GmbH",
  "match_domain": "acme.de",
  "match_name": "Acme",
  "name_matchable": true,
  "attio_data": {
    "shopify_url": "...",
    "shopify_plan": "...",
    "mrr": 49.00,
    "commision_amount": 10,
    "commision_paid_until": "2026-12-31",
    "management_fee": true,
    "company_owner_id": "...",
    "sync": "2026-04-08"
  },
  "plan_ah": { "name": "Pro", "tier": 3, "status": "active" },
  "plan_dh": { "name": "Enterprise" },
  "plan_ph": { "name": "Ultra", "tier": 5, "status": "trial" },
  "contacts": [{ "name": "...", "email": "...", "phone": "...", "job_title": "...", "label": "primary" }]
}
```

### Node 5 — Search in Attio (by Shopify URL)

**Typ:** HTTP POST zu `/v2/objects/companies/records/query`  

**Filter:** `shopify_url.$contains: shopify_domain`

Primäre Suchstrategie: direkter Match per Shopify-URL (eindeutigster Identifier).

### Node 6 — Match gefunden? (IF)

Prüft ob `data[0].values.shopify_url` nicht leer ist (loose validation).

- **True → Update Company in Attio:** PATCH auf `records/{record_id}` mit `shopify_url`, `shopify_plan`, `mrr`, `sync`, `domains` (nur wenn echte Custom-Domain). → Merge Input 0
- **False → Search by Domain**

### Node 7 — Search by Domain

HTTP POST mit `domains.$contains: match_domain`. Wird mit leerem Placeholder (`SKIP_NO_DOMAIN_00000000`) aufgerufen wenn keine echte Domain vorhanden — garantiert kein Match.

### Node 8 — Domain Match? (IF)

`data.length > 0`

- **True → Dup-Check Domain:** Re-sucht per `shopify_url` ob das Unternehmen bereits einen `shopify_url`-Eintrag hat (= wurde schon mal via Shopify-URL gematcht).
    - **Domain ist Duplikat? (IF):**
        - True (`shopify_url` bereits vorhanden): **Skip** — wurde bereits korrekt gesetzt, kein Update nötig
        - False: **Update via Domain Match** → Merge Input 1
- **False → Search by Name**

### Node 9 — Search by Name (Code Node — FIX 2)

Breite Suche mit `name.$contains: matchName`, dann **exakter Match-Filter** (case-insensitive, bereinigt).

Gibt `{data: []}` zurück wenn `!nameMatchable`.

### Node 10 — Name Match? (IF)

`data.length == 1` UND `name_matchable == true`

- **True → Dup-Check Name → Name ist Duplikat?:**
    - True: Skip
    - False: **Update via Name Match** → Merge Input 2
- **False → Create new Company**

### Node 11 — Create new Company (Code Node, 3-Versuch-Logik)

**Versuch 1:** POST mit Domain — normaler Create-Flow.

**Versuch 2 — Race Condition Handling:** Zwischen Webhook-Empfang und Create könnte ein anderer Webhook dasselbe Unternehmen angelegt haben. Re-Suche per `shopify_url`, bei Fund: PATCH statt Create.

**Versuch 3 — Fallback POST ohne Domain:** Falls Domain-Konflikt der Grund für Versuch-1-Fehler war.

→ Merge Input 3

### Node 12 — Merge (4 Inputs)

Sammelt alle 4 Pfade (Shopify-URL-Match, Domain-Match, Name-Match, Neu-Anlage) zusammen. Wartet bis alle Inputs abgearbeitet sind.

### Node 13 — Set Extra Fields (Code Node)

Liest das Merge-Output + Transform-Daten. Berechnet Plan-Texte für Attio.

**`calcPlanText()` — Downgrade-Erkennung:**

Vergleicht den neuen Tier mit dem aktuellen Attio-Wert. Wenn alter Tier höher als neuer Tier: Suffix `(Downgraded)` wird angehängt. Logik bereinigt zuerst bestehende Suffixe wie `(Churned)`, `(Trial)` aus dem Attio-Wert (`extractBasePlan()`).

**PATCH auf Company (`/records/{id}`):**

```
adresshero_plan, discounthero_plan, paymenthero_plan,
company_owner (Workspace Member Reference),
commision_amount, management_fee, commision_paid_until
```

**Output für nächste Nodes:** `record_id`, `company_name`, `contacts`, `existing_team_ids`, `mrr`, `plans`

### Node 14 — Create People (Code Node)

Verarbeitet die `contacts` aus Transform. Für jeden Kontakt mit Email:

1. Suche in Attio People via `email_addresses.$contains`
2. Gefunden → `record_id` verwenden
3. Nicht gefunden → neuen People-Record anlegen mit: `email_addresses`, `name` (full/first/last), `phone_numbers`, `job_title`, `data_label: "Mantle"`
4. Nur neue IDs (nicht bereits in `existing_team_ids`) werden als `new_people_ids` weitergegeben

### Node 15 — Link Team (Code Node)

PATCH auf Company: `team`-Feld wird mit allen Member-IDs gesetzt (`existing_team_ids` + `new_people_ids`, dedupliziert via Set).

### Node 16 — Wait for Note

Kurze Pause vor der Note-Erstellung (sicherstellt dass der Company-Record stabil ist).

### Node 17 — Create Activity Note (Code Node)

Schreibt eine Activity Note in Attio um jeden Webhook-Event nachvollziehbar zu machen.

**App-Name-Mapping:** aus `app.id` des Webhooks

**Event-Label-Mapping:** 18 Event-Typen mit lesbaren Labels (z.B. `customers/upgraded` → "Upgraded")

**Note-Format:**

```
Titel: "AddressHero: Upgraded"
Inhalt:
  Event: customers/upgraded
  App: AddressHero
  Date: 2026-04-08
  Plan: Pro
```

Schreibt via POST `/notes` mit `parent_object: companies`, `parent_record_id`, `format: plaintext`.

---

## Attio-Felder Mapping (Vollständig)

| Attio-Feld | Quelle | Typ |
| --- | --- | --- |
| `shopify_url` | `customer.shopifyDomain` | String |
| `shopify_plan` | `customer.shopifyPlanName` | String |
| `mrr` | `customer.last30Revenue` | Currency |
| `sync` | Aktuelles Datum | Date |
| `domains` | `customer.domain` (bereinigt, kein myshopify) | Domain |
| `adresshero_plan` | Berechnet (normalizeAH + Status) | String |
| `discounthero_plan` | Berechnet (normalizeDH) | String |
| `paymenthero_plan` | Berechnet (normalizePH + Status) | String |
| `company_owner` | OWNER_MAP[[accountOwner.name](http://accountOwner.name)] | Member Ref |
| `commision_amount` | `accountOwners[0].commissionPercentage` | Number |
| `management_fee` | `accountOwners[0].hasCommission` | Boolean |
| `commision_paid_until` | `accountOwners[0].commissionEndsAt` | Date |
| `team` | Contacts (People-Records) | Relation |

---

## Match-Strategie (Diagramm)

```
Webhook Event
    │
    ▼ 15s Wait
    │
    ▼ Fetch from Mantle
    │
    ▼ Transform
    │
    ├─ Search by shopify_url ─ Match? ─ YES → Update → Merge[0]
    │                              │
    │                              NO
    │                              │
    │           Search by Domain ─ Match? ─ YES → Dup? → Update → Merge[1]
    │                                       │
    │                                       NO
    │                                       │
    │             Search by Name ─ Match? ─ YES → Dup? → Update → Merge[2]
    │                                       │
    │                                       NO
    │                                       │
    │           Create new Company (3 Versuche) → Merge[3]
    │
    ▼ Set Extra Fields (Plans, Owner, Commission)
    ▼ Create People (Contacts upsert)
    ▼ Link Team (Company ↔ People)
    ▼ Wait for Note
    ▼ Create Activity Note
```

---

## Bekannte Fixes & Designentscheidungen

| Fix | Problem | Lösung |
| --- | --- | --- |
| FIX 1 | `.myshopify.com` führte zu falschen Domain-Matches | `isMyshopifyDomain()` — `match_domain` = leer |
| FIX 2 | `$contains` bei Name-Suche gab zu viele Treffer | Exakter Post-Filter nach `cleanCompanyName()` |
| Race Condition | Parallele Webhooks für dasselbe Unternehmen | 3-Versuch-Create-Logik in `Create new Company` |
| Downgrade-Erkennung | Altes Attio-Feld hatte noch Suffix (Churned etc.) | `extractBasePlan()` bereinigt vor Tier-Vergleich |

## Edge Cases

- Wenn keine echte Domain vorhanden ist: Domain-Suche wird mit `SKIP_NO_DOMAIN_00000000` durchgeführt um leere Matches sauber zu behandeln
- Generische Firmennamen werden nicht via Name-Match gematcht (`name_matchable = false`)
- Bei parallelen Webhooks zum gleichen Customer wird in Versuch 2 nochmal per `shopify_url` gesucht und ggf. PATCH statt POST gemacht

## Open Questions

- Aktuell keine offenen Fragen — Workflow ist LIVE und stabil