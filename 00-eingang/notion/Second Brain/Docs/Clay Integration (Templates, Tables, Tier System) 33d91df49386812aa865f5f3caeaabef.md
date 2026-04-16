# Clay Integration (Templates, Tables, Tier System)

Created: 9. April 2026 11:34
Doc ID: DOC-41
Doc Type: Reference
Gelöscht: No
Last Edited: 9. April 2026 11:34
Lifecycle: Active
Notes: Clay Integration komplett: Architektur, Templates, 4-Layer LinkedIn Waterfall, 3-Layer Email (Apollo Hauptquelle), 2-Layer Phone (nur DE), Decision Maker Tier System (3 Tiers), Attio Push Logik, Lead Quality System, Company Table 46 Spalten, Person Table 27 Spalten, Coverage Stats. Pro Attio-Liste eigenes Template. 2 Templates live. Spaltenlimit 48.
Pattern Tags: Enrichment
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Stable
Stack: Attio, Clay
Verified: No

## Scope

Clay wird für HeroSoftware als Enrichment-Layer eingesetzt. Aus Attio-Listen (z.B. Churns, High-Value, Cold Outreach) findet Clay Entscheider-Kontakte, qualifiziert sie nach einem 3-Tier-Modell und reichert sie mit Email + Phone an. Die enrichten Daten fließen über Clays native Attio-Integration zurück ins CRM.

Im Gegensatz zu WF1 / den Hetzner-Skripten ist Clay **kein Code-System** — es ist eine konfigurierte Tabellen-Pipeline in Clay selbst. Diese Doku beschreibt Architektur, Templates, Spalten und Regeln.

## Architecture / Constitution

- **2 Templates live** (Stand: Backfill abgeschlossen, läuft auf Auto-Sync)
- **Pro Attio-Liste ein eigenes Clay-Template** (gleiche Struktur, andere Source)
- **48-Spalten-Limit** in Clay-Tables (Ressourcen-Constraint)
- **Decision Maker Tier System** (3 Tiers, GPT-4/Claude-basiert)
- **Doppel-Enrichment-Schutz** via `enriched_by_clay` Checkbox
- **Phone-Enrichment NUR bei `Language = DE`** (Credit-Schutz)

## Standard Workflow

```
Attio Liste importieren (Source, Auto-Sync täglich)
  → Company Table
    → LinkedIn URL Waterfall (Claygent → Apollo → Deep Search → Constructor)
    → Language Detection (Claygent, Website-basiert)
    → Find People at Companies (Source → Person Table)
      → Decision Maker Tier (Claygent GPT-4/Claude)
      → Filter (Tier 1+2 behalten, Tier 3 raus)
      → Email (BetterContact + Apollo Waterfall)
      → Phone (BetterContact, NUR DE)
      → Konsolidierung (Email Final, Phone Final)
      → LinkedIn Clean (trailing slash entfernen)
      → Attio Push (Upsert Mail → Lookup LinkedIn → Create/Update)
    → [Delay 10 Min] Attio Lookup (Team = leer?)
    → [Delay 15 Min] Claygent People Finder (nur Companies ohne Team)
      → P1/P2/P3 Formula-Spalten (max 3 Personen)
      → P1/P2/P3 BetterContact Email + Phone (nur DE)
      → P1/P2/P3 Attio Upsert (Run Condition: Email vorhanden)
```

**Sequenzierung:** Attio Lookup hat 10 Min Delay, Claygent 15 Min Delay. So läuft Find People + Attio Push zuerst. Falls Overlap: Attio Upsert deduped automatisch über Email-Match.

**Spaltenlimit:** 48 Spalten max in Clay. Daher kein Apollo Fallback in der Company Table (spart Spalten). Kein LinkedIn-Fallback für Attio Push (nur Upsert per Email).

---

## Templates (Live)

### Template 1 — Executive Leadership, Digital & Ownership

