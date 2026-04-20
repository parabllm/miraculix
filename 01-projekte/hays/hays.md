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

Werkstudent-Rolle bei **HAYS AG Mid Office Global License Management**. Kernverantwortung: Lizenzmanagement-Prozess für CEMEA-Recruiter, end-to-end von Anfrage → DocuSign → Aktivierung → Reporting, umgesetzt mit **7 Power Automate Flows**. Plus Konzeptpapier für neue Lizenzmanagement-Lösung (Power-BI-Dashboard).

- **Vorgesetzte:** [[christine-kampmann]] (Primary Contact)
- **Kollegin:** [[julia-renzikowski]]
- **Interne Ansprechpartnerin:** Simea (Anfragen laufen über sie)
- **Region:** CEMEA (Deutschland wird separat verwaltet)
- **Verwaltete Produkte:** LinkedIn RPS, LinkedIn SalesNav, LinkedIn LTI, StepStone Talent Finder, Indeed Smart Sourcing, Xing Talent Manager
- **Lizenzmengen:** ~800 DE, ~2.500 CEMEA
- **Architektur:** Hub-and-Spoke (14 SPOC-Listen → 1 zentrale Admin-Liste → Excel-Masterslides als SSOT)
- **Masterslide-Schema:** `tbl{Product}_{Country}` (z.B. `tblLinkedInRPS_DE`)

**Technische Identifier:**
- SharePoint-Site: `https://haysonline.sharepoint.com/sites/globallicensemanagement/admin`
- Admin-Listen-ID: `623ca4ad-2e5f-47a9-b90a-a007149cde34`
- Mail-Absender: `lizenzmanagement@hays.de`
- Mail-BCC-Onboarding: `Deniz.Oezbek@hays.de`

**Sensible Daten:** HAYS-Events im Calendar = `visibility=private`.

## Aktueller Stand

Stand 2026-04-08 (letzte Notion-Aktualisierung): 7 Power Automate Flows live, Deniz ist Sole-Administrator. Konzeptpapier Lizenzmanagement-Lösung (Power-BI-Dashboard) in Arbeit. Power-BI-Implementation wird von externem Experten umgesetzt - Deniz liefert nur Konzept.

Siehe [[bachelor-thesis]] - HAYS ist die empirische Quelle (7-9 Interviews).

## Offene Aufgaben

- [ ] Call mit Justin Münch: Ticketsystem umziehen (heute 15:00-15:45)

## Abgeschlossene Meilensteine

- ~~7 Power Automate Flows live~~
- ~~Konzeptpapier Lizenzmanagement-Lösung entworfen~~

## Out of Scope

- Direkte HR-Themen (Vertrag, Personalakte)
- Power-BI-Implementation (externer Experte, nicht Deniz)

## Report-Identifier pro Produkt

| Produkt | Identifier | Besonderheit |
|---|---|---|
| LinkedIn RPS | Email im `Beschreibung`-Feld | Manueller CSV-Upload-Workaround vor Monatsende |
| LinkedIn SalesNav | Email direkt | Sauberster Report |
| LinkedIn LTI | Email direkt | Kein Problem |
| StepStone | Email direkt | Andere Reporting-Logik (Unlock-Zählung, kein Rating) |
| Indeed | Email direkt | Kein Problem |
| Xing | Xing-Profil | HAYS-Email nicht auszuspielen - manuelle Zuordnung nötig |

## Arbeitshinweise

- Kein direkter PC-Zugriff auf Arbeitslaptop von zuhause
- Workflow: Datei per Mail → Upload → Claude analysiert → Download → zurück an HAYS
- HAYS-Events im Kalender immer `visibility: "private"`

## Detail-Docs

- [[power-automate-flows]] - Vollständige Doku der 7 Flows (Node-Trees, Expressions, Edge Cases)
- [[lizenzmanagement-konzept]] - Konzeptpapier Power-BI-Dashboard für Christine

## Kontakte

- [[christine-kampmann]] - Vorgesetzte
- [[julia-renzikowski]] - Kollegin
- Simea - interne Ansprechpartnerin (nicht als eigener Kontakt)
