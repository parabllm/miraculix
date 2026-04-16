# Endpunkte — `_api/` JSON-Contracts

Die Dateien in `_api/` werden automatisch generiert (Phase 3, via n8n oder lokales Skript). Sind read-only für n8n, MCP-Server, Telegram-Bot. Nicht manuell editieren.

---

## `_api/projekte.json`

```json
{
  "generiert": "2026-04-16T14:30:00Z",
  "projekte": [
    {
      "name": "BellaVie Website",
      "aliase": ["BellaVie"],
      "pfad": "01-projekte/maddox/bellavie-website",
      "typ": "sub-projekt",
      "ueber_projekt": "maddox",
      "bereich": "client_work",
      "status": "aktiv",
      "umfang": "geschlossen",
      "lieferdatum": "2026-05-30",
      "offene_aufgaben": 3,
      "hauptkontakt": "maddox"
    }
  ]
}
```

## `_api/aufgaben.json`

```json
{
  "generiert": "2026-04-16T14:30:00Z",
  "aufgaben": [
    {
      "name": "Preisliste anpassen",
      "projekt": "bellavie-website",
      "status": "offen",
      "benoetigte_kapazitaet": "mittel",
      "faellig": "2026-04-18",
      "quelldatei": "01-projekte/maddox/bellavie-website/aufgaben/preisliste.md"
    }
  ]
}
```

## `_api/kontakte.json`

```json
{
  "generiert": "2026-04-16T14:30:00Z",
  "kontakte": [
    {
      "name": "Maddox Yakymenskyy",
      "aliase": ["Maddox", "Max"],
      "gruppen": ["freelance", "freunde"],
      "projekte": ["bellavie-website", "terminbuchung-app"],
      "quelldatei": "03-kontakte/maddox.md"
    }
  ]
}
```

## `_api/tages-uebersicht.json`

```json
{
  "generiert": "2026-04-16T08:00:00Z",
  "datum": "2026-04-16",
  "kapazitaet": 7,
  "eingang_unverarbeitet": 3,
  "aufgaben_heute_faellig": 2,
  "aufgaben_offen_gesamt": 14,
  "aktive_projekte": 7,
  "letzter_log": {
    "projekt": "bellavie-website",
    "datum": "2026-04-15",
    "titel": "Homepage finalisiert"
  }
}
```

## `_api/wissens-index.json`

```json
{
  "generiert": "2026-04-16T14:30:00Z",
  "eintraege": [
    {
      "name": "n8n Webhook Race-Condition Pattern",
      "domain": ["n8n", "webhook"],
      "kategorie": "pattern",
      "vertrauen": "bestaetigt",
      "zuletzt_verifiziert": "2026-04-16",
      "quelldatei": "02-wissen/n8n/webhook-race-condition.md"
    }
  ]
}
```

---

## Generierungs-Mechanismus

- **Auf Hetzner:** Cron alle 15 Min oder Webhook bei Git-Push
- **Lokal (optional):** Obsidian Dataview-Plugin oder Node.js-Skript

Das Skript parsed alle `.md` Files, extrahiert Frontmatter via gray-matter (Node), aggregiert nach Schemas oben.