- **Source:** Attio Liste "Executive Leadership, Digital, E-Commerce, Ownership"
- **Status:** Fertig — Company Enrichment + Person Table + Attio Push

### Template 2 — Churns & Reactivation

- **Source:** Attio Liste (98 Companies)
- **Status:** Fertig — Company Enrichment + Claygent People Finder + P1/P2/P3 Extraktion + BetterContact Email/Phone + Attio Upsert. Auto-Sync läuft.

---

## Enrichment Waterfalls

### LinkedIn Company URL (4-Layer)

1. Claygent (Website + Google) → Primary
2. Apollo Enrich Company → Fallback
3. Claygent Deep Search (Google aggressiv) → Fallback 2
4. Claygent URL Constructor (raten + verifizieren) → letzter Fallback

→ Konsolidiert in `LinkedIn URL (Final)`

### Email (3-Layer)

1. BetterContact → Find Work Email
2. Apollo → Find Email
3. Claygent Email Finder (LinkedIn + Website + Google)

→ Konsolidiert in `Email (Final)`

### Phone (2-Layer) — NUR bei `Language = DE`

1. BetterContact → Find Mobile Phone
2. Clay Waterfall Mobile Phone Enrichment

→ Konsolidiert in `Phone (Final)`

**Run Condition:** `Language = DE` (spart Credits, nur deutsche Nummern relevant)

---

## Decision Maker Tier System

3-Tier-Modell, Claygent mit GPT-4/Claude besucht LinkedIn-Profile.

### Tier 1 — ENTSCHEIDER (Robin kontaktiert sofort)

Owner, Founder, CEO, Geschäftsführer, CTO, Head of E-Commerce, Prokurist, Vorstand, Managing Director, COO, E-Commerce Manager, Shop Manager, Head of Operations, Head of Digital

### Tier 2 — GRENZFALL (Robin entscheidet manuell)

Marketing Manager, Product Manager, IT Manager, Tech Lead, Head of Sales, CRM Manager, Senior Developer

### Tier 3 — NICHT RELEVANT (automatisch rausgefiltert)

Store Manager, Filialleiter, Intern, Werkstudent, HR, Recruiter, Sales Rep, Designer, Customer Support, Warehouse

### Special Rules

- **Investor + Founder = Tier 1**
- **Store/Branch Manager = IMMER Tier 3**
- **Kleine Companies (<50 MA):** im Zweifel upgraden

---

## Attio Push — Matching-Logik

```
Email vorhanden:
  → Upsert Record Mail (erstellt oder updated automatisch)
    → Company Record ID mitmappen

Keine Email:
  → Lookup Records LinkedIn (LinkedIn Clean ohne trailing Slash!)
    → Gefunden → Update Record
    → Nicht gefunden → Create Record
```

### Bekannte Probleme

- **Attio Upsert People:** Matching NUR über Email möglich
- **LinkedIn URL:** Clay hat trailing Slash, Attio nicht → Formula "LinkedIn Clean"
- **Phone Numbers:** Attio erwartet Array → separater Update Step mit "Append"
- **Company-Feld:** Erwartet UUID, nicht Company-Name

---

## Language Detection

**Company Table (Claygent, 3 Credits):** Besucht die Website und prüft Sprache + Domain TLD + Firmenname (GmbH etc.). Genauer als reine Domain-Prüfung — erkennt auch `.com` Shops die auf Deutsch sind.

**Person Table (AI Formula, 1 Credit):** Location-basiert (DACH = DE, sonst EN). Erkennt auch Städte.

**Attio-Feld:** `Contact Language` (Select: DE, EN)

---

## Claygent People Finder (für Companies ohne Kontakte)

Sucht auf LinkedIn People Tab + Website (Impressum, Team, About) + Google.

- Gibt bis zu 3 Personen als JSON Array zurück
- Nur Tier 1 Titel
- Output: `{"people": [{"first_name", "last_name", "title", "linkedin"}]}`
- **Run Condition:** Attio People Lookup = "No records found"

