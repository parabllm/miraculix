---
typ: wissen
thema: "Lexware Office Public API"
aliase: ["Lexware API", "Lexoffice API", "Lexware Office Rechnungs-API"]
bereich: integration
erstellt: 2026-04-21
quelle: web_search_2026-04-21
vertrauen: extrahiert
---

# Lexware Office Public API, Übersicht

Offizielle REST-API von Lexware Office (früher lexoffice) für die Integration von Buchhaltungsprozessen. Grundlage für Rechnungsstellungs-Automatisierungen, CRM-Anbindungen und Belegverwaltung.

**Status:** Recherchewissen, noch nicht in einem Thalor-Projekt live implementiert. Bei erster Implementierung Skill-Status hochstufen.

---

## Grundfakten

- **Typ:** REST-API, JSON über HTTPS mit TLS
- **Voraussetzung:** Lexware Office **XL**-Lizenz. Niedrigere Tarife (S, M, L) haben laut aktueller Produktdokumentation keinen API-Zugriff. Vor jedem Projekt prüfen welchen Tarif der Kunde hat.
- **Kosten:** API-Nutzung selbst ist kostenlos. Kostenfaktor ist nur die XL-Lizenz.
- **Auth:** API-Key (Bearer-Token), pro Anwendung einen eigenen Key empfohlen
- **Rate-Limit:** max. 2 Requests pro Sekunde, sonst HTTP 429
- **Dokumentation:** https://developers.lexoffice.io/docs/ (aktuell gehostet unter lexoffice-Domain, Lexware plant Migration)

## API-Key generieren

1. In Lexware Office einloggen
2. Erweiterungen → Weitere Apps → Öffentliche API (oder direkt `/settings/#/public-api`)
3. Benutzer auswählen (pro Anwendung idealerweise eigener User)
4. Neuen API-Key erzeugen mit gewünschten Berechtigungen
5. Key sofort kopieren, sicher ablegen

## Endpunkte (Überblick)

Unterstützte Ressourcen:

| Ressource | CRUD-Unterstützung | Besonderheit |
|---|---|---|
| `contacts` | Lesen, Anlegen, Aktualisieren, Filtern | Suche arbeitet als `contains`, nicht exakt |
| `invoices` (Rechnungen) | Lesen, Anlegen, Finalisieren | Per Default als Draft, Query-Parameter `finalize=true` für abgeschlossene Rechnung |
| `credit-notes` (Gutschriften) | Lesen, Anlegen, Finalisieren | Per Default als Draft |
| `quotations` (Angebote) | Lesen, Anlegen, Abschliessen | |
| `order-confirmations` (Auftragsbest.) | Lesen, Anlegen | |
| `delivery-notes` (Lieferscheine) | Lesen, Anlegen | Bleiben immer im Draft-Status |
| `dunnings` (Mahnungen) | Anlegen | Nicht in Haupt-Belegliste sichtbar, nur an Rechnung hängend |
| `articles` (Artikel/Produkte) | Voller CRUD | |
| `files` | Upload, Download | Belege als PDF anhängen |
| `event-subscriptions` | CRUD | Für Webhooks |

## Rechnungs-Workflow (typisch)

Standard-Ablauf für automatisierte Rechnungsstellung:

1. **Contact anlegen oder finden** (POST `/contacts` oder GET mit Filter)
2. **Rechnung als Draft erstellen** (POST `/invoices`)
3. **Rechnung finalisieren** (mit Query-Param `finalize=true` beim POST, oder separater PUT)
4. **PDF generieren lassen** (GET `/invoices/{id}/document` triggert Rendering, liefert `documentFileId`)
5. **PDF herunterladen** (GET `/files/{documentFileId}`)
6. **PDF per E-Mail versenden** oder anderweitig weiterverarbeiten

Wichtig: Neu erstellte Rechnungen müssen das PDF-Rendering **separat auslösen**, bevor das File abrufbar ist. Nicht der gleiche Endpunkt wie bei schon gerenderten Rechnungen.

## Webhooks

Lexware unterstützt Callbacks für Events wie neue Rechnung, bezahlte Rechnung, Kontakt aktualisiert. Webhooks müssen:
- Per `event-subscriptions` Endpunkt registriert werden
- Eine öffentlich erreichbare URL bereitstellen
- Den `X-Lxo-Signature` Header prüfen, um Echtheit zu verifizieren

