---
typ: wissen
projekt: "[[pulsepeptides]]"
thema: clickup-aufbau
status: aktiv
erstellt: 2026-04-26
zuletzt_aktualisiert: 2026-04-27
vertrauen: bestätigt
quelle: clickup-mcp-live-2026-04-27
---

# ClickUp-Aufbau Pulse Peptides

Operative Steuerungsschicht für Pulse Peptides. Aktueller Live-Stand der ClickUp-Struktur, gezogen via MCP am 2026-04-27.

## Architektur-Modell

Drei-Ebenen-Mapping mit klar getrennten Funktionen:

| Ebene | ClickUp-Element | Bedeutung |
|---|---|---|
| 1 | Space | Branch / Geschäftsbereich. Reporting-Grenze. Permissions-Grenze. |
| 2 | Folder | Pillar / Funktionsgruppe. Bündelt verwandte Listen. |
| 3 | List | Exekutivlayer / operative Einheit. Status-Spalten pro Liste konfigurierbar. Hier passiert die Arbeit. |

Konsequenz: Reporting auf Space-Ebene. Pillars als logische Gruppierung. Status-Pipeline pro Liste, nicht global, sodass Bestellungs-Lifecycle anders aussehen kann als QC-Lifecycle.

## Vision (kurz)

Kalani braucht einen Blick auf alles Offene. Tasks mit Owner, Status, Priority, Due-Date. Pro Pillar saubere Sicht. Kein Tool-Sprawl.

Framework basiert auf ZenPilot (3.100+ ClickUp-Implementierungen). Drei-Spaces-Modell:

- Growth: was man dem Markt verspricht (Marketing, Sales, Pricing, B2B)
- Delivery: das Versprechen einlösen (Bestellungen, Versand, QC, Support, Custom Orders)
- Operations: den Laden am Laufen halten (Tech, Finance, Compliance)

## Live-Hierarchie mit IDs

Workspace-ID: `90121674735`

**Space Growth** (`90127264048`)
- Folder Sales & Pricing (`901210727991`)
  - Pricing Projects (`901217511396`)
  - B2B Pipeline (`901217511398`)
- Folder Marketing (`901210727998`)
  - Marketing Tasks (`901217511400`)

**Space Delivery** (`90127264065`)
- Folder Supply Chain (`901210728009`)
  - Orders (`901217511402`)
  - Warehouse & Shipping (`901217511406`)
  - QC & Lab (`901217511408`)
- Folder Customer Operations (`901210728011`)
  - Custom Orders (`901217511413`)
  - Support-Cases (`901217511417`)
  - Affiliate-Ops (`901217511418`)

**Space Operations** (`90127264073`)
- Folder Tech & Automation (`901210728012`)
  - Workflows (`901217511419`)
  - Website & Backend (`901217511421`)
- Folder Finance & Compliance (`901210728018`)
  - Tasks (`901217511425`)

Total: 3 Spaces, 7 Folders, 11 Listen.

## Custom Fields (IS-Stand 2026-04-27)

### Workspace-Level

Aktuell leer. Owner und Priority laufen via native ClickUp-Felder (Assignee, Priority). Effort als eigenes Feld noch nicht angelegt.

### Globale Felder (in 6 von 11 Listen identisch)

In Pricing Projects, Marketing Tasks, QC & Lab, Custom Orders, Support-Cases:

| Feld | Typ | Optionen |
|---|---|---|
| Source | drop_down | Slack, Call, Email, WhatsApp |
| Drive Link | url | freier Link |

Anwendung: Source = Herkunft des Tasks. Drive Link = Verweis auf Drive-Ordner oder Drive-Datei.

### Listen-spezifische Felder

#### Orders (Supply Chain)

| Feld | Typ | Optionen |
|---|---|---|
| Quantity | drop_down | 1mg, 2mg, 3mg, 4mg, 5mg, 10mg, 15mg, 20mg |
| Tracking Number | short_text | freitext |
| Product | short_text | Produktname |
| Payment Status | drop_down | Pending, Paid Crypto, Failed |
| Supplier | drop_down | Lab, XiAN, ZY |

Anmerkung: Im Entwurf war Quantity als Number geplant, live als mg-Dropdown. Sinnvoll für Pulse-Spezifik. SEPA als Payment-Status fehlt aktuell, im Entwurf war "Paid SEPA" enthalten. Klären ob nachpflegen.

#### Affiliate-Ops (Customer Operations)

Aktuell LEER. Echte Lücke im Live-Stand.

Im Entwurf vorgesehen: Affiliate-Name, Plattform (Instagram/TikTok/YouTube/Other), Follower (Number), Niche-Fit (Fitness/Body/Wellness/Off-Topic), Status (Antrag/Approved/Active/Paused/Rejected), Coupon-Code.

#### Andere Listen

Warehouse & Shipping, B2B Pipeline, Workflows, Website & Backend, Tasks (Finance): nur globale Felder (Source, Drive Link), keine listen-spezifischen Custom Fields angelegt.

## Drive-Mapping (Future Work)

