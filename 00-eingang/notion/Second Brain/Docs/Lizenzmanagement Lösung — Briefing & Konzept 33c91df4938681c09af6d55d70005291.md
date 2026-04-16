# Lizenzmanagement Lösung — Briefing & Konzept

Created: 8. April 2026 23:42
Doc ID: DOC-20
Doc Type: Briefing
Gelöscht: No
Last Edited: 8. April 2026 23:42
Lifecycle: Active
Notes: Konzeptpapier für Christine Kampmann. Basis für Pitch an internen Power BI Experten. Dokumentiert Ist-Zustand, 3 Kernprobleme, Ziel-Architektur. Volatile weil aktiv in Bearbeitung.
Pattern Tags: Reporting
Project: HAYS CEMEA (../Projects/HAYS%20CEMEA%2033c91df4938681a2bb83c4c3998f67a5.md)
Stability: Volatile
Stack: Power Automate, SharePoint
Verified: No

## Scope

Arbeitsbereich für das Konzeptpapier an Christine Kampmann. Basis für den Pitch an den internen Power BI Experten. Dokumentiert den Ist-Zustand, die Probleme und die Ziel-Lösung.

## Architecture / Constitution

- **Bestehende Flows bleiben erhalten:** Die 7 Power Automate Flows funktionieren und werden NICHT ersetzt. Die neue Reporting-Lösung muss mit ihnen kompatibel sein.
- **Power BI als Reporting-Layer:** Dashboard liest aus konsolidierter Datenquelle, schreibt nicht zurück (initial).
- **Rollenbasierter Zugriff:** Manager sieht nur eigenes Land, CEMEA-Management sieht alles.

## Kontext: Was ist das HAYS CEMEA Lizenzmanagement?

Das Lizenzmanagement CEMEA existiert seit ca. 2,5 Jahren. Deniz ist seit ca. 1,5 Jahren dabei (Werkstudent, Mid Office / Backoffice). Kernaufgabe: Lizenzen für Recruiting-Tools an HAYS-Recruiter in 10 Ländern allokieren — neue Lizenzen vergeben, Umschreibungen durchführen, Entziehungen verwalten, und das Management mit Reports versorgen.

**10 Länder (CEMEA-Scope):** Deutschland, Polen, Spanien, Frankreich, Niederlande, Belgien, Luxemburg, Tschechien, Ungarn, Rumänien (+ weitere Regionen)

### Verwaltete Produkte

| Produkt | Anbieter | CEMEA-Scope? | Identifier im Report |
| --- | --- | --- | --- |
| RPS (Recruiter Professional Services) | LinkedIn | ✅ Primär | Beschreibungsfeld (Workaround!) |
| Sales Navigator | LinkedIn | ✅ Primär | E-Mail-Adresse direkt |
| LTI (Talent Insights) | LinkedIn | ✅ Primär | E-Mail-Adresse direkt |
| StepStone Talent Finder | StepStone | ✅ | E-Mail direkt (andere Report-Logik) |
| Indeed Smart Sourcing | Indeed | ✅ | E-Mail direkt |
| Xing Talent Manager | Xing | ✅ (nur DE) | Xing-Profil (keine HAYS-Mail!) |
| SalesCloud | Salesforce | ✅ | — |
| Freelancermap / FreelanceDe | Dritte | ✅ | — |

## Ist-Zustand: Die Masterslide-Struktur

### Was ist die Masterslide?

Die Masterslide ist die aktuelle **Single Source of Truth** für die Lizenzzuweisung. Sie ist ein Excel-Workbook pro Land mit mehreren Reitern — je ein Reiter pro Produkt.

- **Pro Land:** 1 Excel-Workbook mit bis zu 15 Reitern
- **Pro Reiter (Produkt):** Nutzerliste + monatliche Usage-Ratings

### Masterslide-Spaltenstruktur (vollständig, aus CS-Analyse)

| Spalte | Beschreibung | Beispiel |
| --- | --- | --- |
| BU | Business Unit | CS |
| Bereich | Bereichsleiter-Ebene | Marcel Bodenbenner |
| Abteilung | Abteilungsleiter | Eric Kadar |
| Team Lead | Direkter Vorgesetzter | Michael Gotzmann |
| Rolle | Job-Titel des Nutzers | Principal Consultant |
| Skill | Recruiting-Skill-Typ | CUP |
| Vertragsart | PER / TEM / CON | PER |
| Kürzel | 4-Buchstaben Mitarbeiter-Kürzel | AAHC |
| Name | Vollname | Anna-Sophie Hochwald |
| Email | HAYS-Email-Adresse | [anna-sophie.hochwald@hays.de](mailto:anna-sophie.hochwald@hays.de) |
| JobSlot | Hat JobSlot-Lizenz? | JA / NEIN |
| Aktivierungsdatum | Datum der Lizenz-Aktivierung | 11.07.2023 |
| Feb 26, Jan 26, ... | Monatliche Usage-Ratings | high / medium / low / no_usage |

