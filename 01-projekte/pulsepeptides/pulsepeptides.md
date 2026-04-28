---
typ: ueber-projekt
name: PulsePeptides
aliase: ["PulsePeptides", "Pulse", "Pulse Peptides", "PulseBot"]
bereich: operativ
umfang: offen
status: aktiv
kapazitaets_last: hoch
rolle_deniz: COO
transition_start: 2026-04-17
transition_ende_geplant: 2026-05-08
hauptkontakt: "[[kalani-ginepri]]"
kontakte: ["[[kalani-ginepri]]", "[[christian-pulse]]", "[[kai-pulse]]", "[[patrick-pulse]]", "[[german-pulse]]", "[[lizzi-pulse]]"]
tech_stack: ["wordpress", "woocommerce", "elementor", "n8n", "slack", "google-sheets", "gmail", "browserless", "openai", "freshdesk", "metorik", "vercel", "telegram"]
notion_url: ""
erstellt: 2026-04-16
aktualisiert: 2026-04-28
notizen: |-
  Peptide-E-Commerce. Deniz ist COO ab 2026-04-17. Kein Thalor-Client mehr, eigenes Über-Projekt. Firmenstruktur siehe [[firmenstruktur]].
quelle: chat_session
vertrauen: bestätigt
---
## Kontext

