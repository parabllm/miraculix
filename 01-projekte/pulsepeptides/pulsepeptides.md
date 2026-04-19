---
typ: ueber-projekt
name: "PulsePeptides"
aliase: ["PulsePeptides", "Pulse", "Pulse Peptides", "PulseBot"]
bereich: operativ
umfang: offen
status: aktiv
kapazitaets_last: hoch
rolle_deniz: "COO"
transition_start: 2026-04-17
transition_ende_geplant: 2026-05-08
hauptkontakt: "[[kalani-ginepri]]"
kontakte: ["[[kalani-ginepri]]", "[[christian-pulse]]", "[[kai-pulse]]", "[[patrick-pulse]]", "[[german-pulse]]", "[[lizzi-pulse]]"]
tech_stack: ["wordpress", "woocommerce", "elementor", "n8n", "slack", "google-sheets", "gmail", "browserless", "openai", "freshdesk", "metorik", "vercel", "telegram"]
notion_url: ""
erstellt: 2026-04-16
notizen: "Peptide-E-Commerce. Deniz ist COO ab 2026-04-17. Kein Thalor-Client mehr, eigenes Uber-Projekt. Firmenstruktur siehe [[firmenstruktur]]."
quelle: chat_session
vertrauen: bestaetigt
---

## Kontext

Peptide-E-Commerce. Verkauf über pulsepeptides.com. Batch-Management intern über PulseBot (Slack) plus n8n plus Google Sheets. Order Management mit Suppliern über Telegram.

Firmenstruktur, Team, Systeme, Pain-Points: siehe [[firmenstruktur]].

## COO-Rolle

Seit 2026-04-17 intern offiziell COO. Transitionsphase ca. 3 Wochen. Umfang 5-10h/Woche.

**Vergütung Phase 1:** Reisen, Essen, Tools. Fixe Vergütung folgt nach Transition.

**Haftung:** Kalani ist Frontrunner fuer Compliance-Themen.

**Verantwortungsbereiche:**
- Peptide bei Suppliern bestellen (Telegram)
- Team koordinieren und Aufgaben verteilen
- Rechnungen und Abrechnung mit Lieferanten
- Qualitaet und Lab-Ergebnisse mit Janoshik
- Eskalations-Endpunkt fuer [[christian-pulse]]
- Workaround fuer Revolut-Banking finden

**Kommunikation:**
- Slack mit Team
- WhatsApp mit Kalani
- Discord fuer Calls

**Onboarding:** taeglich Ruecksprache in Transitionsphase.

**Offene Punkte:**
- Fixe Verguetung definieren (nach Transition)

## Technischer Stack (Bot-Seite)

- **Stack:** n8n Cloud, Slack (PulseBot), Google Sheets (SSOT, 17 Spalten), Gmail, Browserless, OpenAI GPT-4o
- **Interface:** Slack Slash-Command `/pulse` mit Subcommands
- **Labor:** Janoshik (HPLC plus Endotoxin-Tests)
- **Batch-ID-Schema:** `{SupplierCode}{YY}{Q#}{Seq}{ProductCode}` z.B. `LP26Q11BPC`
- **Status-Lifecycle:** Ordered, Received, Testing, Partially Tested, Active, Archived

## Knowledge Base

`knowledge-base/` wird iterativ befuellt:
- `produkte.md`
- `bestellprozess.md`
- `lieferanten.md`
- `team-koordination.md`
- `lab-workflow-janoshik.md`
- `support-eskalation.md`
- `coo-aufgaben.md`
- `firmenstruktur.md`

## Aktueller Stand

Stand 2026-04-17: COO-Rolle gestartet. Erste Bestellung ausgeloest (100 Kits Arg-BPC-157 bei Lab Peptides, 2.800 USD).

## Offene Aufgaben

- [ ] Montag: Kalani fragen wie viele KPV-Bottles bestellen (ZY Peptides hat geantwortet: "Yes, how many?"), dann Reply senden #hoch
- [ ] Montag: Thymosin-Kunde Compensation-Nachricht an Christian in Slack schreiben #hoch
- [ ] Call mit Kalani planen - Übergabe-Stand besprechen (Details: [[coo-aufgaben]]) #mittel
- [ ] Metorik-Zugang einrichten
- [ ] Alternativen Banking-Anbieter fuer Kartenzahlungen recherchieren
- [ ] Knowledge Base iterativ befuellen

## Kontakte

- [[kalani-ginepri]] CEO
- [[christian-pulse]] Support Bali
- [[kai-pulse]] Lager Appelheim
- [[patrick-pulse]] Developer/Backend
- [[german-pulse]] Website/WordPress
- [[lizzi-pulse]] Design/Labels
