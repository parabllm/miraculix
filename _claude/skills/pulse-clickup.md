---
name: pulse-clickup
description: |-
  Verwende diesen Skill IMMER wenn Deniz fuer PulsePeptides ClickUp-Tasks anlegen, updaten, loeschen oder restrukturieren will. Triggert bei "leg das in ClickUp", "ClickUp-Task fuer Pulse", "neuer Pulse-Task", "Status updaten", "Subtask anlegen", "Order in ClickUp" oder generell wenn ein Pulse-Task ins Team-Tool soll.

  Enthaelt Kernprinzip (ClickUp ist Team-Kommunikation, nicht Vault-Mirror), Workspace-Architektur mit IDs, Status-Pipelines pro Liste, Schreibstil fuer Task-Titel und Subtask-Patterns.
---

# Pulse Peptides ClickUp

Operative Task-Steuerung fuer das Pulse-Team. Dieser Skill regelt wie Tasks in ClickUp angelegt werden, was rein gehoert und was im Vault bleibt.

## Kernprinzip: ClickUp ist Team-Kommunikation, nicht Vault-Mirror

ClickUp ist die Sprache mit der Deniz dem Pulse-Team (primaer Kalani, sekundaer Kai/Patrick/Christian) operative Aufgaben kommuniziert. ClickUp ist NICHT die Spiegelung des Vault-Wissens, NICHT das Tracking-System fuer Deniz' eigene Notizen, NICHT der Ort fuer Provenance, Quellen oder interne Reflexionen.

Konsequenzen:

- **Vault-Wissen bleibt im Vault.** Wikilinks, `quelle:`, `vertrauen:`, Meeting-Note-Verweise, COO-Onboarding-Notizen, eigene Strategie-Reflexionen gehen NIE nach ClickUp.
- **Tasks die nur Deniz betreffen** (Domain-Transfer pulsepeptides.com, Vault-Aufgaben, Reflexions-Aufgaben) bleiben im Vault.
- **Tasks die das Team sieht** sind in ClickUp formuliert wie eine Slack-Nachricht an Kalani: kurz, klar, ohne Insider-Sprache, ohne Vault-Begriffe.
- **Description nur wenn noetig.** Der Titel sollte den Task selbsterklaerend machen. Description nur fuer Spec, Mengen, Spezifika die Kalani oder Kai aktiv brauchen. Kein Markdown-Wall, keine Vault-Querverweise.
- **Custom Fields wurden bewusst entfernt.** Source, Drive Link, Quantity, Supplier, Tracking Number etc. Diese werden NICHT wieder angelegt ausser auf expliziten Wunsch von Deniz mit Begruendung.

## Workspace-Architektur (Stand 2026-04-30)

| Ebene | Wert |
|---|---|
| Workspace ID | `90121674735` |

### Spaces und Listen

| Space | Space ID | Folder | Liste | List ID |
|---|---|---|---|---|
| Growth | `90127264048` | Sales & Pricing | Pricing Projects | `901217511396` |
| Growth | `90127264048` | Sales & Pricing | B2B Pipeline | `901217511398` |
| Growth | `90127264048` | Marketing | Marketing Tasks | `901217511400` |
| Delivery | `90127264065` | Supply Chain | Orders | `901217511402` |
| Delivery | `90127264065` | Supply Chain | Warehouse & Shipping | `901217511406` |
| Delivery | `90127264065` | Supply Chain | QC & Lab | `901217511408` |
| Delivery | `90127264065` | Customer Operations | Custom Orders | `901217511413` |
| Delivery | `90127264065` | Customer Operations | Support-Cases | `901217511417` |
| Delivery | `90127264065` | Customer Operations | Affiliate-Ops | `901217511418` |
| Operations | `90127264073` | Tech & Automation | Workflows | `901217511419` |
| Operations | `90127264073` | Tech & Automation | Website & Backend | `901217511421` |
| Operations | `90127264073` | Finance & Compliance | Tasks | `901217511425` |

### User-IDs

| Person | User ID |
|---|---|
| Deniz Oezbek | `296508627` |
| Kalani Ginepri | `296508734` |

## Status-Pipelines (empirisch, Stand 2026-04-30)

Jede Liste hat eigene Status-Pipeline. `in progress`, `to do`, `complete` sind NICHT ueberall verfuegbar. Bei API-Fehler "Status not found" oder "Status does not exist": Status weglassen oder anderen Wert probieren.

