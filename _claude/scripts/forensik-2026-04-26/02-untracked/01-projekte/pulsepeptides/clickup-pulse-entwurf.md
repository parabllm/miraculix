---

## typ: wissen projekt: "[[pulsepeptides]]" thema: clickup-pulse-entwurf status: entwurf erstellt: 2026-04-26 zuletzt_aktualisiert: 2026-04-26 vertrauen: angenommen quelle: chat_session + kalani-call-2026-04-25 + zenpilot-framework

# ClickUp-Aufbau Pulse Peptides Entwurf

Operative Steuerungsschicht für Pulse Peptides. Tasks und Boards in ClickUp. Wissen, SOPs, Meeting-Notes bleiben im Vault. Google Sheets bleibt Daten-Master für Batch-Sheet und Pricelists. Slack bleibt Real-Time-Kommunikation.

## Vision der Restrukturierung

Ausgangspunkt Call Kalani 2026-04-25. Kalani will weg vom mentalen Tracken aller Pillars. Er braucht ein Tool das ihm Projektstand zeigt und in dem er Tasks anlegen und zuordnen kann. Framework muss bis 2026-05-01 stehen.

Kerngedanke: Kalani gibt Informationen und Tasks weiter, Deniz strukturiert und steuert, das Team arbeitet Tasks ab. Globales Tracking pro Pillar. Kein Tool-Sprawl.

**Was das System leisten muss:**

1. Kalani sieht in einem Blick was offen ist und wo es hängt
2. Tasks haben Owner, Status, Priority, Due-Date
3. Pro Pillar saubere Sicht auf laufende Arbeit
4. Bestellungen, Custom Orders, Support-Cases als strukturierte Karten
5. Skaliert mit dem Team (Christian, Kai, Lizzi, German, Patrick als zukünftige Owner)

**Was das System bewusst nicht macht (Phase 1):**

- Keine SOPs in ClickUp veröffentlichen, bleibt im Vault
- Keine Automations bauen bevor manuelle Workflows verstanden sind (Kalani-Vorgabe)
- Kein PulseBot-Sheet ablösen, läuft weiter als Daten-Master
- Keine Sprints in V1
- Keine Custom Task Types in V1

## ZenPilot-Framework als Grundlage

ZenPilot ist ClickUps größter Solutions-Partner mit 3.100+ Implementierungen. Empfehlung: jedes Business in 3 Spaces zerlegen.

SpaceBedeutungBei PulseGrowth"Du machst dein Versprechen"Marketing, Sales, Pricing, B2BDelivery"Du hältst dein Versprechen"Bestellungen, Versand, QC, Support, Custom OrdersOperations"Du hältst den Laden am Laufen"Tech, Finance, Compliance

Vorteil: Reporting auf Space-Ebene möglich. Permissions klarer (Operations sensitiv für Kalani+Deniz, Delivery sichtbar fürs Team). Mental Model klar.

## Hierarchie

```
Workspace: Pulse Peptides
├── Space: Growth
│   ├── Folder: Sales & Pricing
│   │   ├── List: Pricing-Projekte
│   │   └── List: B2B Pipeline
│   └── Folder: Marketing
│       └── List: Marketing Tasks
├── Space: Delivery
│   ├── Folder: Supply Chain
│   │   ├── List: Bestellungen
│   │   ├── List: Lager & Versand
│   │   └── List: QC & Lab
│   └── Folder: Customer Operations
│       ├── List: Custom Orders
│       ├── List: Support-Cases
│       └── List: Affiliate-Ops
└── Space: Operations
    ├── Folder: Tech & Automation
    │   ├── List: PulseBot & n8n
    │   └── List: Website & Backend
    └── Folder: Finance & Compliance
        └── List: Tasks
```

3 Spaces, 7 Folders, 11 Listen.

## Globale Custom Fields

Auf Workspace-Level definiert, in jeder Liste sichtbar.

FeldTypWerteOwnerDropdownKalani, Deniz, Christian, Kai, Lizzi, German, Patrick, ExternalPrioritynativeUrgent, High, Normal, LowEffortDropdownXS, S, M, LSourceDropdownSlack, Call, Email, Voice, DriveDrive-LinkURLfür Anhänge wenn nötig

## Globale Status-Pipeline (Default)

`Backlog → Up Next → In Progress → Waiting → Review → Done`

Listen können davon abweichen wo der Lifecycle anders ist (Bestellungen, QC, Custom Orders).

