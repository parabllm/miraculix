---
typ: sub-projekt
name: "PulsePeptides"
aliase: ["PulsePeptides", "Pulse", "Pulse Peptides", "PulseBot"]
ueber_projekt: "[[thalor]]"
bereich: client_work
umfang: offen
status: aktiv
kapazitaets_last: hoch
rolle_deniz: "COO"
transition_start: 2026-04-17
transition_ende_geplant: 2026-05-08
kontakte: ["[[kalani-ginepri]]", "[[christian-pulse]]", "[[kai-pulse]]", "[[patrick-pulse]]", "[[german-pulse]]", "[[lizzi-pulse]]"]
tech_stack: ["wordpress", "woocommerce", "elementor", "n8n", "slack", "google-sheets", "gmail", "browserless", "openai", "freshdesk", "Metorik", "vercel", "telegram"]
notion_url: ""
erstellt: 2026-04-16
notizen: "Peptide-E-Commerce. Seit 2026-04-17 intern offiziell COO. Transitionsphase ca. 3 Wochen. Vergütung Phase 1: Reisen, Essen, Tools. Firmenstruktur siehe [[firmenstruktur]]."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

Peptide-E-Commerce. Verkauf über pulsepeptides.com. Batch-Management intern über PulseBot (Slack) plus n8n plus Google Sheets. Order Management mit Suppliern über Telegram.

Firmenstruktur, Team, Systeme, Pain-Points: siehe [[firmenstruktur]].

## COO-Rolle

Intern offiziell COO ab 2026-04-17. Kein externer Titel nach aussen. Transitionsphase ca. 3 Wochen. Umfang 5-10h/Woche.

**Vergütung Phase 1 (Transition):** Reisen, Essen, Tools (z.B. Claude). Fixe Vergütung folgt nach Transition.

**Haftung:** Kalani ist Frontrunner für Compliance-Themen. Deniz ist operativ tätig aber nicht persönlich exponiert.

**Verantwortungsbereiche:**
- Peptide bei Suppliern bestellen (Telegram)
- Team koordinieren und Aufgaben verteilen
- Rechnungen und Abrechnung mit Lieferanten
- Qualität und Lab-Ergebnisse mit Janoshik
- Eskalations-Endpunkt für [[christian-pulse]]
- Workaround für Revolut-Banking finden (Aufgabe)

**Kommunikation:**
- Slack mit Team
- WhatsApp mit Kalani
- Discord für Calls

**Onboarding:** täglich Rücksprache in Transitionsphase (~3 Wochen).

**Offene Punkte:**
- Übergabeplan (was wann konkret)
- Fixe Vergütung definieren (nach Transition)

## Technischer Stack (Bot-Seite, Thalor-Projekt)

- **Stack:** n8n Cloud, Slack (PulseBot), Google Sheets (SSOT, 17 Spalten), Gmail, Browserless, OpenAI GPT-4o
- **Interface:** Slack Slash-Command `/pulse` mit Subcommands
- **Labor:** Janoshik (HPLC plus Endotoxin-Tests)
- **Batch-ID-Schema:** `{SupplierCode}{YY}{Q#}{Seq}{ProductCode}` z.B. `LP26Q11BPC`
- **Status-Lifecycle:** Ordered, Received, Testing, Partially Tested, Active, Archived

**3 n8n-Workflows:**
1. PulseBot Router
2. PulseBot Interactivity
3. Janoshik Backfill

**Kritische Patterns:**
- Slack 3s-Timeout, async Response-Pattern
- Gmail Send Lab Email MUSS erfolgreich sein bevor Status-Update

## Knowledge Base

`knowledge-base/` — wird iterativ befüllt:
- `bestellprozess.md`
- `lieferanten.md`
- `team-koordination.md`
- `lab-workflow-janoshik.md`
- `support-eskalation.md`

## Aktueller Stand

Stand 2026-04-17: COO-Rolle gestartet. Onboarding-Call gestern (siehe Log 2026-04-16). Call heute 13:00 Orderprozess und Metorik. Admin-Hub-Entscheidung ausstehend.

## Offene Aufgaben

- Orderprozess-Call heute 13:00 mit Kalani
- Metorik-Zugang einrichten (kommt via 1Password)
- Alternativen Banking-Anbieter für Kartenzahlungen recherchieren (Revolut-Ersatz)
- Knowledge Base iterativ befüllen
- Übergabeplan mit Kalani definieren
- Admin-Hub-Entscheidung abwarten

## Out of Scope

- E-Commerce-Frontend und Shop-System
- Kundendaten-Management
- Payment-Abwicklung

## Kontakte

- [[kalani-ginepri]] CEO
- [[christian-pulse]] Support Bali
- [[kai-pulse]] Lager Appelheim
- [[patrick-pulse]] Developer/Backend
- [[german-pulse]] Website/WordPress
- [[lizzi-pulse]] Design/Labels


## COO-Agenda

Strukturelle Aufgaben und interne Baustellen: siehe [[coo-aufgaben]].

## Offene Aufgaben

- [ ] KPV Capsules bei ZY Peptides anfragen (Telegram) und Christian morgen zurueckmelden