| Liste | Bekannte Statuses | Default beim Anlegen |
|---|---|---|
| Orders | to do, inquiry, shipped (vermutlich auch: quoted, ordered, arrived, qc pending, active, archived) | to do |
| Warehouse & Shipping | to do, in progress, complete | to do |
| QC & Lab | sent, awaiting result, result in, reviewed, filed | sent |
| Custom Orders | unbekannt (vermutet: anfrage, identifier ausstehend, sourcing, quote raus, bestellt, versendet, geschlossen) | unbekannt |
| Support-Cases | unbekannt (vermutet: eingereicht, in bearbeitung, compensation sent, geschlossen) | unbekannt |
| Affiliate-Ops | application (= Antrag), reviewed, approved, active, inactive | application |
| Pricing Projects | to do, review, complete | to do |
| Workflows | to do, in progress, complete | to do |
| Website & Backend | to do, complete | to do |
| Tasks (Finance) | to do, in progress, complete | to do |
| B2B Pipeline | unbekannt | unbekannt |
| Marketing Tasks | unbekannt | unbekannt |

Wenn eine Liste neu bespielt wird: erstmal Task ohne Status anlegen, dann Status nachsetzen. Bei Fehler: in der UI nachschauen welche Statuses verfuegbar sind und Pipeline hier ergaenzen.

## Schreibstil fuer Task-Titel

Tasks sind an Kalani gerichtet. Titel folgen dem Slack-DM-Pattern: Verb plus Objekt plus Kontext. Keine Vault-Slang. Keine Wikilinks. Keine `[[...]]`.

Gut:

- "Druckereien anrufen + Angebote einholen"
- "PT-141 Labels nachbestellen"
- "XiAN Caps Order"
- "Banking-Alternative Revolut + Pulse-eigene Kreditkarte"
- "Tschechien-Lager Setup Phase 1"
- "Mengen mit Vivian abstimmen"

Schlecht:

- "Anrufen" (was, wen?)
- "Mail" (welche?)
- "Onboarding" (wofuer?)
- "Siehe [[2026-04-28-lager-besuch-kalani]]" (Vault-Sprache)
- "Affiliate-Framework gemaess COO-Aufgaben" (Vault-Querverweis)

## Subtask-Patterns

ClickUp-API kann existierende Tasks NICHT zu Subtasks konvertieren. Wenn ein Task in einen Subtask umgewandelt werden muss: alten loeschen, neuen mit `parent` Parameter anlegen.

### Pattern 1: Multi-Item-Bestellung

Wenn mehrere Produkte zusammen beim selben Supplier bestellt werden, ein Parent fuer den Order-Vorgang plus Subtask pro Produkt plus Subtask fuer Mengen-Klaerung.

```
XiAN Caps Order (Parent, Deniz, high)
  - BPC-157 Caps (Sub, Deniz)
  - 5-Amino-1MQ Caps (Sub, Deniz)
  - KPV - Form klaeren (Sub, Deniz)
  - Mengen mit Vivian abstimmen (Sub, Deniz, urgent)
```

### Pattern 2: Multi-Step-Aufgabe

Wenn eine Aufgabe natuerlich aus mehreren Schritten besteht.

```
Tschechien-Lager Setup Phase 1 (Parent, Deniz, high)
  - Maman TBD-Felder finalisieren (Sub, Kalani+Deniz, high)
  - Onboarding-Dokument Tschechen finalisieren (Sub, Deniz)
  - DHL-Anmeldung Tschechien-Firma (Sub, Deniz)
  - WMS Lokia Anbindung mit Patrick klaeren (Sub, Deniz)
  - 20% Testvolumen starten (Sub, Deniz)
```

### Pattern 3: Cluster zusammengehoeriger Tasks (Workflows)

Wenn mehrere Tasks logisch zusammenhaengen, Parent als Hauptaufgabe und Subtasks als verbundene naechste Schritte.

```
Janoshik n8n-Workflow fixen (Parent, Deniz, high, in progress)
  - DHL-CSV-Flow reparieren (Sub, Deniz)
  - Janoshik OCR Pipeline aufsetzen (Sub, Deniz)
```

### Wann KEIN Parent-Subtask-Pattern

- Einzeltasks ohne natuerliche Untergliederung: einfach als Standalone-Task
- Backorder-Items die nicht zusammen bestellt werden: einzelne Tasks (PT-141 Labels, Semax Labels, Selank Labels haben jeweils eigene Druckerei-Logik, kein Parent)

## Workflow: Vault zu ClickUp

### Wenn Deniz sagt "leg das in ClickUp"

