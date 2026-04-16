---
typ: aufgabe
name: "WF1 - Mantle → Attio (n8n Cloud Webhook)"
projekt: "[[herosoftware]]"
status: erledigt
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[robin-kronshagen]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

WF1 = zentraler Echtzeit-Sync Mantle→Attio. 17 Nodes, Activity Notes integriert in Node 17. LIVE in n8n Cloud (`herosoftware.app.n8n.cloud`). Finale gemergte Version aller vorherigen Flow-Entwürfe. Stand 2026-04-09.

## Architektur

- **Trigger:** n8n Webhook (POST `/mantle-webhook`) in n8n Cloud
- **17 Nodes** in linearer Pipeline mit 4-Wege-Match-Strategie
- **Match-Reihenfolge:** Shopify URL → Domain → Name → Create New
- **Race-Condition-Schutz:** 3-Versuch-Logik beim Create
- **Activity Notes:** in jeden Webhook-Lauf integriert (Node 17) - eigener WF6 nicht nötig

## Unterstützte Mantle Events

`customers/installed`, `customers/uninstalled`, `customers/subscribed`, `customers/unsubscribed`, `customers/upgraded`, `customers/downgraded`, `customers/resubscribed`, `customers/trial_expired`, `customers/deactivated`, `customers/reactivated`, `customers/refunded`, `customers/payment_failed`, u.a.

Webhook-Body enthält mindestens `topic`, `customer.id`, `app.id`.

## Technischer Ablauf

### Node 1 - Webhook
n8n Webhook, POST `/mantle-webhook`. Body unverändert weitergereicht.

### Node 2 - Wait (15 Sekunden)
Mantle hat interne Verarbeitungsverzögerung. Direkt nach Webhook sind Kundendaten noch nicht vollständig via API abrufbar. 15s Wartezeit verhindern inkonsistente Datenbeschaffung.

### Node 3 - Fetch Customer from Mantle
HTTP GET `https://api.heymantle.com/v1/customers/{customer.id}` mit Mantle API Key (Header). Retry: 3x, 5s zwischen Versuchen. Holt vollständigen Kundendatensatz: alle `appInstallations`, Subscription, Plan-Namen, Owner, Kontakte, Domain.

### Node 4 - Transform Customer Data (Code Node)
Der größte und wichtigste Node.

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
|---|---|---|
| AddressHero | Pro Legacy (4) > Pro (3) > Lite (2) > Enterprise (1) | Substring-Match |
| PaymentHero | Ultra (5) > Premium (4) > Basic (3) > Special Free (2) > Free (1) | Exact-Match |
| DiscountHero | Enterprise / Custom | Simpel |

**`getAppPlanInfo()` Status-Logik:** Findet relevanteste Installation (active > installed > churned), gibt `{name, tier, status}` zurück.

| Status | Bedeutung |
|---|---|
| active | Aktives bezahltes Abo |
| trial | Aktive Trial (Enddatum in Zukunft) |
| trial_expired | Trial abgelaufen, kein Abo gestartet |
| installed | Installiert ohne Subscription |
| churned | Deinstalliert oder Abo gekündigt |
| none | Nicht installiert |

**FIX 1 - Domain-Bereinigung:** `.myshopify.com` ist keine echte Custom-Domain. `match_domain` wird leer gesetzt wenn Domain auf `.myshopify.com` endet oder leer ist. Verhindert falsche Domain-Matches.

**FIX 2 - Company Name Matching:** `cleanCompanyName()` entfernt Rechtsformen (GmbH, AG, Ltd, Inc, UG etc.) und Sonderzeichen. Generische Namen ("My Store", "Test", "Shop") werden nicht gematcht (`name_matchable = false`). Mindestlänge: 4 Zeichen.

### Nodes 5-11 - Match-Pipeline

- **Node 5:** Search by Shopify URL (POST `/v2/objects/companies/records/query`, Filter `shopify_url.$contains`)
- **Node 6:** Match gefunden? (IF) - TRUE → Update + Merge[0], FALSE → Search by Domain
- **Node 7:** Search by Domain (mit Placeholder `SKIP_NO_DOMAIN_00000000` wenn keine echte Domain)
- **Node 8:** Domain Match? → Dup-Check → Update + Merge[1] oder Search by Name
- **Node 9:** Search by Name (Code Node, FIX 2 mit exaktem Post-Filter)
- **Node 10:** Name Match? (`data.length == 1` UND `name_matchable`) → Update + Merge[2] oder Create
- **Node 11:** Create new Company (3-Versuch-Logik):
  - Versuch 1: POST mit Domain
  - Versuch 2: Race Condition Handling - Re-Suche per `shopify_url`, bei Fund PATCH statt Create
  - Versuch 3: Fallback POST ohne Domain

