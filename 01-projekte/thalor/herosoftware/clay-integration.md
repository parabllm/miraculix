---
typ: aufgabe
name: "HeroSoftware Clay Integration"
projekt: "[[herosoftware]]"
status: erledigt
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[robin-kronshagen]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Clay als Enrichment-Layer. Aus Attio-Listen (Churns, High-Value, Cold Outreach) findet Clay Entscheider-Kontakte, qualifiziert per 3-Tier-Modell, reichert mit Email + Phone an, pusht zurück ins CRM über native Attio-Integration. Stand 2026-04-09.

## Architektur

- **2 Templates live** (Stand: Backfill abgeschlossen, Auto-Sync läuft)
- **Pro Attio-Liste ein eigenes Clay-Template** (gleiche Struktur, andere Source)
- **48-Spalten-Limit** in Clay-Tables (Ressourcen-Constraint)
- **Decision Maker Tier System** (3 Tiers, GPT-4/Claude)
- **Doppel-Enrichment-Schutz:** `enriched_by_clay` Checkbox
- **Phone-Enrichment NUR bei `Language = DE`** (Credit-Schutz)

Im Gegensatz zu WF1 / Hetzner-Skripten ist Clay kein Code-System, sondern eine konfigurierte Tabellen-Pipeline in Clay selbst.

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

Attio Lookup hat 10 Min Delay, Claygent 15 Min Delay. So läuft Find People + Attio Push zuerst. Bei Overlap: Attio Upsert deduped automatisch via Email-Match.

## Templates (Live)

- **Template 1 - Executive Leadership, Digital & Ownership:** Source Attio-Liste "Executive Leadership, Digital, E-Commerce, Ownership". Company Enrichment + Person Table + Attio Push.
- **Template 2 - Churns & Reactivation:** Source Attio-Liste (98 Companies). Company Enrichment + Claygent People Finder + P1/P2/P3 Extraktion + BetterContact Email/Phone + Attio Upsert. Auto-Sync läuft.

## Enrichment Waterfalls

### LinkedIn Company URL (4-Layer)

1. Claygent (Website + Google) - Primary
2. Apollo Enrich Company - Fallback
3. Claygent Deep Search (Google aggressiv) - Fallback 2
4. Claygent URL Constructor (raten + verifizieren) - letzter Fallback

Konsolidiert in `LinkedIn URL (Final)`.

### Email (3-Layer)

1. BetterContact → Find Work Email
2. Apollo → Find Email
3. Claygent Email Finder (LinkedIn + Website + Google)

Konsolidiert in `Email (Final)`.

### Phone (2-Layer) - NUR bei `Language = DE`

1. BetterContact → Find Mobile Phone
2. Clay Waterfall Mobile Phone Enrichment

Konsolidiert in `Phone (Final)`. Run Condition: `Language = DE` spart Credits.

## Decision Maker Tier System

3-Tier-Modell, Claygent mit GPT-4/Claude besucht LinkedIn-Profile.

### Tier 1 - ENTSCHEIDER (Robin kontaktiert sofort)

Owner, Founder, CEO, Geschäftsführer, CTO, Head of E-Commerce, Prokurist, Vorstand, Managing Director, COO, E-Commerce Manager, Shop Manager, Head of Operations, Head of Digital

### Tier 2 - GRENZFALL (Robin entscheidet manuell)

Marketing Manager, Product Manager, IT Manager, Tech Lead, Head of Sales, CRM Manager, Senior Developer

### Tier 3 - NICHT RELEVANT (automatisch rausgefiltert)

Store Manager, Filialleiter, Intern, Werkstudent, HR, Recruiter, Sales Rep, Designer, Customer Support, Warehouse

### Special Rules

- Investor + Founder = Tier 1
- Store/Branch Manager = IMMER Tier 3
- Kleine Companies (<50 MA): im Zweifel upgraden

## Attio Push - Matching-Logik

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

- Attio Upsert People matcht nur über Email
- LinkedIn URL: Clay hat trailing Slash, Attio nicht → Formula "LinkedIn Clean"
- Phone Numbers: Attio erwartet Array → separater Update Step mit "Append"
- Company-Feld: erwartet UUID, nicht Company-Name

## Language Detection

- **Company Table (Claygent, 3 Credits):** besucht Website, prüft Sprache + Domain TLD + Firmenname (GmbH etc.). Erkennt auch `.com`-Shops die auf Deutsch sind.
- **Person Table (AI Formula, 1 Credit):** Location-basiert (DACH = DE, sonst EN). Erkennt auch Städte.
- **Attio-Feld:** `Contact Language` (Select: DE, EN)

## Claygent People Finder (für Companies ohne Kontakte)

Sucht auf LinkedIn People Tab + Website (Impressum, Team, About) + Google.

- Bis zu 3 Personen als JSON-Array
- Nur Tier-1-Titel
- Output: `{"people": [{"first_name", "last_name", "title", "linkedin"}]}`
- Run Condition: Attio People Lookup = "No records found"

## Lead Quality System (4 Stufen)

| Quality | Daten | LGM Sequence? |
|---|---|---|
| Priority | Email + Phone + LinkedIn | Ja (alle 3 Kanäle) |
| Standard | Email + LinkedIn | Ja (Email + LinkedIn) |
| Basic | Nur Email | Ja (nur Email) |
| Low | Nur LinkedIn | Nein |

Lead Quality wird als Formula berechnet und beim Attio Upsert mitgegeben. Low wird bei LinkedIn-only Create-Records gesetzt.

## Ready for Sequence Logik

Company ready wenn: `enriched_by_clay = true` ODER `manually_enriched = true`.

[[lgm-push]] holt dann ALLE People der Company (egal ob Clay/Mantle/manuell).

## Attio-Attribute

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

## Coverage-Statistik (Person Table, Initial-Lauf)

**359 Personen total:**
- Tier 1: 202 (56%)
- Email: 165/202 (82% der Tier 1) - BetterContact: 17, Apollo: 150 (**Apollo ist Hauptquelle**)
- Phone: 95/202 (47%)
- Language: 187 DE, 172 EN (100%)
- Attio Push: 163 (160 Upsert + 3 Update)

### Company Table Claygent Fallback (33 Companies ohne Team)

- P1 gefunden: 26/33
- P1 Email: 5/26 (19% - nur BetterContact, kein Apollo wegen Spaltenlimit)
- Attio Push: 5

## Key Learning

**Apollo >> BetterContact für Email.** Person Table: Apollo 150 Emails vs. BetterContact 17. Apollo ist Hauptquelle. Company Table fehlt Apollo wegen Spaltenlimit - daher nur 19% Email-Coverage.

## Edge Cases

- Generische Firmennamen ("My Store", "Test", "Shop") vom Match ausgenommen
- `.myshopify.com` Domains keine Custom-Domains, nicht zum Match verwendet
- Apollo findet Email aber LinkedIn passt nicht zum Company-Match: Email gewinnt, LinkedIn-Mismatch wird geloggt

## Open Points

- Apollo in Company Table ermöglichen wäre gut (mehr Email-Coverage), blockiert vom 48-Spalten-Limit
- Spalten-Umbenennungen sind dokumentiert aber noch nicht umgesetzt
