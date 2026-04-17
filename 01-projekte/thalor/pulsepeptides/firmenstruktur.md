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

### 1. Pulse Peptides Limited — Zypern

- **Funktion:** operative Firma, über die bestellt und das Geschäft geführt wird
- **Registrierung:** Zypern
- **Shareholder:** Kalani (100%)
- **UBO (Ultimate Beneficial Owner):** formell andere Person eingetragen (Details offen)
- **Steuern:** offen (Zypern-Regelung zu klären)

### 2. Pulse Organization Limited — Revolut Business

- **Funktion:** Annahme von Kartenzahlungen der Kunden
- **Konto:** Revolut Business
- **Registrierung:** offen
- **Inhaber:** Kalani
- **Accountant:** Sultan
- **Compliance-Workaround:** Revolut Business akzeptiert keine Zahlungen für Peptid-Shops. Zahlungen laufen deshalb über **pulseprana.com** (Consulting Service), also werden als Consulting-Zahlungen deklariert.
- **Pain-Point:** Revolut findet das irgendwann raus. Alternativer Banking-Anbieter für Kartenzahlungen muss gefunden werden bevor das passiert.

### 3. Pulse Enterprise Limited — Hongkong / Air Wallet

- **Funktion:** Lagerung und Empfang von Geld (kein operatives Geschäft)
- **Konto:** Air Wallet, Hongkong
- **Registrierung:** Hongkong
- **Inhaber:** Kalani
- **Steuern:** 0% (Hongkong-Regelung)
- **Geldfluss:** Geld von Revolut Business wird hierher transferiert und dort gelagert

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

| Thema | Risiko | Status |
|---|---|---|
| Revolut Business | Entdeckt Peptid-Zahlungen, sperrt Konto | Aktiv, Lösung offen |
| Krypto-Limit | 12.000 EUR legal pro Person/Jahr, skaliert nicht | Aktiv, Lösung offen |
| Lager Deutschland | Versand rechtlich nicht zugelassen | Aktiv, Verlagerung Tschechien Mai 2026 |
| Domain GoDaddy | Compliance, Transfer steht aus | Aktiv |
| UBO Zypern | Details zu klären | Offen |

---

## Website und Shop

- **Domain:** pulsepeptides.com, aktuell bei GoDaddy (Transfer steht aus)
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

- **Tool:** Motific
- **Zugang:** kommt über 1Password Vault von Kalani
- **Einführung:** Call 2026-04-17

## Order Management

- **Kanal:** Telegram (zwei Gruppen)
- **Supplier 1:** Lab Peptides
- **Supplier 2:** ZY Peptides
- **Zahlung:** Krypto
- **Krypto-Limit:** 12.000 EUR legal pro Person/Jahr. Aktuelles Restlimit: offen (Call 2026-04-17)

## Lieferkette

- **Produktion:** China
- **Versandweg:** China, London, Belgien, Europa
- **Lead Time:** 10-18 Tage
- **Lager:** [[kai-pulse]], Appelheim bei Mannheim, Teilzeit
- **Lager-Verlagerung:** Tschechien, Zieldatum Anfang Mai 2026

## Labels

- **Design:** [[lizzi-pulse]] (Freelancer, 30 EUR/h)
- **Druck:** etikettendrucken.de
- **Problem:** Batch-Nummern nicht mitdruckbar, nachträglich manuell (aktuell Kai)
- **Offen:** Label-Pipeline automatisieren

## Systeme und Zugänge

| System | Funktion | Zugang Deniz |
|---|---|---|
| Telegram | Supplier-Kommunikation | vorhanden |
| Google Sheets | Batch-SSOT (17 Spalten) | vorhanden |
| Motific | Inventory Management | kommt via 1Password |
| Freshdesk | Support-Tickets | kommt via 1Password |
| Slack | Team-Kommunikation | vorhanden |
| 1Password | Passwort-Vault Kalani | Zugriff kommt |
| Vercel (Admin Hub) | Support-Interface | kommt via 1Password |

## Team

| Person | Rolle | Ort | Status |
|---|---|---|---|
| [[kalani-ginepri]] | CEO | variabel | Gründer |
| Deniz | COO (informell) | Mannheim | Transition ab 2026-04-17 |
| [[christian-pulse]] | Support | Bali | Teilzeit |
| [[kai-pulse]] | Lager | Appelheim | Teilzeit |
| [[patrick-pulse]] | Developer/Backend | variabel | Freelancer |
| [[german-pulse]] | Website/WordPress | variabel | Freelancer, 30 EUR/h |
| [[lizzi-pulse]] | Design/Labels | variabel | Freelancer, 30 EUR/h |

## Offen

- Rechtsform-Details Pulse Peptides Limited Zypern (UBO genau, Kalanis genaue Position)
- Bankverbindung der operativen Firma (Pulse Peptides Limited)
- Konkrete Krypto-Plattform und Lösung >12k
- Vollständige Preislisten der Supplier
- Verkaufspreis-Dokumentation (Bulk-Preise, Strategien)
- Alternativer Banking-Anbieter für Kartenzahlungen (Revolut-Ersatz)
