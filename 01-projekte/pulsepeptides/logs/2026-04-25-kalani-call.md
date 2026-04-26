---
typ: meeting-note
datum: 2026-04-25
projekt: "[[pulsepeptides]]"
teilnehmer: ["[[kalani-ginepri]]", "Deniz"]
ort: "Call"
thema: "Zwischenstand-Check Pulse, Pricing-Strategie, Pillar-Struktur, Tool-Entscheidung"
status: offen
uhrzeit: "20:00-21:00"
erstellt: 2026-04-25
aktualisiert: 2026-04-25
quelle: meeting
vertrauen: bestätigt
notizen: "Strategie-Call. Pricing-Phase-1, Pillar-Struktur, Tool-Entscheidung ClickUp. Folgecall zu 2026-04-24 (Kurz-Call) und 2026-04-23 (COO Weekly)."
---

# Kalani Call, 2026-04-25

**Teilnehmer:** Kalani Ginepri, Deniz **Format:** Call (verschoben auf 20:00) **Zeit:** 20:00 - 21:00

---

## Anknüpfung

Direkter Folgecall zu [[2026-04-24-kalani-call]] (Kurz-Call gestern) und [[2026-04-23-kalani-coo-call]] (COO Weekly mit SOPs).

---

## Besprochenes

### Pricing-Strategie

Hauptthema des Calls. Neue Preisliste steht an, Pulse soll nicht billiger werden sondern Premium-Positionierung halten analog Prostamax. Direkter Benchmark ist Biolab Shop.

Analyse läuft in zwei Phasen:

- **Phase 1, jetzt:** nur Rohmaterialkosten. Shipping, Testing, Marketing-Kosten werden bewusst ausgeblendet um sauberen Cost-Floor zu bekommen.
- **Phase 2, später:** Shipping-Kosten separat einrechnen.

Preisstruktur zweigeteilt: Einzelstückpreise und Bulk-Pricing ab ca. 10 Stück.

Pricing-Liste wird Cross-Tool-Use-Case für ClickUp + Google Drive (siehe Framework unten).

### Produkt-Mapping

Welche Produkte sind noch ohne Lab-Test (kein COA/QC) und welche werden neu reingebracht.

Produkte im Scope:

- KPV, beide Formen
- SS-31
- 5-Amino-1 Kapseln
- Thymalin Spritze
- BPC-157

Sourcing-Update: BPC-157 und 5-Amino-1 Kapseln gehen zum neuen Supplier **XiAN Sheerherb**.

### Janoshik Testing Flow

Der automatische Lab-Test-Flow mit Janoshik plus n8n muss zum Laufen kommen. Voraussetzung dafür: Auto-Forwarding der Pulse-Organization-Mailbox auf eine Gmail-Adresse einrichten, damit n8n die eingehenden COA-PDFs automatisch auslesen kann. Aktuell wird das manuell gemacht oder steht still.

### Lager Tschechien

Nächste Woche Tschechien-Lager mit Kapseln befüllen. Operativ Kai-Thema, Deniz koordiniert. Ersetzt den ausgefallenen Eppelheim-Visit.

### Labels AxonPeptides

