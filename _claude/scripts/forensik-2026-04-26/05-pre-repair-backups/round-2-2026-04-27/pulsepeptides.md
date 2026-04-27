---

## typ: ueber-projekt name: "PulsePeptides" aliase: \["PulsePeptides", "Pulse", "Pulse Peptides", "PulseBot"\] bereich: operativ umfang: offen status: aktiv kapazitaets_last: hoch rolle_deniz: "COO" transition_start: 2026-04-17 transition_ende_geplant: 2026-05-08 hauptkontakt: "[[kalani-ginepri]]" kontakte: \[[kalani-ginepri]]", "[[christian-pulse]]", "[[kai-pulse]]", "[[patrick-pulse]]", "[[german-pulse]]", "[[lizzi-pulse]]"\] tech_stack: \["wordpress", "woocommerce", "elementor", "n8n", "slack", "google-sheets", "gmail", "browserless", "openai", "freshdesk", "metorik", "vercel", "telegram"\] notion_url: "" erstellt: 2026-04-16 aktualisiert: 2026-04-23 notizen: "Peptide-E-Commerce. Deniz ist COO ab 2026-04-17. Kein Thalor-Client mehr, eigenes Uber-Projekt. Firmenstruktur siehe [[firmenstruktur]]." quelle: chat_session vertrauen: bestätigt

## Kontext

Peptide-E-Commerce. Verkauf über [pulsepeptides.com](http://pulsepeptides.com). Batch-Management intern über PulseBot (Slack) plus n8n plus Google Sheets. Order Management mit Suppliern über Telegram.

Firmenstruktur, Team, Systeme, Pain-Points: siehe [[firmenstruktur]].

## COO-Rolle

Seit 2026-04-17 intern offiziell COO. Transitionsphase ca. 3 Wochen. Umfang 5-10h/Woche.

**Vergütung Phase 1:** Reisen, Essen, Tools. Fixe Vergütung folgt nach Transition.

**Haftung:** Kalani ist Frontrunner für Compliance-Themen.

**Verantwortungsbereiche:**

- Peptide bei Suppliern bestellen (Telegram)
- Team koordinieren und Aufgaben verteilen
- Rechnungen und Abrechnung mit Lieferanten
- Qualitaet und Lab-Ergebnisse mit Janoshik
- Eskalations-Endpunkt für [[christian-pulse]]
- Workaround für Revolut-Banking finden

**Kommunikation:**

- Slack mit Team
- WhatsApp mit Kalani
- Discord für Calls

**Onboarding:** täglich Ruecksprache in Transitionsphase.

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
- `lab-peptides.md` (vollständige Preisliste, neu 2026-04-23)
- `team-koordination.md`
- `lab-workflow-janoshik.md`
- `support-eskalation.md`
- `firmenstruktur.md`

`coo-aufgaben.md`, `coo-automations.md`, `janoshik-ocr.md`, `pulsebot-workflows.md` im Haupt-Ordner.

`custom-orders/` für einzelne Custom-Order-Cases.

## Aktueller Stand

Stand 2026-04-23: COO Weekly Call mit Kalani durchgeführt (Details [[2026-04-23-kalani-coo-call]]). Lager-Besuch Eppelheim entfiel (Kalani krank, Lebensmittelvergiftung). Mehrere SOPs neu definiert: Custom-Order (CAS/PubChem/Sequenz-Abfrage), Affiliate-Cap (1.000 Follower, Christian autonom), Norway Express Shipping (UPS Express Standard). Bulk-Pricing-Linie für B2B festgelegt (siehe [[support-eskalation]]). Slack-Schreibstil als Projekt-Skill formalisiert (`pulse-slack-schreibstil`).

## Offene Aufgaben

### Hoch

- \[ \] Bulk-Pricing-Liste von Christian einholen und überarbeiten, bevor Pepspan-Antwort rausgeht
- \[ \] Prostamax Custom-Order: auf Lily-Antwort (Lab Peptides) und Kundenmenge warten, dann Order auslösen
- \[ \] Affiliate-Framework mit No-Human-Use-Klausel aufbauen (siehe [[coo-aufgaben]])

### Mittel

- \[ \] System-Login-Sweep: überall anmelden und Admin-Zugriff sicherstellen (siehe [[coo-aufgaben]])
- \[ \] Reta Lab-Test Transition PulsePeptides → Axonpeptides: beim nächsten Sync mit Kalani klären
- \[ \] Valko_body Onboarding-Details klären

### Verschoben bis Kalani wieder fit ist

- \[ \] KPV Supplier-Wechsel von ZY auf Testing-Badge-Supplier durchziehen
- \[ \] BPC-157 + 5-Amino-1 Kapseln Sourcing beim Testing-Badge-Supplier
- \[ \] US Shipments konkrete Schritte festlegen
- \[ \] PepStack Vendor Program strategisch bewerten (Max Berktold)

## Abgeschlossene Meilensteine

- ~~Metorik-Zugang eingerichtet~~ 2026-04-20
- ~~500 Pakete nachbestellen (kein neues Design nötig)~~ 2026-04-23
- ~~Norway Express Shipping SOP definiert (UPS Express ab 49,15 EUR)~~ 2026-04-23
- ~~Affiliate Follower-Cap bei 1.000 festgelegt, Christian autonom~~ 2026-04-23
- ~~Custom-Order-SOP definiert (CAS → PubChem → Sequenz)~~ 2026-04-23
- ~~Lab Peptides Preisliste vollständig dokumentiert~~ 2026-04-23
- ~~Thymosin-Kunde Compensation aus Agenda genommen~~ 2026-04-23

## Kontakte

- [[kalani-ginepri]] CEO
- [[christian-pulse]] Support Bali
- [[kai-pulse]] Lager Eppelheim
- [[patrick-pulse]] Developer/Backend
- [[german-pulse]] Website/WordPress
- [[lizzi-pulse]] Design/Labels
