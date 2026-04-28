---
typ: wissen
projekt: "[[pulsepeptides]]"
thema: firmenstruktur
status: in_arbeit
erstellt: 2026-04-17
zuletzt_aktualisiert: 2026-04-28
vertrauen: extrahiert
quelle: voice_dump
---

# PulsePeptides Firmenstruktur

Quelle: Onboarding-Calls mit Kalani 2026-04-16 und 2026-04-17. Wird iterativ ergänzt.

---

## Unternehmensstruktur

Drei separate Entitäten mit unterschiedlichen Funktionen:

### 1. Pulse Peptides Limited - Zypern

- **Funktion:** operative Firma, über die bestellt und das Geschäft geführt wird
- **Registrierung:** Zypern
- **Adresse:** Kalymnou, Q MERITO, 4th floor Agios Nikolaos, Kamares, 6037 Larnaca, Cyprus
- **Shareholder:** Kalani (100%)
- **UBO (Ultimate Beneficial Owner):** formell andere Person eingetragen (Details offen)
- **Steuern:** offen (Zypern-Regelung zu klären)
- **Verwendung Operations:** Druckerei-Bestellungen (Vials, Kapsel-Bottles, Bac-Water-Bottles) laufen über Pulse Peptides Cyprus
- **Hinweis:** Maman-Angebot (2026-03-30) ist an "PULSPEPTIDES Ltd." (sic, ohne E) adressiert, vermutlich Tippfehler von Maman. Korrekte Schreibweise mit Mandak klaeren bevor Vertrag.

### 2. Pulse Organization Limited - England (UK)