---

## Lead Quality System (4 Stufen)

| Quality | Daten | LGM Sequence? |
| --- | --- | --- |
| Priority | Email + Phone + LinkedIn | Ja (alle 3 Kanäle) |
| Standard | Email + LinkedIn | Ja (Email + LinkedIn) |
| Basic | Nur Email | Ja (nur Email) |
| Low | Nur LinkedIn | Nein |

Lead Quality wird in Clay als Formula berechnet und beim Attio Upsert mitgegeben. Low wird bei LinkedIn-only Create-Records gesetzt.

## Ready for Sequence Logik

Company ist ready wenn: `enriched_by_clay = true` ODER `manually_enriched = true`

`lgm-push.mjs` holt dann ALLE People der Company (egal ob Clay/Mantle/manuell).

---

## Attio-Attribute (alle angelegt)

**Company:**

- `enriched_by_clay` (Checkbox, Clay setzt automatisch)
- `manually_enriched` (Checkbox, Robin setzt manuell)
- `outbound_status_2` (Select)

**People:**

- `contact_language` (Select: DE/EN)
- `sequence_status` (Select)
- `contacted_at` (Date)
- `lgm_sequence` (Text)
- `lead_quality` (Select: Priority/Standard/Basic/Low)

---

## Table-Struktur & Spalten

### Company Table (46/48 Spalten)

| # | Spalte | Typ | Funktion |
| --- | --- | --- | --- |
| 1 | Import records from Attio lists | Source | Attio Daten |
| 2 | Lookup Records | Attio Enrichment | Company Lookup |
| 3 | Parent Record Id | Formula | Company UUID |
| 4 | Company Domain | Text | Domain |
| 5 | Company Name | Text | Firmenname |
| 6 | LinkedIn URL | Text | Konsolidiert |
| 7 | Update People Search | Source | Find People Status |
| 8 | Company Name Exists | Formula | Check |
| 9 | Lookup Records (2) | Attio Enrichment | Team Lookup |
| 10 | Team Has Entry | Formula | true/false |
| 11 | Contact Language | Claygent | DE/EN |
| 12 | Shopify App Decision Makers | Claygent | JSON Array |
| 13-16 | First/Last Name P1, Title P1, Linkedin P1 | Formula | Person 1 |
| 17-20 | First/Last Name P2, Title P2, Linkedin P2 | Formula | Person 2 |
| 21-24 | First/Last Name P3, Title P3, Linkedin P3 | Formula | Person 3 |
| 25-27 | LinkedIn URL Cleaned P1/P2/P3 | Formula | Trailing Slash |
| 28-30 | Full Name P1/P2/P3 | Formula | Kombiniert |
| 31-33 | Find work email P1/P2/P3 | BetterContact | Email |
| 34-36 | Find mobile phone / (2) / P3 | BetterContact | Phone |
| 37-38 | Contact Email/Phone Data | BC Output | (evtl. löschen) |
| 39-41 | Email P1/P2/P3 | Formula | Konsolidiert |
| 42-44 | Upsert Record / (2) / (3) | Attio | Push |

### Person Table (27 Spalten)

