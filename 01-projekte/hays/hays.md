---
typ: ueber-projekt
name: "HAYS CEMEA"
aliase: ["HAYS", "HAYS CEMEA", "Hays", "Hays AG"]
bereich: intern
umfang: offen
status: aktiv
kapazitaets_last: mittel
hauptkontakt: "[[christine-kampmann]]"
tech_stack: ["power-automate", "sharepoint", "excel-online", "microsoft-forms", "outlook", "teams"]
erstellt: 2026-04-16
notizen: "Werkstudent-Job bei HAYS AG. Lizenzmanagement CEMEA via 7 Power Automate Flows. Deniz ist sole Administrator."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

Werkstudent-Rolle bei **HAYS AG Mid Office Global License Management**. Kernverantwortung: Lizenzmanagement-Prozess für CEMEA-Recruiter, end-to-end von Anfrage zu DocuSign zu Aktivierung zu Reporting, umgesetzt mit **7 Power Automate Flows**. Plus Konzeptpapier für neue Lizenzmanagement-Lösung (Power-BI-Dashboard).

- **Vorgesetzte:** [[christine-kampmann]] (Primary Contact, aktuell krank)
- **Kollegin:** [[julia-renzikowski]]
- **Interne Ansprechpartnerin:** Simea (Anfragen laufen über sie)
- **Region:** CEMEA (Deutschland wird separat verwaltet)
- **Verwaltete Produkte:** LinkedIn RPS, LinkedIn SalesNav, LinkedIn LTI, StepStone Talent Finder, Indeed Smart Sourcing, Xing Talent Manager
- **Lizenzmengen:** ~800 DE, ~2.500 CEMEA
- **Architektur:** Hub-and-Spoke (14 SPOC-Listen zu 1 zentrale Admin-Liste zu Excel-Masterslides als SSOT)
- **Masterslide-Schema:** `tbl{Product}_{Country}` (z.B. `tblLinkedInRPS_DE`)

**Technische Identifier:**
- SharePoint-Site: `https://haysonline.sharepoint.com/sites/globallicensemanagement/admin`
- Admin-Listen-ID: `623ca4ad-2e5f-47a9-b90a-a007149cde34`
- Mail-Absender: `lizenzmanagement@hays.de`
- Mail-BCC-Onboarding: `Deniz.Oezbek@hays.de`

**Sensible Daten:** HAYS-Events im Calendar = `visibility=private`.

**Karrierepfade bei HAYS (drei Pfade):**
- Sales: Recruiter, Sourcing-Mitarbeiter, Account Manager, Key Account Manager
- Führungskraft: Teamleitung, Bereichsleitung, Abteilungsleitung, Niederlassungsleitung
- Expert: Expert, Senior Expert (Spezialisierung in einem Fachfeld, z.B. Analytics, Legal, IT)

## Aktueller Stand

Stand 2026-04-08 (letzte Notion-Aktualisierung): 7 Power Automate Flows live, Deniz ist Sole-Administrator. Konzeptpapier Lizenzmanagement-Lösung (Power-BI-Dashboard) in Arbeit. Power-BI-Implementation wird von externem Experten umgesetzt, Deniz liefert nur Konzept.

Siehe [[bachelor-thesis]], HAYS ist die empirische Quelle (7-9 Interviews).

## Offene Aufgaben

- [x] Call mit Justin Münch (Ticketsystem Umzug) - geklärt 2026-04-22
- [ ] Wenn Christine zurück aus Krankenstand: Thesis-Themen mit ihr durchgehen:
  - [[anna-luettgen]] anfragen über Christine (enge Beziehung)
  - [[rob-norris]] und [[francis-davis]] durchsprechen (englische Kontakte, wenn möglich deutsche Alternative finden)
  - [[florian-meyer]] (extern LinkedIn) durchsprechen, ob es eine deutsche Alternative gibt

## Abgeschlossene Meilensteine

- ~~7 Power Automate Flows live~~
- ~~Konzeptpapier Lizenzmanagement-Lösung entworfen~~
