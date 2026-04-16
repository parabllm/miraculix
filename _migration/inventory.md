# Inventur - Phase A

Erstellt: 2026-04-16
Quellen:
- `00-eingang/notion/` - 128 Files (Markdown + CSV), Notion Second-Brain Export
- `00-eingang/claude/` - 112 Conversations (`conversations.json`, 83 MB), 7 Projekt-Container (`projects.json`), `memories.json`, `users.json`

---

## Projekte erkannt

Aus Notion (`Projects` DB, Stand 2026-04-09) sowie Claude-Projekten (Stand 2026-03-28) und Konversations-Titeln. Zeitlich jüngste Quelle: Notion (09.04.) + Claude-Chats bis 16.04.

### Über-Projekte

| Slug | Notion-Name | Bereich | Status | Haupt-Kontakte | Quellen |
|---|---|---|---|---|---|
| `thalor` | Thalor Agency | client_work | aktiv (Umbrella) | - | Notion PRJ-8 + Claude "Logo und Branding für Talor Agency" |
| `coralate` | coralate | produkt | aktiv | Jann Allenberger, Lars Blum | Notion PRJ-7 + Claude Project "Coralate" + viele Food-Scanner Docs |
| `hays` | HAYS CEMEA | intern | aktiv | Christine Kampmann, Julia Renzikowski | Notion PRJ-2 + Doc "HAYS Kontext" |
| `thesis` | Bachelor Thesis | studium | aktiv (Kritisch, Abgabe 15.06.2026) | Prof. Sandbrink + 10 HAYS-Interview-Kandidaten | Notion PRJ-3 |
| `persoenlich` | Personal Life | persoenlich | aktiv | - | Notion PRJ-1 + Health/Supplement Chats |
| `miraculix` | (nur Claude) | intern | aktiv | - | Claude "Miraculix" Projekt + Chats zu Second-Brain/Obsidian |
| `terminbuchung-app` | Terminbuchungs-App | produkt | pausiert (bis nach Thesis) | - | Notion PRJ-9 |

### Sub-Projekte (2. Ebene)

Unter `thalor/`:
- `herosoftware` - PRJ-10, Mantle→Attio→Clay→LGM Pipeline, Robin Kronshagen (größter aktiver Client)
- `bellavie` - PRJ-6, Beauty-Salon Neunkirchen, Maddox Yakymenskyy, Framer+Fresha
- `pulsepeptides` - PRJ-5, Peptide E-Commerce, Kalani Ginepri, PulseBot/n8n/Janoshik
- `resolvia` - PRJ-4, Stripe→Attio Sync Auftrag, David Schreiner (500€)

Unter `coralate/`:
- `cora-ai-engine` - RAG-/Korrelations-Engine (Modi: Proaktiv, Card-QA, Home-RAG)
- `food-scanner` - dominantes Sub-Thema, eigene Master-Doc `DOC-62` (v8 Architecture), Pipeline Supabase+pgvector+Edge Functions; 15+ Docs, 10+ Logs
- `coralate-pictures` - Claude-Projekt ohne Content, vermutlich Image-Pipeline (Exercise images)

Unter `hays/`:
- `lizenzmanagement` - 7 Power Automate Flows, Konzept Power-BI-Dashboard (Doc "Lizenzmanagement Lösung - Briefing")

Unter `thesis/`:
- `interviews` - 7-9 Experteninterviews in 2 Clustern (Operativ + Compliance/Legal)

Keine separaten Sub-Projekte im `persoenlich`-Bucket - Docs direkt dort.

---

## Personen erkannt

20 benannte Kontakte, alle aus Notion `Contacts` (CSV + pro-Person MD-Files). Keine zusätzlichen Personen aus Claude-Chats die nicht auch in Notion stehen.

### Nach Gruppen

**Coralate Core (2):**
- Jann Allenberger - Co-Founder/Frontend-Partner (Food-Scanner-Backend von ihm)
- Lars Blum - Coralate Team

**Thalor-Clients (4):**
- Maddox Yakymenskyy - BellaVie (Freund + Kunde)
- Robin Kronshagen - HeroSoftware
- Kalani Ginepri - PulsePeptides
- David Schreiner - Resolvia AI