Für n8n-Integration: `event-subscriptions` einmalig anlegen per HTTP Request Node, URL auf n8n-Webhook-Trigger zeigen lassen.

## n8n-Integration

- **Kein nativer Lexware-Node in n8n.** Muss komplett über HTTP Request Nodes abgebildet werden.
- Bearer-Token-Credential in n8n anlegen (Header Auth: `Authorization: Bearer {API_KEY}`)
- Alternative: Microsoft Power Platform hat einen Lexoffice-Connector (OAuth 2.0). Für n8n-Setups aber irrelevant.

Baustein für typisches n8n-Szenario:
```
[Trigger: neue Anmeldung im CRM]
  → [HTTP: POST /contacts (Kontakt anlegen)]
  → [HTTP: POST /invoices?finalize=true (Rechnung erstellen und abschliessen)]
  → [HTTP: GET /invoices/{id}/document (PDF triggern)]
  → [HTTP: GET /files/{documentFileId} (PDF holen)]
  → [SMTP: Rechnung als E-Mail versenden]
```

## Wichtige Details für Implementierungen

**E-Rechnung (XRechnung, ZUGFeRD)**
- Lexware Office unterstützt E-Rechnung ab XL-Tarif
- API kann sowohl XML- als auch PDF-Variante liefern
- Für B2B-Pflicht ab 2025 relevant, für B2C meistens optional

**Draft vs. Finalisiert**
- Rechnungen werden per Default als Draft erstellt und sind in Lexware änderbar
- `finalize=true` macht sie endgültig und buchungsrelevant
- Status einer finalisierten Rechnung kann nicht mehr per API geändert werden

**Datumsformat**
- ISO 8601 mit Millisekunden und Zeitzone: `2026-04-21T18:35:00.000+02:00`
- Nicht einfach `2026-04-21`, das wird abgewiesen

**Adressen**
- `contactId` referenziert bestehenden Kontakt (empfohlen)
- Alternative: Adresse als Inline-Objekt direkt in Rechnung, aber dann kein sauberes CRM

**Test-Accounts**
- Lexware stellt auf Anfrage Test-Accounts für Entwicklung bereit
- Integrationspartner-Programm: kostenloser Partner-Account mit Test-Umgebung

## Anwendungsfälle für Thalor-Kunden

Potenzielle Einsatzorte im Thalor-Portfolio:

- **Heiraten in Dänemark:** Rechnung pro Paar bei Buchung automatisch erstellen (wenn Rechnungsprozess überhaupt über Lexware läuft, ungeklärt)
- **BellaVie:** Behandlungs-Rechnungen. Lohnt sich nur wenn Volumen rechtfertigt, aktuell vermutlich zu wenig Kunden.
- **Terminbuchungs-App (Maddox-Projekt):** Nach gebuchter Beauty-Behandlung automatisch Rechnung erstellen. Relevant falls der Klient irgendwann steuerlich skaliert.
- **HeroSoftware-Ökosystem:** Für eigene SaaS-Subscriptions unrealistisch (hat Mantle als Billing), aber theoretisch denkbar für Custom-Kunden.

## Alternativen zu Lexware

Wenn Kunde nicht Lexware nutzt oder XL-Tarif nicht will:

- **sevDesk:** Konkurrent mit ähnlicher API, teilweise einfacher
- **fastbill:** Ebenfalls API, fokussiert auf wiederkehrende Rechnungen
- **DATEV:** Falls der Steuerberater das will, aber API deutlich schwerer
- **Stripe Invoicing:** Wenn die Zahlung eh über Stripe läuft, spart einen Hop

## Offene Fragen

- Welche konkreten Berechtigungs-Scopes gibt es beim API-Key? (Recherche zeigt "gewünschte Berechtigungen", aber keine Scope-Liste)
- Wie funktioniert Mehrmandanten-Setup? Ein API-Key pro Mandant?
- Datenschutzrechtliche Einordnung bei Auftragsdatenverarbeitung, falls Thalor Rechnungen im Kundenauftrag erstellt

## Referenzen

- Offizielle Dokumentation: https://developers.lexoffice.io/docs/
- Lexware Partner-Seite: https://www.lexware.de/partner/public-api/
- Power Automate Connector (als Feature-Referenz): https://learn.microsoft.com/de-de/connectors/lexoffice/