**Rating-Schema (Ampel):**

- `high` — hohe Nutzung
- `medium` — mittlere Nutzung
- `low` — niedrige Nutzung
- `no_usage` — keine Aktivität in diesem Monat

### Inkonsistenz zwischen Ländern

- **Deutschland (CS):** 15 Reiter (RPS, Talent Insights, SalesNav, XTM, StepStone, Indeed, Xing Premium, SalesCloud, Index, Freelancermap, FreelanceDe, Tandems, masterslide_insert, rps_salesnav_indeed, Warteliste)
- **Polen:** 5 Reiter (RPS, SalesNav, LTI, rps_salesnav_indeed, RPO)

→ **Kein einheitliches Schema.** Jedes Land hat unterschiedliche Produkte und teilweise unterschiedliche Spaltenstrukturen.

## Ist-Zustand: Die Report-Quellen

Jeder Vendor liefert monatlich einen Usage-Report. Diese Reports werden manuell verarbeitet und in die Masterslides eingetragen. Aktuell 5 verschiedene Report-Formate.

### 1. LinkedIn RPS — Haupt-Problem-Report

**Format:** Excel-Export aus LinkedIn Admin Center

**Felder:** Lizenznehmer:in, Lizenznummer, Bundesland (=Status), Vertrag (=Land), **Beschreibung (= Email, Workaround!)**, Usertyp, Lizenz:Standort, Lizenz:Account-Center-Gruppen, Aktive Tage, Profilansichten, Suchanfragen, InMails, KI-Suchanfragen, InMail-Antwortrate, Rating

**Das Problem:** LinkedIn spielt beim RPS die Email-Adresse **nicht direkt aus**. Die Email steht im Feld `Beschreibung` — aber nur wenn sie manuell eingetragen wurde. Deniz trägt kurz vor Monatsende bei allen Nutzern die Email in das Beschreibungsfeld ein (CSV-Upload), damit der Monats-Report über die Email gematcht werden kann.

→ Zeitintensiver manueller Workaround, fehleranfällig, nie 100% vollständig.

### 2. LinkedIn Sales Navigator — Sauberster Report

**Format:** CSV-Export

**Felder:** Lizenznummer, Mitarbeiter-ID, **E-Mail-Adresse** (direkt!), Name, Lizenztyp, Status, Eingeladen am, Aktiviert am, Entfernt am, Tage aktiv, Suchanfragen, Profilbesuche, Gespeicherte Leads, InMails, InMail-Annahmequote, + Group/Land-Spalten (50+ Länder)

**Matching:** Email direkt verfügbar — kein Problem

### 3. StepStone — Anderes Konzept

**Format:** Excel-Export

**Felder:** Login, Mail, Candidate ID, UNLOCK (=Anzahl)

**Besonderheit:** Kein Usage-Rating. StepStone zählt monatliche Candidate-Unlocks. Deniz erstellt daraus manuell eine Unlock-Übersicht. Reporting-Logik komplett anders als bei LinkedIn.

**Matching:** Mail direkt verfügbar

### 4. Xing Talent Manager — Größtes Problem

**Format:** Excel-Export ("Ihre Kollegen")

**Felder:** Xing-Profilname, Team-Statistiken, **keine HAYS-Email-Spalte**

**Das Problem:** Xing verknüpft Lizenzen mit dem Xing-Profil, nicht mit der HAYS-Email. Es ist **nicht möglich**, die HAYS-Email automatisch auszuspielen. Matching nur über manuelle Zuordnung Name ↔ Email.

### 5. Indeed Smart Sourcing

**Matching:** Email direkt verfügbar

## Ist-Zustand: Die Automatisierung (Power Automate)

Deniz hat 7 Power Automate Flows gebaut, die den Lizenz-Workflow teilautomatisieren:

| Flow | Funktion |
| --- | --- |
| Transfer Flow (×14) | SPOC-Anfragen automatisch in Admin-Liste übertragen |
| Ready Check | Nutzer gegen Masterslide validieren |
| Master Execute | Masterslide-Eintrag schreiben + Onboarding-Mail |
| DocuSign Initial | Policy-Unterzeichnung anfordern |
| DocuSign Reminder | Erinnerung Policy |
| Activation Reminder | Lizenz-Aktivierungserinnerung |
| Complete Request | Ticket abschließen |
| Cancel Request | Stornierung |

**Wichtig für die Lösung:** Die Flows existieren bereits und funktionieren. Die neue Reporting-Lösung muss mit ihnen kompatibel sein, nicht sie ersetzen.

## Die drei zentralen Probleme (Ist-Zustand)

### Problem 1: Keine einheitliche Nutzerdatenbank