Ziel: Drive-Ordner-Struktur spiegelt ClickUp-Hierarchie 1:1. Custom Field "Drive Link" pro Task verlinkt auf passenden Drive-Ordner oder direkte Drive-Datei.

Aktueller Stand: Drive ist eigenständig strukturiert, nicht aligned mit ClickUp.

Soll-Logik:

- Pro Space ein Top-Level-Drive-Folder
- Pro ClickUp-Folder ein Sub-Drive-Folder
- Pro List ein Sub-Sub-Drive-Folder
- Tasks verlinken über "Drive Link" auf den passenden Folder

Implementierungs-Pfad: Drive einmalig sauber strukturieren parallel zur ClickUp-Hierarchie, dann Tasks beim Anlegen mit Drive-Link versehen.

## Status-Pipelines (Soll, aus Entwurf)

API zeigt Status-Pipelines pro Liste nicht zurück. Live-Verifikation in ClickUp-UI offen.

| Liste | Soll-Pipeline |
|---|---|
| Default (alle Listen ohne eigene Definition) | Backlog → Up Next → In Progress → Waiting → Review → Done |
| Orders | Quoted → PO Sent → Paid → Shipped → Arrived → QC Pending → Active → Archived |
| QC & Lab | Sent → Awaiting Result → Result In → Reviewed → Filed |
| Custom Orders | Anfrage → Identifier ausstehend → Sourcing → Quote raus → Bestellt → Versendet → Geschlossen |
| Support-Cases | Eingereicht → In Bearbeitung → Compensation Sent → Geschlossen |
| Affiliate-Ops | Antrag → Reviewed → Approved → Active → Inactive |
| Pricing Projects | Recherche → Berechnung → Review Kalani → Approved → Live im Shop |

## Was wo lebt

| Inhalt | Tool | Begründung |
|---|---|---|
| Tasks, Status, Owner | ClickUp | aktiv steuerbar |
| Batch-Sheet (PulseBot) | Google Sheet | Daten-Master, n8n schreibt rein |
| Pricelists (Lab, ZY, XiAN) | Google Sheet im Drive | Spreadsheet-Funktionen, Lookup |
| Pricing-Workbook | Google Sheet im Drive | Cross-Sheet-Formeln |
| SOPs | Vault | privat, nur Deniz |
| Meeting-Notes | Vault | privat, nur Deniz |
| Sensible Compliance-Docs | Google Drive | Permissions kontrolliert |
| Kommunikation | Slack | Real-Time |

ClickUp-Tasks halten Drive-Verweise via Custom Field "Drive Link". Kein Doppelhalten.

## Anpassungs-Backlog

Offene Anpassungen, die in den nächsten Iterationen anstehen:

- [ ] Affiliate-Ops Custom Fields anlegen (aktuell leer)
- [ ] Drive-Folder-Struktur an ClickUp-Hierarchie angleichen (siehe Drive-Mapping)
- [ ] Workspace-Level Custom Fields entscheiden: Owner+Priority via native ClickUp, Effort als eigenes Feld?
- [ ] Status-Pipelines pro Liste live verifizieren gegen Soll-Tabelle
- [ ] Quantity-Feld eventuell auch in Custom Orders übernehmen (Compound + Menge)
- [ ] Payment Status um SEPA ergänzen (im Entwurf vorgesehen, live nicht da)
- [ ] Listen-spezifische Felder für QC, Custom Orders, Pricing, Support nachziehen (im Entwurf definiert, live noch nicht angelegt)
- [ ] Goals-Sektion in ClickUp anlegen (Framework V1, Pricing Phase 1, Tschechien-Lager, Sortiment-Refill, Janoshik-Mail-Flow)
- [ ] Cross-Pillar-Views einrichten ("Mein Schreibtisch" Kalani, "Diese Woche", "Waiting")

## Roll-Out-Status

**Phase 1 (Skelett anlegen)** abgeschlossen 2026-04-26 bis 27. Workspace, 3 Spaces, 7 Folders, 11 Listen live. Erste Custom Fields (Orders global plus listen-spezifisch).

**Phase 2 (Befüllung + Integration)** offen. Tasks anlegen, Slack-ClickUp-Integration aktivieren, Drive an ClickUp koppeln, fehlende Custom Fields ergänzen.

**Phase 3 (Adjustments nach Live-Betrieb)** future. Nach 2-3 Wochen Real-Use: Custom Task Types, Sprints, pillar-spezifische Optimierungen.

## Quellen

- ClickUp MCP Live-Pull 2026-04-27 (Hierarchie + Custom Fields)
- Call mit Kalani [[2026-04-25-kalani-call]] (Pricing-Strategie, Pillar-Struktur, ClickUp-Entscheidung)
- Call mit Kalani [[2026-04-27-kalani-call]] (Wochenstart, Drive plus ClickUp Cross-Tool, Pricing-Review)
- ZenPilot-Framework als methodische Grundlage
- Vorläufer: clickup-pulse-entwurf.md (gelöscht 2026-04-27, in Git-History verfügbar)