| # | Spalte | Typ | Funktion |
| --- | --- | --- | --- |
| 1 | Executive Leadership... | Source | Find People |
| 2 | Company Table Data | Reference | Link zu Company |
| 3-5 | First/Last/Full Name | Text | Name |
| 6 | Job Title | Text | Titel |
| 7 | Location | Text | Standort |
| 8 | Company Domain | URL | Domain |
| 9 | LinkedIn Profile | URL | Person LinkedIn |
| 10 | Is Tier 1 | Formula | true/false |
| 11 | Find work email | BetterContact | BC Email |
| 12 | Contact Email Address - Data | BC Output | (Duplikat?) |
| 13 | Find mobile phone | BetterContact | BC Phone |
| 14 | Contact Phone Number - Data | BC Output | (Duplikat?) |
| 15 | Enrich person | Apollo | Apollo |
| 16 | Email - Person | Apollo | Apollo Email |
| 17 | Sanitized Phone | Apollo | Apollo Phone |
| 18 | Mobile Phone | Formula | Konsolidierung |
| 19 | Primary Email | Formula | Final Email |
| 20 | Primary Phone Number | Formula | Final Phone |
| 21 | Language Code | AI Formula | DE/EN |
| 22 | Upsert Record | Attio | Email Push |
| 23 | Lookup Records | Attio | LinkedIn Lookup |
| 24 | Create Record | Attio | LinkedIn Create |
| 25 | Update Record | Attio | LinkedIn Update |

### Coverage-Statistik (Person Table, Stand Initial-Lauf)

**359 Personen:**

- Tier 1: 202 (56%)
- Email: 165/202 (82% der Tier 1) — BetterContact: 17, Apollo: 150 (Apollo ist Hauptquelle!)
- Phone: 95/202 (47%)
- Language: 187 DE, 172 EN (100%)
- Attio Push: 163 (160 Upsert + 3 Update)

### Coverage Company Table Claygent Fallback (33 Companies ohne Team)

- P1 gefunden: 26/33
- P1 Email: 5/26 (19% — nur BetterContact, kein Apollo wegen Spaltenlimit)
- Attio Push: 5

## Key Learning

**Apollo >> BetterContact für Email.** In der Person Table hat Apollo 150 Emails gefunden vs BetterContact nur 17. Apollo ist die Hauptquelle für Email-Enrichment. In der Company Table fehlt Apollo wegen Spaltenlimit — daher dort nur 19% Email-Coverage.

## Spalten-Umbenennung (Vorschläge — nicht umgesetzt)

### Company Table

| Aktuell | Vorschlag |
| --- | --- |
| Lookup Records | Attio Company Lookup |
| Lookup Records (2) | Attio Team Lookup |
| Contact Email Address - Data | löschen |
| Contact Phone Number - Data | löschen |
| Find mobile phone | Phone P1 (BC) |
| Find mobile phone (2) | Phone P2 (BC) |
| Find mobile phone P3 | Phone P3 (BC) |
| Find work email P1/P2/P3 | Email P1/P2/P3 (BC) |
| Upsert Record / (2) / (3) | Attio Upsert P1/P2/P3 |
| Shopify App Decision Makers | Claygent People Finder |
| Company Name Exists | (prüfen ob nötig) |

### Person Table

| Aktuell | Vorschlag |
| --- | --- |
| Contact Email Address - Data | löschen (BC Duplikat) |
| Contact Phone Number - Data | löschen (BC Duplikat) |
| Sanitized Phone - Contact - Person | Phone (Apollo) |
| Email - Person | Email (Apollo) |
| Enrich person | Apollo Enrich |
| Find work email | Email (BC) |
| Find mobile phone | Phone (BC) |
| Is Tier 1 | Tier Filter |
| Upsert Record | Attio Upsert (Email) |
| Lookup Records | Attio Lookup (LinkedIn) |
| Create Record | Attio Create (LinkedIn) |
| Update Record | Attio Update (LinkedIn) |

## Edge Cases

- **Generische Firmennamen:** "My Store", "Test", "Shop" werden vom Match ausgenommen
- **`.myshopify.com` Domains:** keine Custom-Domains, werden nicht zum Match verwendet
- **Apollo findet Email aber LinkedIn passt nicht zum Company-Match:** Email gewinnt, LinkedIn-Mismatch wird geloggt

## Open Questions

- Apollo in Company Table ermöglichen wäre schön (mehr Email-Coverage), aber blockiert vom 48-Spalten-Limit — müsste andere Spalten loswerden
- Spalten-Umbenennungen sind dokumentiert aber noch nicht umgesetzt