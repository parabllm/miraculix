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
- `team-koordination.md`
- `lab-workflow-janoshik.md`
- `support-eskalation.md`
- `coo-aufgaben.md`
- `firmenstruktur.md`

## Aktueller Stand

Stand 2026-04-20: KPV Capsules für nächste Bestellung eingeplant (ZY Peptides hat Verfuegbarkeit bestaetigt). Christian wurde informiert ("available soon"). Affiliate Valko_body approved. US-Markt wird geprueft.

## Offene Aufgaben

- [ ] Kalani fragen: wie viele KPV Bottles bei ZY bestellen? Dann ZY Reply senden mit Menge #hoch
- [ ] Thymosin-Kunde Compensation-Nachricht an Christian in Slack schreiben #hoch
- [ ] Affiliate Valko_body: nächste Schritte klaeren (Onboarding, Konditionen) #mittel
- [ ] Call mit Kalani planen - Übergabe-Stand besprechen (Details: [[coo-aufgaben]]) #mittel
- [ ] Metorik-Zugang einrichten
- [ ] Alternativen Banking-Anbieter für Kartenzahlungen recherchieren
- [ ] Knowledge Base iterativ befuellen

## Kontakte

- [[kalani-ginepri]] CEO
- [[christian-pulse]] Support Bali
- [[kai-pulse]] Lager Appelheim
- [[patrick-pulse]] Developer/Backend
- [[german-pulse]] Website/WordPress
- [[lizzi-pulse]] Design/Labels