Peptide-E-Commerce. Verkauf über [pulsepeptides.com](http://pulsepeptides.com). Batch-Management intern über PulseBot (Slack) plus n8n plus Google Sheets. Order Management mit Suppliern über Telegram plus WhatsApp.

Firmenstruktur, Team, Systeme, Pain-Points: siehe [[firmenstruktur]].

## COO-Rolle

Seit 2026-04-17 intern offiziell COO. Transitionsphase ca. 3 Wochen. Umfang 5-10h/Woche.

**Vergütung Phase 1:** Reisen, Essen, Tools. Fixe Vergütung folgt nach Transition.

**Haftung:** Kalani ist Frontrunner für Compliance-Themen.

**Verantwortungsbereiche:**

- Peptide bei Suppliern bestellen (Telegram, WhatsApp)
- Team koordinieren und Aufgaben verteilen
- Rechnungen und Abrechnung mit Lieferanten
- Qualitaet und Lab-Ergebnisse mit Janoshik
- Eskalations-Endpunkt für [[christian-pulse]]
- Workaround für Revolut-Banking finden

**Kommunikation:**

- Slack mit Team
- WhatsApp mit Kalani plus mit XiAN Sheerherb (Pax)
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
- `lieferanten.md` (XiAN-Sheerherb-Kontakt Pax und neue Inquiry, neu 2026-04-28)
- `lab-peptides.md` (vollständige Preisliste)
- `team-koordination.md`
- `lab-workflow-janoshik.md`
- `support-eskalation.md`
- `firmenstruktur.md` (Pulse Organization UK ergaenzt, Druckerei-Sourcing-Spec, neu 2026-04-28)
- `bulk-pricing.md` (Christians v2 plus geplante v3-Struktur)
- `design-system.md` (Farbpalette, Typografie, Komponenten, CSS-Tokens [pulsepeptides.com](http://pulsepeptides.com))
- `xian-sheerherb.md` (Kontakt Pax, KPV-Wechsel, neu 2026-04-28)

`coo-aufgaben.md`, `coo-automations.md`, `janoshik-ocr.md`, `pulsebot-workflows.md`, `eppelheim-lager.md` (operatives Lager mit aktuellen Logistik-Daten, neu 2026-04-28), `lager-tschechien.md` (geplante Verlagerung) im Haupt-Ordner.

`custom-orders/` für einzelne Custom-Order-Cases.

## Aktueller Stand

Stand 2026-04-23: COO Weekly Call mit Kalani durchgeführt (Details [[2026-04-23-kalani-coo-call]]). Lager-Besuch Eppelheim entfiel (Kalani krank, Lebensmittelvergiftung). Mehrere SOPs neu definiert: Custom-Order (CAS/PubChem/Sequenz-Abfrage), Affiliate-Cap (1.000 Follower, Christian autonom), Norway Express Shipping (UPS Express Standard). Bulk-Pricing-Linie für B2B festgelegt (siehe [[support-eskalation]]). Slack-Schreibstil als Projekt-Skill formalisiert (`pulse-slack-schreibstil`).

Stand 2026-04-27: Erste Inquiry für Lager-Verlagerung Tschechien eingegangen (Maman Euro Logistic, Cheb). Angebot vom 2026-03-30, ausführlich aufgenommen in [[lager-tschechien]]. TBD-Felder offen, Vergleichs-Inquiries noch nicht eingeholt. Christians Bulk-Pricing v2 eingegangen, dokumentiert in [[bulk-pricing]] inkl. Konflikt-Analyse zur Kalani-Linie und 9-Punkte-Review-Liste, Pepspan-Antwort weiter geblockt bis v3. Design-System [pulsepeptides.com](http://pulsepeptides.com) extrahiert und in [[01-projekte/pulsepeptides/knowledge-base/design-system|design-system]] dokumentiert (Farbpalette, Typografie Red Hat Display, Komponenten, CSS-Tokens, Astra-Theme abgeleitet).

Stand 2026-04-28: Lager-Besuch Eppelheim durchgeführt mit Kalani, Kai und Albin (Details [[2026-04-28-lager-besuch-kalani]]). Tschechien Phase 1 entschieden: DE labelt fertig, Tschechen lernen erst nur Versand, Test mit 20% der Bestellungen. Pulse-aus-DE-Strategie mit DDP-Setup ueber chinesische Firma als Origin. Versandsystem-Migration zu UPS plus Unternehmens-API in Tschechien. Inventory-Bestellungen identifiziert: PT-141, Tesamorelin, Cmax, Semang. Etiketten-Bug 100 Stueck Hyaluronic-Acid-Text. WhatsApp-Gruppe Pulse x XianHerb mit Pax aufgemacht (KPV-Wechsel von ZY plus 5-Amino-1MQ neu plus BPC-157 Caps). Pulse Organization Ltd UK in Firmenstruktur ergaenzt. Druckerei-Sourcing-Auftrag: 10 ct/Stueck, 10k alle 3 Monate, scalable, Vials plus Kapsel-Bottles plus Bac-Water-Bottles, Cyprus zahlt, UK rechnet (Nachgespraech [[2026-04-28-nachgespraech-kalani]]).

## Offene Aufgaben

### Hoch

- \[ \] Janoshik OCR Pipeline aufsetzen
- \[ \] Offene Bestellungen ins System eintragen (Backlog plus aktuelle Backorders)
- \[ \] Druckereien anrufen fuer Label-Sourcing (10 ct/Stueck, 10k alle 3 Monate, scalable, Scope: Vials, Kapsel-Bottles, Bac-Water-Bottles, Cyprus zahlt, UK rechnet)
- \[ \] WhatsApp-Antwort von Pax (XiAN Sheerherb) tracken: BPC-157 Caps, 5-Amino-1MQ, KPV
- \[ \] Bulk-Pricing-Liste überarbeiten und als v3 ablegen, bevor Pepspan-Antwort rausgeht (Christians v2 liegt vor, siehe [[bulk-pricing]])
- \[ \] Prostamax Custom-Order: auf Lily-Antwort (Lab Peptides) und Kundenmenge warten, dann Order auslösen
- \[ \] Affiliate-Framework mit No-Human-Use-Klausel aufbauen (siehe [[coo-aufgaben]])
- \[ \] N8N Janoshik-Workflow fixen, dann DHL-CSV-Flow reparieren
- \[ \] PT-141, Tesamorelin, Cmax, Semang nachbestellen
- \[ \] Bezahl-Setup: andere Kreditkarte fuer Pulse organisieren (getrennt vom Rest)

### Mittel

- \[ \] System-Login-Sweep: überall anmelden und Admin-Zugriff sicherstellen (siehe [[coo-aufgaben]])
- \[ \] Reta Lab-Test Transition PulsePeptides → Axonpeptides als SOP dokumentieren
- \[ \] Valko_body Onboarding-Details klären
- \[ \] Onboarding-Dokument Tschechen-Lager finalisieren
- \[ \] DHL-Anmeldung fuer Tschechien-Firma vorbereiten
- \[ \] Mit Patrick: WMS Lokia (Maman) Anbindung an Pulse-Systeme klaeren

### Strategisch parallel

- \[ \] Distributor-Eisbox-Angebot fuer PepStar-Kandidat ausarbeiten
- \[ \] Batch-Nummer-Loesung als Alternative zum Etikettendrucker evaluieren (Direktdruck wie Lab Peptides)
- \[ \] 20%-Test-Volumen Tschechien starten sobald Setup steht

### Verschoben

- \[ \] BPC-157 plus 5-Amino-1 Kapseln Sourcing beim Testing-Badge-Supplier (XiAN Sheerherb): laeuft aktiv ueber Pax, in WhatsApp-Inquiry uebergegangen
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
- ~~Lager-Besuch Eppelheim durchgefuehrt mit Kalani plus Kai plus Albin~~ 2026-04-28
- ~~Tschechien Phase 1 Setup entschieden (DE labelt, Tschechen versenden, 20% Test-Volumen)~~ 2026-04-28
- ~~WhatsApp-Gruppe Pulse x XianHerb mit Pax aufgemacht (KPV-Wechsel, neue Inquiry)~~ 2026-04-28

## Kontakte

- [[kalani-ginepri]] CEO
- [[christian-pulse]] Support Bali
- [[kai-pulse]] Lager Eppelheim
- [[patrick-pulse]] Developer/Backend
- [[german-pulse]] Website/WordPress
- [[lizzi-pulse]] Design/Labels
- Pax (XiAN Sheerherb, neu 2026-04-28, Kontakt-File offen)