**HAYS (3 operativ + 10 Thesis-Kandidaten):**
- Christine Kampmann - Primary Contact HAYS, Thesis-Enablerin
- Julia Renzikowski - HAYS-Kollegin
- Prof. Dr. Christoph Sandbrink - Thesis-Betreuer (HdWM)
- Anna Lüttgen, Arda Sener, Felix Schwarz, Florian Gönnwein, Florian Meyer, Francis Davis, Johannes Leuschner, Lara Lünnemann, Leon Rädisch, Rini Kodzadziku, Rob Norris - Thesis-Interviewpartner, von Christine empfohlen (17.03.2026)

**Self:**
- Deniz Özbek - wird nicht als Kontakt angelegt (= Vault-Owner)

### Aliases aus Source-Material (Kurzliste)

- Maddox Yakymenskyy → ["Maddox", "Max", "Maddox Y"]
- Robin Kronshagen → ["Robin", "Robin K"]
- Jann Allenberger → ["Jann"]
- Kalani Ginepri → ["Kalani"]
- David Schreiner → ["David", "David S"]
- Christine Kampmann → ["Christine", "Christine K"]
- Prof. Dr. Christoph Sandbrink → ["Sandbrink", "Prof. Sandbrink", "Prof Dr Christoph Sandbrink"]

---

## Wissens-Domains erkannt

Aus Docs, Log-Titeln und Chat-Content. Prio nach Frequenz:

### Tool-/Infrastruktur-Domains
- **n8n** - Cloud-Webhooks, Batch-Workflows, Slack-Routing, Error-Patterns (WF1, PulseBot, Workflow-Error-Slack)
- **Attio** - CRM als SSOT, Match-Kaskade, Stripe/Mantle-Integration
- **Clay** - Enrichment, Templates, Tier System, Tables
- **La Growth Machine (LGM)** - Outbound, Audiences/IDs-Mapping, Status-Sync
- **Supabase** - Edge Functions (Deno), pgvector, RLS, Auth, DB-Reset-Patterns (Food Scanner)
- **Stripe** - Metadata-gestütztes Matching, Resolvia-Scope, Subscription-Events
- **Mantle** (Shopify Billing) - Webhook-Source für HeroSoftware
- **Power Automate / SharePoint** - HAYS, Lizenzmanagement, Hub-and-Spoke
- **Framer** - BellaVie Website
- **Fresha** - Booking-System BellaVie
- **Hetzner** - Server-Setup für HeroSoftware-Batch-Scripts und Thalor-Website
- **Slack** - PulseBot-UI, Error-Notifications, 3s-Timeout-Pattern
- **Gmail** - Lab-Email in PulseBot vor Status-Update (Reliability-Pattern)
- **Janoshik OCR** - Pulse Lab-Report-Parsing
- **React Native / Expo / Zustand / Skia** - Coralate Stack
- **pgvector / INFOODS / OFF** - Food-Scanner Retrieval-Layer

### Methodik-Domains
- **Mayring Inhaltsanalyse** - Thesis-Methodik
- **EU AI Act / Compliance** - Thesis-Thema Cluster Legal
- **Interview-Design** - Thesis, 2 Cluster, Leitfaden
- **RAG-Architektur** - Cora, Food Scanner (Hybrid 3-Tier, RRF, Embeddings)
- **Lokale SEO** - BellaVie, Outreach-Pattern (Heiran Dänemark)
- **Stripe/Attio Matching-Kaskade** - wiederholt: Hero-WF1, Resolvia
- **Health / Supplement Biohacking** - Personal Life, keine Projekt-Relevanz

### Cross-Project Patterns (Kandidaten für `02-wissen/`)
- **n8n Webhook-Pattern**: WF1 Mantle→Attio UND (geplant) Resolvia Stripe→Attio → 2 Projekte → `abgeleitet`
- **Attio Match-Kaskade (Domain/Email → Fallback Create)**: Hero + Resolvia geplant → 2 Projekte
- **Supabase Edge Function Deno-Limits**: nur Coralate (Food Scanner) - noch nicht cross
- **Slack 3s-Timeout / Async-Response-Pattern**: nur Pulse - noch nicht cross
- **Batch-Jobs via Hetzner-Cron**: nur Hero - noch nicht cross

---

## Nicht zuordenbare Files / Ambiguitäten

### Claude-Conversations ohne Titel (37 Stück)
Alle `msgs > 0` aber `chars = 0` - vermutlich Chats die nur aus Audio/Images bestanden, Tool-Outputs, oder abgebrochene Sessions. **Behandlung:** Skip in Phase D (kein destillierbarer Inhalt), werden nicht ins Wissen verarbeitet. Claude-Export bleibt als Fallback.

