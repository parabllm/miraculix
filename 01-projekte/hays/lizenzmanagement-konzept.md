---
typ: aufgabe
name: "HAYS Lizenzmanagement-Konzept"
projekt: "[[hays]]"
status: in_arbeit
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: ["[[christine-kampmann]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Konzeptpapier für Christine Kampmann als Basis für Pitch an internen Power-BI-Experten. Ist-Zustand, 3 Kernprobleme, Ziel-Architektur. Stand 2026-04-08.

## Architektur-Prinzipien

- **Bestehende Flows bleiben erhalten:** Die 7 Power Automate Flows funktionieren, werden NICHT ersetzt. Neue Reporting-Lösung muss kompatibel sein.
- **Power BI als Reporting-Layer:** Dashboard liest aus konsolidierter Datenquelle, schreibt nicht zurück (initial).
- **Rollenbasierter Zugriff:** Manager sieht nur eigenes Land, CEMEA-Management sieht alles.

## Kontext

Lizenzmanagement CEMEA existiert seit ~2,5 Jahren. Deniz ist seit ~1,5 Jahren dabei (Werkstudent Mid Office / Backoffice). Kernaufgabe: Lizenzen für Recruiting-Tools an HAYS-Recruiter in 10 Ländern allokieren - neue Lizenzen vergeben, Umschreibungen, Entziehungen, Management mit Reports versorgen.

**10 Länder (CEMEA-Scope):** Deutschland, Polen, Spanien, Frankreich, Niederlande, Belgien, Luxemburg, Tschechien, Ungarn, Rumänien (+ weitere Regionen)

### Verwaltete Produkte

| Produkt | Anbieter | CEMEA-Scope | Identifier im Report |
|---|---|---|---|
| RPS (Recruiter Professional Services) | LinkedIn | Primär | Beschreibungsfeld (Workaround) |
| Sales Navigator | LinkedIn | Primär | E-Mail direkt |
| LTI (Talent Insights) | LinkedIn | Primär | E-Mail direkt |
| StepStone Talent Finder | StepStone | Ja | E-Mail direkt (andere Report-Logik) |
| Indeed Smart Sourcing | Indeed | Ja | E-Mail direkt |
| Xing Talent Manager | Xing | Nur DE | Xing-Profil (keine HAYS-Mail) |
| SalesCloud | Salesforce | Ja | - |
| Freelancermap / FreelanceDe | Dritte | Ja | - |

## Ist-Zustand: Masterslide-Struktur

### Was ist die Masterslide?

Aktuelle **Single Source of Truth** für Lizenzzuweisung. Excel-Workbook pro Land mit mehreren Reitern - je ein Reiter pro Produkt.

- Pro Land: 1 Excel-Workbook mit bis zu 15 Reitern
- Pro Reiter (Produkt): Nutzerliste + monatliche Usage-Ratings

### Masterslide-Spalten

| Spalte | Beschreibung | Beispiel |
|---|---|---|
| BU | Business Unit | CS |
| Bereich | Bereichsleiter-Ebene | Marcel Bodenbenner |
| Abteilung | Abteilungsleiter | Eric Kadar |
| Team Lead | Direkter Vorgesetzter | Michael Gotzmann |
| Rolle | Job-Titel | Principal Consultant |
| Skill | Recruiting-Skill-Typ | CUP |
| Vertragsart | PER / TEM / CON | PER |
| Kürzel | 4-Buchstaben-Kürzel | AAHC |
| Name | Vollname | Anna-Sophie Hochwald |
| Email | HAYS-Email | anna-sophie.hochwald@hays.de |
| JobSlot | JobSlot-Lizenz? | JA / NEIN |
| Aktivierungsdatum | Datum Lizenz-Aktivierung | 11.07.2023 |
| Feb 26, Jan 26, ... | Monatliche Usage-Ratings | high / medium / low / no_usage |

**Rating-Ampel:** `high` / `medium` / `low` / `no_usage`

### Inkonsistenz zwischen Ländern

- **DE (CS):** 15 Reiter (RPS, Talent Insights, SalesNav, XTM, StepStone, Indeed, Xing Premium, SalesCloud, Index, Freelancermap, FreelanceDe, Tandems, masterslide_insert, rps_salesnav_indeed, Warteliste)
- **Polen:** 5 Reiter (RPS, SalesNav, LTI, rps_salesnav_indeed, RPO)

→ Kein einheitliches Schema. Unterschiedliche Produkte + teils unterschiedliche Spaltenstrukturen.

## Ist-Zustand: Report-Quellen

### 1. LinkedIn RPS - Hauptproblem

LinkedIn spielt Email beim RPS **nicht direkt aus**. Email steht im Feld `Beschreibung` - aber nur wenn manuell eingetragen. Deniz trägt vor Monatsende bei allen Nutzern die Email in Beschreibung ein (CSV-Upload), damit Monats-Report über Email gematcht werden kann.

→ Zeitintensiver manueller Workaround, fehleranfällig, nie 100% vollständig.

### 2. LinkedIn Sales Navigator - Sauberster Report

CSV-Export mit E-Mail-Adresse direkt. Kein Problem.

### 3. StepStone - Anderes Konzept

Excel-Export: Login, Mail, Candidate ID, UNLOCK (Anzahl). **Kein Usage-Rating.** StepStone zählt monatliche Candidate-Unlocks. Deniz erstellt daraus manuell eine Unlock-Übersicht. Reporting-Logik komplett anders.

### 4. Xing Talent Manager - Größtes Problem

Excel-Export: Xing-Profilname, Team-Statistiken, **keine HAYS-Email-Spalte**. Xing verknüpft Lizenzen mit Xing-Profil, nicht HAYS-Email. **Nicht möglich HAYS-Email automatisch auszuspielen.** Matching nur über manuelle Zuordnung Name ↔ Email.

### 5. Indeed Smart Sourcing

Email direkt verfügbar.

## Die drei zentralen Probleme

### Problem 1: Keine einheitliche Nutzerdatenbank

14 separate SPOC-Listen + 10 separate Masterslides in Excel = keine zentrale, konsolidierte Nutzerdatenbank. Wer hat welche Lizenz? Über welches Land? Seit wann? Aktuell nur über manuelle Excel-Recherche beantwortbar.

### Problem 2: Kein einheitlicher Identifier über alle Produkte

| Produkt | Identifier | Problem |
|---|---|---|
| RPS | Email (manuell hinterlegt) | Monatlicher Workaround nötig |
| Sales Navigator | Email (direkt) | Kein Problem |
| LTI | Email (direkt) | Kein Problem |
| StepStone | Email (direkt) | Anderes Reporting-Format |
| Indeed | Email (direkt) | Kein Problem |
| Xing | Xing-Profil | Keine HAYS-Email auszuspielen |

→ Kein einheitlicher Identifier = kein automatischer Cross-Product-Match möglich.

### Problem 3: Kein konsolidiertes Reporting

Jeder Report hat ein anderes Format, andere KPIs, andere Granularität. Fehlt: Ein konsolidiertes Dashboard, das alle Produkte in einem einheitlichen Schema zeigt.

## Ziel-Lösung: Power BI Dashboard

### Vision

1. **Nutzerdatenbank:** Alle Lizenznehmer CEMEA-weit konsolidiert
2. **Status Quo Lizenz-Allokation:** Wer, wo, welches Produkt, seit wann
3. **Reporting:** Alle monatlichen Reports der 6 Produkte in einheitlichem Schema
4. **Ampel-System:** Einheitliches Rating high/medium/low/no_usage
5. **Rollenbasierter Zugriff:** Manager aus Spanien sehen nur Spanien, CEMEA-Management sieht alles
6. **Flow-Kompatibilität:** Bestehende PA-Flows bleiben, Dashboard als Reporting-Layer dazu

### Datenfluss-Architektur

```
Vendor-Reports (monatlich)
    ├─ LinkedIn RPS CSV
    ├─ LinkedIn SalesNav CSV
    ├─ LinkedIn LTI CSV
    ├─ StepStone XLSX
    ├─ Indeed CSV
    └─ Xing XLSX
            ↓
    ETL / Data Prep (Normalisierung auf einheitliches Schema)
            ↓
    Zentrales Datenmodell
    (1 Nutzerdatenbank + Lizenz-Status-Tabelle + monatliche Nutzungsdaten)
            ↓
    Power BI Dashboard
    ├─ Lizenz-Übersicht (Allokation, Status quo)
    ├─ Usage-Reporting (Ampel, alle Produkte)
    ├─ Kosten-Übersicht (gekauft vs. genutzt)
    └─ Rollenbasiert: Land-Manager sieht nur eigenes Land
```

### Einheitliches Daten-Schema

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
|---|---|
| Xing-Email-Problem | Xing spielt keine HAYS-Email aus. Manuelle Zuordnung oder alternative Lösung? |
| RPS Email-Workaround | Kann LinkedIn-seitig Email dauerhaft hinterlegt werden, oder CSV-Upload dauerhaft nötig? |
| Datenquelle | SharePoint als Datenquelle für Power BI? Oder direkte CSV-Imports? |
| Flow-Integration | Soll Power BI auch schreibend auf Masterslide zugreifen oder nur lesend? |
| Historische Daten | Wie weit soll Datenmigration rückwirkend gehen? |
| Update-Frequenz | Real-time (SharePoint-Anbindung) oder monatlicher Refresh? |

## Lizenzmengen

- Deutschland gesamt: ~800 Lizenzen
- CEMEA gesamt: ~2.500 Lizenzen

(Genaue Zahlen muss Christine im Briefing ergänzen.)