## Listen im Detail

### Space Delivery: Supply Chain

#### List: Bestellungen

Eine Karte gleich eine Supplier-Order. Vereinfachte V1-Felder.

**Custom Fields:**

FeldTypWerteProduktTextfreitext, z.B. "BPC-157 Arginin", "GHK-CU"SupplierDropdownLab Peptides, ZY Peptides, XiAN Sheerherb, OtherBestelldatumDatewann bestelltMengeNumberVials oder KitsOrder-StatusDropdownsiehe Pipeline untenTracking-NumberTextwenn vorhandenPayment-StatusDropdownPending, Paid Crypto, Paid SEPA, Failed

**Status-Pipeline:**`Quoted → PO Sent → Paid → Shipped → Arrived → QC Pending → Active → Archived`

#### List: Lager & Versand

Alles was rund um Lager und Versand passiert das KEIN Bestellprozess ist. Tschechien-Migration, Pakete, Labels, Versand-Routing, Stock-Alerts.

**Custom Fields:** nur globale (Owner, Priority, Effort, Source, Drive-Link).

**Status-Pipeline:** Default.

#### List: QC & Lab

Janoshik-Tests, COAs, HPLC, Endotoxin, Batch-Issues. Tasks die einen Mensch erfordern. Das Google Sheet bleibt Daten-Master.

**Custom Fields:**

FeldTypWerteBatch-IDTextz.B. LP26Q11BPCTest-TypeDropdownHPLC, Endotoxin, Sterility, OtherLabDropdownJanoshik, OtherResultDropdownPending, Pass, Fail, BorderlineCOA-LinkURLDrive-Link zum PDF

**Status-Pipeline:**`Sent → Awaiting Result → Result In → Reviewed → Filed`

### Space Delivery: Customer Operations

#### List: Custom Orders

Eine Karte gleich ein Custom-Order-Case. Lifecycle anders als reguläre Bestellungen.

**Custom Fields:**

FeldTypWerteKundeTextInitialen oder Vorname (Datenschutz)CompoundTextfreitext, z.B. "Prostamax KEDP"Standard-SortimentCheckboxtrue wenn doch im Lab-SortimentSupplierDropdownLab Peptides, ZY Peptides, XiAN SheerherbAnfrage-MengeNumber

**Status-Pipeline:**`Anfrage → Identifier ausstehend → Sourcing → Quote raus → Bestellt → Versendet → Geschlossen`

Hinweis: Bei Übergang zu "Bestellt" wird parallel ein Task in der Bestellungen-Liste angelegt. V1 manuell, später Automation.

#### List: Support-Cases

Reklamationen, Failed Shipments, Compensation. Hauptsächlich Christian.

Christian legt nur die Cases an die er an Deniz eskaliert. Standard-Anfragen löst er weiter direkt in Slack ohne ClickUp-Karte.

**Custom Fields:**

FeldTypWerteIssue-TypeDropdownFailed Shipment, Defekte Vials, Versand-Frage, Reklamation, Lab-Test-Anfrage, OtherCustomer-CountryDropdownDE, EU, Norway, US, OtherSeverityDropdownLow, Medium, HighCompensation-TypeDropdownNone, Extra Vials, Coupon, RefundSlack-ThreadURLLink zum Slack-Thread

**Status-Pipeline:**`Eingereicht → In Bearbeitung → Compensation Sent → Geschlossen`

#### List: Affiliate-Ops

Affiliate-Anträge plus aktive Affiliates pflegen.

**Custom Fields:**

FeldTypWerteAffiliate-NameTextUsernamePlattformDropdownInstagram, TikTok, YouTube, OtherFollowerNumberNiche-FitDropdownFitness, Body, Wellness, Off-TopicStatusDropdownAntrag, Approved, Active, Paused, RejectedCoupon-CodeText

**Status-Pipeline:**`Antrag → Reviewed → Approved → Active → Inactive`

### Space Growth: Sales & Pricing

#### List: Pricing-Projekte

Phase 1 Margen, Phase 2 Shipping, Bulk-Liste, Premium-Linie, Biolab-Benchmark.

**Custom Fields:**

FeldTypWertePhaseDropdownPhase 1, Phase 2, Premium-Linie, Bulk-B2BSheet-LinkURLGoogle SheetApprovalCheckboxKalani-OK