Labels werden neu gedruckt. Anforderung: Batch-Nummern direkt auf dem Label, nicht mehr separat aufgeklebt. Löst manuelle Nacharbeit von Kai ab. Lizzi macht das Design, [etikettendrucken.de](http://etikettendrucken.de) muss variable Daten unterstützen oder Druckerei-Wechsel prüfen.

### Pillar-Struktur

Sechs operative Pillars für Pulse als Organisations-Schema definiert:

1. **Sales** - Verkauf, Pricing, Custom Orders, B2B-Anfragen
2. **Marketing** - Ads, Content, Branding, Affiliate-Programm
3. **Logistics** - Lager, Supplier, Bestellungen, Versand, Labels, QC
4. **Support** - Kundenservice, Reklamationen, Christian-Koordination
5. **Financials** - Kosten, Margen, Pricing, Buchhaltung
6. **Bureaucracy** - Compliance, Zoll, Behörden, EU-Regulatorik

Pillars decken alle bisherigen COO-Aufgaben ab und werden als Folder-Struktur in ClickUp abgebildet.

---

## Entscheidungen

EntscheidungBegründungStatusClickUp wird primäres Orga-Tool für PulseKein PM-Tool aktuell. Pillars + Tasks + Docs in einem. Slack + Drive-Integration vorhanden.bestätigtPricing-Analyse Phase 1 nur RohmaterialkostenSauberer Cost-Floor ohne Lärm durch Shipping/TestingbestätigtPricing-Strategie Premium analog ProstamaxNicht in Preiskampf gehen, Positionierung haltenbestätigtBiolab Shop als Vergleichs-BenchmarkDirekter Konkurrent, vergleichbares SortimentbestätigtBPC-157 + 5-Amino-1 zu XiAN SheerherbTesting-Badge-SupplierbestätigtJanoshik Auto-Forwarding einrichtenVoraussetzung für n8n-Lab-Flow-AutomatisierungbestätigtLabels mit integrierter Batch-NummerManuelle Nacharbeit Kai eliminierenbestätigt

---

## Strategischer Block: Tool- und Workflow-Architektur

### Status quo

Pulse hat 8 Tools im Stack: Slack, Telegram, Google Sheets (Batch-SSOT, 17 Spalten), PulseBot (n8n), Metorik, Freshdesk, Vercel Admin Hub, 1Password. Kein Projektmanagement-Tool. Aufgaben verteilen sich zwischen Slack-Channels, dem Vault von Deniz und Kalanis Kopf.

### Ziel

ClickUp als zentrale Aufgaben- und Pillar-Schicht. Slack und Drive bleiben Spezial-Tools, ClickUp orchestriert.

### Architektur

```
Quellen (Input)
- Slack-Posts (Christian, Kai, Kalani)
- Voice-Dumps Deniz
- Calls Deniz/Kalani
- E-Mails (Janoshik, Kunden)
        ↓
Routing
- Slack-zu-ClickUp Automation: neue Posts in Operations-Channels werden als Tasks vorgeschlagen
- Manuelle Triage durch Deniz (Miraculix als Filter)
        ↓
ClickUp (Single Source of Action)
- 6 Pillar-Folders mit Listen
- Tasks mit Assignee, Status, Priorität
- Docs für SOPs
- Drive-Files an Tasks (Pricing-Liste, COA, Labels)
        ↓
Output
- Notifications zurück in Slack-Channels
- Status-Sync zu Google Sheets (PulseBot bleibt SSOT für Batches)
- Archivierung im Obsidian Vault über Logs
```

### Automatisierungen die geplant sind

1. **Slack Morning Sweep:** jeden Morgen läuft eine Automation die alle gestern in Operations-Channels geposteten Nachrichten checkt und unklassifizierte Items als ClickUp-Task-Vorschläge in eine Triage-Liste packt. Deniz triagiert dann.
2. **Custom-Order-Form:** Christian erstellt Custom Orders über ClickUp-Form statt Slack-Channel. Form generiert direkt Task in Sales-Liste.
3. **Janoshik COA Import:** Pulse-Organization-Mail Auto-Forward auf Gmail. n8n liest COA-PDF, extrahiert Batch-Daten, erstellt Task in Logistics mit angehängtem PDF.
4. **Pricing-Sheet Live-Sync:** Phase-1-Pricing-Liste in Google Sheets, an Logistics-Task verknüpft. Updates landen automatisch im Task-Comment-Feed.

---

## Roadmap bis nächste Woche

Bis Freitag 2026-05-01 muss das Framework stehen.

WasWerWannClickUp Pulse-Folder mit 6 Pillars + erste TasksDenizerledigt 2026-04-25Slack-ClickUp Integration einrichten (mit Kalani-OK)Denizbis 2026-04-29Google Drive an ClickUp anbinden (Account-Frage klären)Deniz + Kalanibis 2026-04-29Offene COO-Aufgaben aus Vault in ClickUp-Pillars übertragenDenizbis 2026-04-28Pricing-Phase-1: ZY + XiAN-Preislisten ziehenDenizbis 2026-04-30Pricing-Phase-1: Margen-Berechnung pro ProduktDenizbis 2026-05-01Vergleich Biolab Shop Einzel + BulkDenizbis 2026-05-01Janoshik Auto-Forwarding einrichtenKalani + Denizbis 2026-05-01Tschechien-Lager-Befüllung KapselnKai + Deniznächste WocheLabels-Druckerei-Frage klären (variable Batch-Daten)Lizzi + Deniznächste Woche

Bestellungen sind ab nächster Woche operativ wieder dran. Bis dahin steht das Framework.

---

## Nächste Schritte (operativ priorisiert)

### Diese Woche (bis Freitag 01.05.)

- [ ] Slack-ClickUp Integration: Kalani-OK einholen, Integration in Pulse-Slack aktivieren
- [ ] Google-Drive-Account-Frage mit Kalani klären (privater Account, Pulse Workspace neu, oder anders)
- [ ] Drive an ClickUp koppeln
- [ ] Offene COO-Aufgaben aus `coo-aufgaben.md` in ClickUp-Pillars übertragen
- [ ] ZY + XiAN Sheerherb Preislisten ziehen
- [ ] Margen-Berechnung pro Produkt
- [ ] Biolab Shop Preise scrapen (Einzel + Bulk)
- [ ] Pulse-Organization-Mail Auto-Forwarding einrichten

### Nächste Woche

- [ ] Custom-Order-Form in ClickUp bauen
- [ ] Slack Morning Sweep Automation aufsetzen
- [ ] Janoshik COA-Auslese via n8n testen
- [ ] Tschechien-Lager-Übergabe vorbereiten mit Kai
- [ ] Erste Bestellungen über neuen Workflow

### Pausiert

- Persönlicher Transcription-Workflow (ElevenLabs Pipeline) wird verschoben bis Pulse-Framework steht.

### Carry-Over aus laufender COO-Liste

Bleibt offen, wird in ClickUp Pillars überführt:

- Bulk-Pricing-Liste B2B (Christian liefert)
- Pepspan Bulk-Pricing-Anfrage
- Prostamax Custom-Order (Lily-Antwort)
- Affiliate-Framework No-Human-Use
- Banking-Alternative Revolut
- Domain-Transfer GoDaddy
- System-Login-Sweep