### Node 12 - Merge (4 Inputs)
Sammelt alle 4 Pfade (Shopify-URL/Domain/Name/Create). Wartet bis alle abgearbeitet sind.

### Node 13 - Set Extra Fields (Code Node)

**`calcPlanText()` Downgrade-Erkennung:** Vergleicht neuen Tier mit Attio-Wert. Alter Tier höher → Suffix `(Downgraded)`. `extractBasePlan()` bereinigt bestehende Suffixe (`(Churned)`, `(Trial)`) vor Tier-Vergleich.

PATCH: `adresshero_plan`, `discounthero_plan`, `paymenthero_plan`, `company_owner` (Member Ref), `commision_amount`, `management_fee`, `commision_paid_until`.

### Node 14 - Create People
Für jeden Kontakt mit Email: Suche in Attio People (`email_addresses.$contains`) → gefunden: record_id verwenden / nicht gefunden: neuen People-Record (Email, Name, Phone, job_title, `data_label: "Mantle"`).

### Node 15 - Link Team
PATCH Company `team`-Feld mit allen Member-IDs (existing + new, dedupliziert via Set).

### Node 16 - Wait for Note
Kurze Pause vor Note-Erstellung (Company-Record stabil).

### Node 17 - Create Activity Note
Schreibt Activity Note pro Webhook-Event.

- **Event-Label-Mapping:** 18 Event-Typen mit lesbaren Labels
- **Format:** Titel `"AddressHero: Upgraded"`, Inhalt mit Event/App/Date/Plan
- POST `/notes` mit `parent_object: companies`, `parent_record_id`, `format: plaintext`

## Attio-Felder Mapping

| Attio-Feld | Quelle | Typ |
|---|---|---|
| shopify_url | `customer.shopifyDomain` | String |
| shopify_plan | `customer.shopifyPlanName` | String |
| mrr | `customer.last30Revenue` | Currency |
| sync | Aktuelles Datum | Date |
| domains | `customer.domain` (bereinigt, kein myshopify) | Domain |
| adresshero_plan | Berechnet (normalizeAH + Status) | String |
| discounthero_plan | Berechnet (normalizeDH) | String |
| paymenthero_plan | Berechnet (normalizePH + Status) | String |
| company_owner | OWNER_MAP[accountOwner.name] | Member Ref |
| commision_amount | `accountOwners[0].commissionPercentage` | Number |
| management_fee | `accountOwners[0].hasCommission` | Boolean |
| commision_paid_until | `accountOwners[0].commissionEndsAt` | Date |
| team | Contacts (People-Records) | Relation |

## Match-Strategie

```
Webhook Event → 15s Wait → Fetch from Mantle → Transform
    │
    ├─ Search by shopify_url ─ Match? ─ YES → Update → Merge[0]
    │                              │ NO
    │           Search by Domain ─ Match? ─ YES → Dup? → Update → Merge[1]
    │                                       │ NO
    │             Search by Name ─ Match? ─ YES → Dup? → Update → Merge[2]
    │                                       │ NO
    │           Create new Company (3 Versuche) → Merge[3]
    │
    ▼ Set Extra Fields (Plans, Owner, Commission)
    ▼ Create People (Contacts upsert)
    ▼ Link Team (Company ↔ People)
    ▼ Wait for Note
    ▼ Create Activity Note
```

## Fixes & Designentscheidungen

| Fix | Problem | Lösung |
|---|---|---|
| FIX 1 | `.myshopify.com` führte zu falschen Domain-Matches | `isMyshopifyDomain()` - `match_domain = leer` |
| FIX 2 | `$contains` bei Name-Suche gab zu viele Treffer | Exakter Post-Filter nach `cleanCompanyName()` |
| Race Condition | Parallele Webhooks für selbe Company | 3-Versuch-Create-Logik |
| Downgrade-Erkennung | Altes Attio-Feld hatte Suffix | `extractBasePlan()` bereinigt vor Tier-Vergleich |

## Edge Cases

- Keine echte Domain: Domain-Suche mit `SKIP_NO_DOMAIN_00000000`
- Generische Firmennamen: `name_matchable = false`, kein Name-Match
- Parallele Webhooks zum selben Customer: Versuch 2 re-sucht per `shopify_url`, PATCH statt POST