1. Pruefen ob es ein Team-Task ist oder eine eigene Vault-Aufgabe. Eigene Aufgaben (Vault-Cleanup, Wissens-Destillation, COO-Reflexion, Domain-Transfer) bleiben im Vault, nicht ins ClickUp.
2. Pruefen ob bereits ein passender Task in ClickUp existiert. Wenn ja, updaten statt neu anlegen.
3. Liste bestimmen aus Workspace-Architektur-Tabelle.
4. Titel formulieren nach Schreibstil.
5. Owner setzen (Deniz=`296508627`, Kalani=`296508734`).
6. Priority setzen (urgent / high / normal / low).
7. Status nur setzen wenn die Pipeline der Liste einen sinnvollen Wert hergibt. Sonst weglassen, default greift.
8. Ohne `description` anlegen ausser Spec ist kritisch (Mengenangabe, Spezifikation).

### Wenn Deniz sagt "Status updaten"

`clickup_update_task` mit `task_id` und `status`. Wenn Pipeline-Fehler kommt: andere Status-Werte aus der Tabelle probieren oder in der UI nachschauen.

### Wenn Deniz sagt "loesche das"

`clickup_delete_task` mit `task_id`. Vorher `clickup_filter_tasks` aufrufen wenn ID nicht bekannt.

### Wenn Deniz sagt "ist erledigt"

`clickup_update_task` mit `status: complete` (oder pipeline-spezifischer Endstatus, z.B. `archived` bei Orders).

### Wenn Deniz sagt "mach Subtask aus X"

ClickUp-API kann nicht direkt umstellen. Workflow:

1. Alten Task auslesen (Name, Owner, Priority, Description merken)
2. Alten Task loeschen
3. Neuen Task mit `parent` Parameter und gemerkten Werten anlegen

### Wenn Deniz sagt "neue Order: X bei Y"

1. Pruefen ob es Multi-Item-Order ist (mehrere Produkte beim selben Supplier) oder Single-Item.
2. Bei Multi-Item: Parent anlegen ("X Order"), dann Subtasks pro Produkt.
3. Bei Single-Item: Standalone-Task in Orders-Liste.
4. Status entsprechend Phase (inquiry wenn Anfrage rausgegangen, ordered wenn bestellt, shipped wenn unterwegs, etc.)

## Caveats und bekannte Probleme

- **Status-Pipelines sind list-spezifisch.** "Status does not exist"-Error nicht ignorieren, sondern Pipeline aus Tabelle nutzen oder Status weglassen.
- **API-Subtask-Konvertierung fehlt.** Bestehende Tasks koennen nicht via Update zu Subtasks gemacht werden. Loeschen + neu anlegen.
- **Sporadische API-Fehler.** Manche API-Calls failen mit "Error occurred during tool execution" beim ersten Versuch. Retry funktioniert meist.
- **Filter-Task gibt keine Description zurueck.** Wenn Description gesetzt war, ist sie nicht im Filter-Result sichtbar. Einzelnen Task pullen ueber `clickup_get_task`.
- **Custom Fields wurden im April 2026 entfernt.** Nicht ohne Begruendung neu anlegen. Felder die je nach Workflow noetig waeren (Tracking Number, Supplier) lieber als Tag oder im Description halten.

## Vault-Synchronisation

Wenn ein Task in ClickUp angelegt oder erledigt wird, ist KEINE automatische Vault-Synchronisation noetig. Der Vault hat eigenen Task-Block in Projekt-Files (z.B. `pulsepeptides.md` Sektion "Offene Aufgaben"). Der bleibt Deniz' eigene Sicht.

Wenn ein Task im Vault drin ist UND in ClickUp, ist das OK. Beide leben parallel:

- Vault = vollstaendige Sicht inkl. eigener Notizen, Strategie, Vault-only-Tasks
- ClickUp = operative Sicht fuers Team

Manueller Sync nur bei expliziter Anweisung "log das im Vault" oder "abgleich pulsepeptides".

## Live-Stand 2026-04-30

Stand der ClickUp-Tasks dokumentiert in `01-projekte/pulsepeptides/clickup-pulse.md`. Diese Datei ist die Vault-Sicht der ClickUp-Architektur und wird nach jedem groesseren Restructure aktualisiert.

## Quellen

- ClickUp MCP Live-Pulls (laufend)
- Vault-Datei `01-projekte/pulsepeptides/clickup-pulse.md`
- Aufraeum-Session 2026-04-30 (Custom Fields entfernt, Tasks restrukturiert, Sub-Tasks eingefuehrt)
- ZenPilot-Framework als methodische Grundlage fuer Drei-Spaces-Modell
