---
typ: wissen
projekt: "[[pulsepeptides]]"
thema: firmenstruktur
status: in_arbeit
erstellt: 2026-04-17
zuletzt_aktualisiert: 2026-04-17
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
- **Shareholder:** Kalani (100%)
- **UBO (Ultimate Beneficial Owner):** formell andere Person eingetragen (Details offen)
- **Steuern:** offen (Zypern-Regelung zu klären)

### 2. Pulse Organization Limited - Revolut Business

- **Funktion:** Annahme von Kartenzahlungen der Kunden
- **Konto:** Revolut Business
- **Inhaber:** Kalani
- **Accountant:** Sultan
- **E-Mail:** [pulseorganization@protonmail.com](mailto:pulseorganization@protonmail.com) (Passwort in 1Password)
- **Compliance-Workaround:** Revolut Business akzeptiert keine Zahlungen für Peptid-Shops. Zahlungen laufen über [pulseprana.com](http://pulseprana.com) (Consulting Service).
- **Pain-Point:** Revolut findet das irgendwann raus. Alternativer Banking-Anbieter muss gefunden werden.

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
Pulse Organization Limited (Revolut Business)
        ↓
Pulse Enterprise Limited (Air Wallet Hongkong, 0% Steuer)
        ↓
Krypto-Kauf für Supplier-Orders
        ↓
Pulse Peptides Limited (Zypern) — operative Bestellungen
```

---

## Compliance-Risiken und Pain-Points

ThemaRisikoStatusRevolut BusinessEntdeckt Peptid-Zahlungen, sperrt KontoAktiv, Lösung offenKrypto-Limit12.000 EUR legal pro Person/JahrAktiv, Lösung offenLager DeutschlandVersand rechtlich nicht zugelassenAktiv, Verlagerung Tschechien Mai 2026Domain GoDaddyCompliance, Transfer steht ausAktivUBO ZypernDetails zu klärenOffen

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

- **Kanal:** Telegram (zwei Gruppen)
- **Supplier 1:** Lab Peptides (schnelle Produktion)
- **Supplier 2:** ZY Peptides (langsame Produktion)
- **Zahlung:** Krypto
- **Krypto-Limit:** 12.000 EUR legal pro Person/Jahr. Aktuelles Restlimit: offen
- **Offene Bestellung:** Tireptide müssen bestellt werden

## Lieferkette

- **Produktion:** China
- **Versandweg:** China, London, Belgien, Europa
- **Lead Time:** 10-18 Tage
- **Lager:** [[kai-pulse]], Appelheim bei Mannheim, Teilzeit
- **Lager-Verlagerung:** Tschechien, Zieldatum Anfang Mai 2026

## Labels

- **Design:** [[lizzi-pulse]] (Freelancer, 30 EUR/h)
- **Druck:** [etikettendrucken.de](http://etikettendrucken.de)
- **Problem:** Batch-Nummern nicht mitdruckbar, nachträglich manuell (aktuell Kai)
- **Offen:** Label-Pipeline automatisieren

## Systeme und Zugänge

SystemFunktionZugang DenizTelegramSupplier-KommunikationvorhandenGoogle SheetsBatch-SSOT (17 Spalten)vorhandenMetorikInventory Managementaktiv (WordPress, 2026-04-17)FreshdeskSupport-Ticketskommt via 1PasswordSlackTeam-Kommunikationvorhanden1PasswordPasswort-Vault KalaniZugriff kommtVercel (Admin Hub)Support-Interfacekommt via 1Password

## Team

PersonRolleOrtStatus[[kalani-ginepri]]CEOvariabelGründerDenizCOOMannheimTransition ab 2026-04-17[[christian-pulse]]SupportBaliTeilzeit[[kai-pulse]]LagerAppelheimTeilzeit[[patrick-pulse]]Developer/BackendvariabelFreelancer[[german-pulse]]Website/WordPressvariabelFreelancer, 30 EUR/h[[lizzi-pulse]]Design/LabelsvariabelFreelancer, 30 EUR/h

## Offen

- Rechtsform-Details Pulse Peptides Limited Zypern (UBO genau)
- Bankverbindung operative Firma
- Krypto-Plattform und Lösung &gt;12k
- Vollständige Preislisten Supplier (Call 14:15)
- Verkaufspreis-Dokumentation
- Alternativer Banking-Anbieter (Revolut-Ersatz)

## Slack-Workspace Struktur

### Operations (COO relevant)

ChannelZweckWer#generalTeam-Kommunikation allgemeinAlle#inventoryLagerbestand (alt)Kai, Team#inventory-Lagerbestand (neu, zu mergen mit #inventory)Kai, Team#backordersNachbestellungenKai, COO#custom-order-requestsManual/Custom OrdersChristian, Kai, COO#failed-shipmentsDefekte und fehlgeschlagene LieferungenChristian, Kai#csupport-generalCustomer Support allgemeinChristian#csupport-shipmentsSupport VersandfragenChristian#financialFinanzen allgemeinKalani, COO#crypto-paymentsKrypto-ZahlungenKalani, COO#forwardingZweck unklar, zu klären-#shipping-costs-changeVersandkosten-ÄnderungenKai#affiliate-programmAffiliate-ProgrammKalani#office-eppelheimKais Lager AppelheimKai

### Automatisierte Channels (n8n Flows)

ChannelZweck#jumingoMetorik-Exporte via n8n automatisch#dhlDHL-Daten via n8n automatisch

### Entwicklung/Tech

ChannelZweckWer#backendServer und BackendPatrick#webdevWebsite WordPressGerman#aidevKI-AutomatisierungenDeniz, Kalani#adminhubphase1Admin Hub EntwicklungForster Labs#customer-supprt-hubdevSupport Hub EntwicklungForster Labs#qcanalyticsQC und AnalyticsKalani#workflow_testingDeniz Testing-ChannelDeniz

### Sonstiges

ChannelZweckWer#virtual-assistantFreelancer für Monkey TasksRasmus Madsen#goggleadsGoogle AdsKalani#randomSmalltalkAlle

### Offene Punkte Slack-Struktur

- #inventory und #inventory- sollten gemergt werden (Kalani hat das erwähnt)
- #forwarding Zweck unklar, mit Kalani klären
- #shipping-costs-change Zweck unklar, mit Kai klären
- Projektmanagement-Tool noch nicht definiert (steht in [coo-aufgaben.md](http://coo-aufgaben.md))