14 separate SPOC-Listen + 10 separate Masterslides in Excel = keine zentrale, konsolidierte Nutzerdatenbank. Wer hat welche Lizenz? Über welches Land? Seit wann? — Aktuell nur über manuelle Excel-Recherche beantwortbar.

### Problem 2: Kein einheitlicher Identifier über alle Produkte

| Produkt | Identifier | Problem |
| --- | --- | --- |
| RPS | Email (manuell hinterlegt) | Monatlicher Workaround nötig |
| Sales Navigator | Email (direkt) | Kein Problem |
| LTI | Email (direkt) | Kein Problem |
| StepStone | Email (direkt) | Anderes Reporting-Format |
| Indeed | Email (direkt) | Kein Problem |
| Xing | Xing-Profil | **Keine HAYS-Email auszuspielen** |

→ Kein einheitlicher Identifier = kein automatischer Cross-Product-Match möglich.

### Problem 3: Kein konsolidiertes Reporting

Jeder Report hat ein anderes Format, andere KPIs, andere Granularität. Aktuell:

- LinkedIn RPS → manuell in Masterslide rating eintragen
- LinkedIn SalesNav → manuell auswerten
- StepStone → separates monatliches Unlock-Reporting
- Xing → manuell, schwer matchbar

Fehlt: Ein konsolidiertes Dashboard, das alle Produkte in einem einheitlichen Schema zeigt.

## Ziel-Lösung: Was gebaut werden soll

### Vision

Ein **zentrales Power BI Dashboard** (oder vergleichbare Lösung), das:

1. **Nutzerdatenbank:** Alle Lizenznehmer CEMEA-weit in einer konsolidierten Datenbank
2. **Status Quo Lizenz-Allokation:** Wer hat welche Lizenz, in welchem Land, welches Produkt, seit wann
3. **Reporting:** Alle monatlichen Reports der 6 Produkte in einem einheitlichen Schema
4. **Ampel-System:** Einheitliches Rating high/medium/low/no_usage, anwendbar auf alle Produkte
5. **Rollenbasierter Zugriff:** Manager aus Spanien sehen nur Spanien; Deutschland nur Deutschland; CEMEA-Management sieht alles
6. **Flow-Kompatibilität:** Bestehende PA-Flows bleiben erhalten; Dashboard als Reporting-Layer dazu

### Datenfluss-Architektur (Ziel)

```
Vendor-Reports (monatlich)
    ├─ LinkedIn RPS CSV
    ├─ LinkedIn SalesNav CSV
    ├─ LinkedIn LTI CSV
    ├─ StepStone XLSX
    ├─ Indeed CSV
    └─ Xing XLSX
            ↓
    ETL / Data Prep
    (Normalisierung auf einheitliches Schema)
            ↓
    Zentrales Datenmodell
    (1 Nutzerdatenbank + Lizenz-Status-Tabelle + monatliche Nutzungsdaten)
            ↓
    Power BI Dashboard
    ├─ Lizenz-Übersicht (Allokation, Status quo)
    ├─ Usage-Reporting (Ampel, alle Produkte)
    ├─ Kosten-Übersicht (gekaufte Lizenzen vs. genutzte Lizenzen)
    └─ Rollenbasiert: Land-Manager sieht nur eigenes Land
```

### Einheitliches Daten-Schema (Ziel)

```
Nutzer-Record:
  - HAYS Email (Primärer Identifier)
  - Name, Kürzel
  - BU, Bereich, Abteilung, Team Lead
  - Land / Region
  - Rolle, Vertragsart

Lizenz-Record:
  - Nutzer-Email
  - Produkt (RPS / SalesNav / LTI / StepStone / Indeed / Xing)
  - Status (Aktiv / Inaktiv / Ausstehend)
  - Aktivierungsdatum
  - Monatlicher Usage-Rating (high / medium / low / no_usage)
  - Lizenz-Kosten
```

## Open Questions

| Frage | Kontext |
| --- | --- |
| Xing-Email-Problem | Xing spielt keine HAYS-Email aus. Manuelle Zuordnung oder alternative Lösung? |
| RPS Email-Workaround | Kann LinkedIn-seitig die Email dauerhaft hinterlegt werden, oder ist CSV-Upload dauerhaft nötig? |
| Datenquelle | SharePoint als Datenquelle für Power BI? Oder direkte CSV-Imports? |
| Flow-Integration | Soll Power BI auch schreibend auf die Masterslide zugreifen, oder nur lesend/reporting? |
| Historische Daten | Wie weit soll die Datenmigration rückwirkend gehen? |
| Update-Frequenz | Dashboard real-time (SharePoint-Anbindung) oder monatlicher Refresh nach Report-Import? |

## Lizenzmengen (Größenordnung für das Briefing)

| Scope | Geschätzte Lizenzen |
| --- | --- |
| Deutschland gesamt | ~800 Lizenzen |
| CEMEA gesamt | ~2.500 Lizenzen |

*Genaue Zahlen muss Christine im Briefing ergänzen.*