**Status-Pipeline:**`Recherche → Berechnung → Review Kalani → Approved → Live im Shop`

#### List: B2B Pipeline

Aktive B2B-Leads. Pepspan und zukünftige.

**Custom Fields:**

FeldTypWerteFirmaTextKontaktTextStageDropdownErstkontakt, Bulk-Liste raus, Quote, Verhandlung, Geschlossen

**Status-Pipeline:** Default.

### Space Growth: Marketing

#### List: Marketing Tasks

Aktuell wenig Volumen. Eine Liste reicht. Ads, Content, Branding.

**Custom Fields:** nur globale.

**Status-Pipeline:** Default.

### Space Operations: Tech & Automation

#### List: PulseBot & n8n

PulseBot-Workflows, n8n-Issues, neue Automations.

**Custom Fields:** nur globale.

**Status-Pipeline:** Default.

#### List: Website & Backend

German plus Patrick Themen.

**Custom Fields:** nur globale.

**Status-Pipeline:** Default.

### Space Operations: Finance & Compliance

#### List: Tasks

Banking, Krypto, UBO, Buchhaltung, Zoll, EU-Regulatorik. Niedriges Volumen, eine Liste reicht.

**Custom Fields:** nur globale.

**Status-Pipeline:** Default.

## Views

Ableitung aus den Listen-Definitionen, V1.

**Pro Liste Default-View:** Kanban-Board (Status als Spalten). **Zusätzlich pro Liste:** List-View für Bulk-Edits, Calendar-View wo Due-Dates relevant.

**Cross-Pillar Views:**

- "Mein Schreibtisch" (Kalani): gefiltert auf Owner=Kalani über alle Listen, Status nicht Done
- "Diese Woche": gefiltert auf Due-Date diese Woche über alle Listen
- "Waiting": gefiltert auf Status=Waiting über alle Listen, für Wochen-Review

**Gantt-View nur wo nötig:**

- Tschechien-Lager-Migration (Lager & Versand)
- Pricing Phase 1 plus Phase 2 (Pricing-Projekte)
- Framework-Aufbau diese Woche (separate temporäre Liste)

## Goals

Zusätzliche Goals-Ebene für messbare Meilensteine. Goals werden mit Tasks verknüpft, ClickUp rechnet Progress automatisch.

GoalTargetDeadlineFramework V1 stehttrue2026-05-01Pricing Phase 1 abgeschlossen7 Produkte mit Marge gerechnet2026-05-01Tschechien-Lager operativtrueAnfang MaiSortiment-Refill kritische Produkte6 Produkte zurück auf Stock2026-05-15Janoshik-Mail-Flow livetrue2026-05-08

## Was wo lebt

InhaltToolBegründungTasks, Status, OwnerClickUpaktiv steuerbarBatch-Sheet PulseBotGoogle Sheetbleibt Daten-Master, n8n schreibt reinPricelists Lab/ZY/XiANGoogle Sheet im DriveSpreadsheet-Funktionen, LookupPricing-WorkbookGoogle Sheet im DriveCross-Sheet-FormelnSOPsVaultprivat, nur DenizMeeting-NotesVaultprivat, nur DenizSensible Compliance-DocsGoogle DrivePermissions kontrolliertKommunikationSlackReal-Time

ClickUp-Tasks können Drive-URL als Custom-Field haben. Kein Doppelhalten.

## Roll-Out-Plan

Nicht alle 3 Spaces gleichzeitig befüllen. ZenPilot-Empfehlung: erst Top-3-Listen wo aktive Cases liegen, dann erweitern.

**Phase 1 (diese Woche, bis 2026-05-01):**

- Workspace plus 3 Spaces plus 7 Folders plus 11 Listen anlegen
- Globale Custom Fields anlegen
- Status-Pipelines pro Liste setzen
- Top-3-Listen befüllen mit aktiven Tasks: Bestellungen, Custom Orders, Pricing-Projekte
- Goals anlegen
- "Mein Schreibtisch"-View für Kalani

**Phase 2 (nach 2026-05-01):**

- Andere Listen befüllen
- Slack-ClickUp-Integration
- Drive an ClickUp anbinden
- Erste Automations evaluieren

**Phase 3 (nach 2-3 Wochen Live-Betrieb):**

- Adjustments basierend auf realer Nutzung
- Custom Task Types prüfen
- Sprints prüfen
- Pillar-spezifische Custom Fields wo wirklich gebraucht