- **Funktion:** Annahme von Kartenzahlungen der Kunden, Rechnungsstellung an Lieferanten und Druckereien
- **Registrierung:** England (UK)
- **Konto:** Revolut Business
- **Inhaber:** Kalani
- **Accountant:** Sultan
- **E-Mail:** [pulseorganization@protonmail.com](mailto:pulseorganization@protonmail.com) (Passwort in 1Password)
- **Compliance-Workaround:** Revolut Business akzeptiert keine Zahlungen für Peptid-Shops. Zahlungen laufen über [pulseprana.com](http://pulseprana.com) (Consulting Service).
- **Pain-Point:** Revolut findet das irgendwann raus. Alternativer Banking-Anbieter muss gefunden werden.
- **Stand 2026-04-28:** Rechnungen für Druckerei-Bestellungen werden über die UK-Entitaet gestellt, Bezahlung erfolgt über Pulse Cyprus.

### 3. Pulse Enterprise Limited - Hongkong / Air Wallet

- **Funktion:** Lagerung und Empfang von Geld (kein operatives Geschäft)
- **Konto:** Air Wallet, Hongkong
- **Registrierung:** Hongkong
- **Inhaber:** Kalani
- **Steuern:** 0% (Hongkong-Regelung)
- **Geldfluss:** Geld von Revolut Business wird hierher transferiert

---

## Geldfluss-Übersicht

```
Kunde zahlt per Karte
        ↓
pulseprana.com (Consulting-Tarnung)
        ↓
Pulse Organization Limited UK (Revolut Business)
        ↓
Pulse Enterprise Limited (Air Wallet Hongkong, 0% Steuer)
        ↓
Krypto-Kauf für Supplier-Orders
        ↓
Pulse Peptides Limited (Zypern) — operative Bestellungen
```

---

## Compliance-Risiken und Pain-Points

| Thema | Risiko | Status |
|---|---|---|
| Revolut Business | Entdeckt Peptid-Zahlungen, sperrt Konto | Aktiv, Lösung offen |
| Krypto-Limit | 12.000 EUR legal pro Person/Jahr | Aktiv, Lösung offen |
| Lager Deutschland | Versand rechtlich nicht zugelassen | Aktiv, Verlagerung Tschechien Mai 2026 |
| Domain GoDaddy | Compliance, Transfer steht aus | Aktiv |
| UBO Zypern | Details zu klären | Offen |

---

## Website und Shop

- **Domain:** [pulsepeptides.com](http://pulsepeptides.com), aktuell bei GoDaddy (Transfer steht aus)
- **Stack:** WordPress plus Elementor plus WooCommerce
- **Hosting:** VPS (VPS4U), Backups dort
- **Verantwortlich Website:** [[german-pulse]] (Freelancer, 30 EUR/h)
- **Verantwortlich Backend/Server:** [[patrick-pulse]] (Freelancer)

## Admin Hub

- **Hosting:** Vercel
- **Entwicklung:** externe Firma (beauftragt)
- **Funktion:** Freshdesk-Tickets plus TypeMail, Arbeitsfläche für [[christian-pulse]]
- **Custom Orders:** Christian pusht in Slack-Channel #custom-orders

## Inventory Management

- **Tool:** Metorik
- **Zugang:** über WordPress (Deniz angemeldet 2026-04-17)
- **E-Mail:** [pulseorganization@protonmail.com](mailto:pulseorganization@protonmail.com) (Passwort in 1Password)
- **Inventar:** nach Anmeldung sichtbar, Details im Call 14:15

## Order Management

- **Kanal:** Telegram (zwei Gruppen) plus WhatsApp (XiAN Sheerherb)
- **Supplier 1:** Lab Peptides (schnelle Produktion)
- **Supplier 2:** ZY Peptides (langsame Produktion)
- **Supplier 3:** XiAN Sheerherb (Kapseln plus Vials, Testing-Badge)
- **Zahlung:** Krypto
- **Krypto-Limit:** 12.000 EUR legal pro Person/Jahr. Aktuelles Restlimit: offen
- **Offene Bestellung:** Tireptide müssen bestellt werden

## Lieferkette

- **Produktion:** China
- **Versandweg:** China, London, Belgien, Europa
- **Lead Time:** 10-18 Tage
- **Lager:** [[kai-pulse]], Eppelheim bei Mannheim, Teilzeit
- **Lager-Verlagerung:** Tschechien, Zieldatum Anfang Mai 2026

## Labels und Druckerei

- **Design:** [[lizzi-pulse]] (Freelancer, 30 EUR/h)
- **Aktueller Druck:** [etikettendrucken.de](http://etikettendrucken.de)
- **Aktuelles Format:** 6x9mm Etikett, mit Pinzette zu kleben, sehr fummelig
- **Problem:** Batch-Nummern nicht mitdruckbar, nachträglich manuell (aktuell Kai)
- **Bug 2026-04-28:** 100 Stück Kapsel-Labels mit altem "Hyaluronic Acid"-Text (vor Halal-Wechsel)
- **Referenz:** Lab Peptides druckt Batch-Nummer direkt auf Flasche, Vorbild fuer eigene Loesung

### Druckerei-Sourcing (Stand 2026-04-28)

- **Spec:** 10 ct pro Label, 10.000 Stueck alle 3 Monate, scalable
- **Scope:** Vials plus Bottles fuer Kapseln plus Bac-Water-Bottles
- **Bezahlung:** ueber Pulse Peptides Cyprus
- **Rechnungsstellung:** ueber Pulse Organization Limited UK
- **Aufgabe Deniz:** Druckereien anrufen, Angebote einholen

## Systeme und Zugänge

| System | Funktion | Zugang Deniz |
|---|---|---|
| Telegram | Supplier-Kommunikation | vorhanden |
| WhatsApp | XiAN Sheerherb (Pax) | vorhanden, eSIM |
| Google Sheets | Batch-SSOT (17 Spalten) | vorhanden |
| Metorik | Inventory Management | aktiv (WordPress, 2026-04-17) |
| Freshdesk | Support-Tickets | kommt via 1Password |
| Slack | Team-Kommunikation | vorhanden |
| 1Password | Passwort-Vault Kalani | Zugriff kommt |
| Vercel (Admin Hub) | Support-Interface | kommt via 1Password |

## Team

| Person | Rolle | Ort | Status |
|---|---|---|---|
| [[kalani-ginepri]] | CEO | variabel | Gründer |
| Deniz | COO | Mannheim | Transition ab 2026-04-17 |
| [[christian-pulse]] | Support | Bali | Teilzeit |
| [[kai-pulse]] | Lager | Eppelheim | Teilzeit |
| [[patrick-pulse]] | Developer/Backend | variabel | Freelancer |
| [[german-pulse]] | Website/WordPress | variabel | Freelancer, 30 EUR/h |
| [[lizzi-pulse]] | Design/Labels | variabel | Freelancer, 30 EUR/h |

## Offen

- Rechtsform-Details Pulse Peptides Limited Zypern (UBO genau)
- Bankverbindung operative Firma
- Krypto-Plattform und Lösung &gt;12k
- Vollständige Preislisten Supplier (Call 14:15)
- Verkaufspreis-Dokumentation
- Alternativer Banking-Anbieter (Revolut-Ersatz)

## Slack-Workspace Struktur

### Operations (COO relevant)

| Channel | Zweck | Wer |
|---|---|---|
| #general | Team-Kommunikation allgemein | Alle |
| #inventory | Lagerbestand (alt) | Kai, Team |
| #inventory-Lagerbestand | Lagerbestand (neu, zu mergen mit #inventory) | Kai, Team |
| #backorders | Nachbestellungen | Kai, COO |
| #custom-order-requests | Manual/Custom Orders | Christian, Kai, COO |
| #failed-shipments | Defekte und fehlgeschlagene Lieferungen | Christian, Kai |
| #csupport-general | Customer Support allgemein | Christian |
| #csupport-shipments | Support Versandfragen | Christian |
| #financial | Finanzen allgemein | Kalani, COO |
| #crypto-payments | Krypto-Zahlungen | Kalani, COO |
| #forwarding | Zweck unklar, zu klären | - |
| #shipping-costs-change | Versandkosten-Änderungen | Kai |
| #affiliate-programm | Affiliate-Programm | Kalani |
| #office-eppelheim | Kais Lager Eppelheim | Kai |

### Automatisierte Channels (n8n Flows)

| Channel | Zweck |
|---|---|
| #jumingo | Metorik-Exporte via n8n automatisch |
| #dhl | DHL-Daten via n8n automatisch |

### Entwicklung/Tech

| Channel | Zweck | Wer |
|---|---|---|
| #backend | Server und Backend | Patrick |
| #webdev | Website WordPress | German |
| #aidev | KI-Automatisierungen | Deniz, Kalani |
| #adminhubphase1 | Admin Hub Entwicklung | Forster Labs |
| #customer-supprt-hubdev | Support Hub Entwicklung | Forster Labs |
| #qcanalytics | QC und Analytics | Kalani |
| #workflow_testing | Deniz Testing-Channel | Deniz |

### Sonstiges

| Channel | Zweck | Wer |
|---|---|---|
| #virtual-assistant | Freelancer für Monkey Tasks | Rasmus Madsen |
| #goggleads | Google Ads | Kalani |
| #random | Smalltalk | Alle |

### Offene Punkte Slack-Struktur

- #inventory und #inventory- sollten gemergt werden (Kalani hat das erwähnt)
- #forwarding Zweck unklar, mit Kalani klären
- #shipping-costs-change Zweck unklar, mit Kai klären
- Projektmanagement-Tool noch nicht definiert (steht in [coo-aufgaben.md](http://coo-aufgaben.md))