### Einzelne Chats mit unklarer Projekt-Zuordnung
- "Vector DB" (2026-04-13, 375k chars) - Titel-Keyword-Match schwach, aber inhaltlich vermutlich Food-Scanner (pgvector) → in Phase D verifizieren
- "💬 Recherchiere umfassend zum The…" (2026-03-29, 6.7k chars) - abgeschnittener Titel, vermutlich Research-Ein-Shot
- "Unbenannt" (2026-04-07, 2.3k chars) - kurz, vermutlich Coralate
- "SAP Bewerbung" (2026-03-23, 164k chars) - **persoenlich/career**, nicht Coralate wie Keyword vermutete
- "LinkedIn Profil optimieren" (2026-03-27, x2) - persoenlich/career
- "Kalender" (2026-03-24, 120k chars) - vermutlich Miraculix/Orga, nicht Hero
- "Website für Workflow-Automatisierung-Agentur" (2026-03-27, 63k chars) - **Thalor-Website**, nicht Hero
- "Metorik Flow" (2026-03-19, 71k chars) - **Pulse** (WooCommerce/Metorik), nicht Personal
- "Externe Speicherverwaltung für Claude" - Miraculix, nicht Coralate
- "SEO-Outreach für Heiran Dänemark" - **Pulse** (nicht BellaVie; Heiran ist Pulse-Lab)
- "Bachelorarbeit-Dokumentation ergänzen" - **Thesis**, nicht Coralate

→ Keyword-Classifier ist grob, echte Zuordnung in Phase D nach Chat-Head-Read.

### Ambige Notion-Pages
- `Home 79228b97…md` - Notion Dashboard-Page, Meta-Inhalt → nicht migrieren, Fallback im Source
- `Second Brain 33c91df4…md` - Notion-Root, ebenfalls Meta → skip
- `Claude Context 33c91df4…md` - Notion-Page die Claude-Boot-Kontext enthielt → wird durch neues CLAUDE.md abgelöst, nicht migrieren
- `Unbenannt 33c91df4938681fe…md` - leerer Placeholder → skip
- `Cora Backend - Fortlaufende Doku Sprint 2 …md` (Root-Level, Duplikat zu `Second Brain/Docs/Cora Backend - Sprint 2 Continuity Doc`) → neuere Version (im Titel "Fortlaufende") nehmen, alte verwerfen

Alle unklaren Cases werden nicht pauschal nach `00-eingang/unverarbeitet/` geschoben - die Source-Ordner bleiben als Fallback. Nur echte AMBIG-Entscheidungen aus Destillation landen als `AMBIG_*.md` dort.

---

## Zahlen

- Über-Projekte: **7** (davon 1 pausiert)
- Sub-Projekte: **9** (4 unter thalor, 3 unter coralate, 1 unter hays, 1 unter thesis)
- Kontakte: **20** (1 Core-Coralate, 4 Client-Entscheider, 3 HAYS-Operativ, 11 Thesis-Interview + 1 Professor)
- Claude-Conversations mit Content: **~75** von 112 (37 leer)
- Notion-Docs: **~55** substantielle Markdown-Files + 8 CSVs
- Wissens-Kandidaten cross-project: **2 mit ≥ 2 Projekten** (n8n Webhook, Attio Match-Kaskade). Rest zunächst projekt-lokal.

---

## Plan für Phase B+

1. **Phase B** - 20 Kontakt-Files in `03-kontakte/` nach Schema. Nur ein File pro Person, Aliases sorgfältig.
2. **Phase C** - 7 Über-Projekt-Ordner, 9 Sub-Projekt-Ordner, jeweils `_projekt.md`. Commit nach jedem Über-Projekt.
3. **Phase D** - Claude-Chats destillieren (**nicht** roh kopieren): pro Projekt `logs/` + ggf. `meetings/`. Leere Chats überspringen.
4. **Phase E** - Cross-Project Patterns (n8n Webhook, Attio Match-Kaskade) als `02-wissen/` Einträge, `abgeleitet`.
5. **Phase F** - wahrscheinlich skippen (keine klare Tages-Struktur in den Chats erkennbar).
6. **Phase G + H** - Lint + Report.

Source-Ordner `00-eingang/notion/` und `00-eingang/claude/` bleiben erhalten als Fallback-Referenz.
