---
name: miraculix-wissens-destillation
description: |-
  Triggered implicitly during "log" when Deniz wraps up work. Also explicitly when Deniz says "destilliere das", "das ist ein Pattern", "speicher das als transferable".
  
  Use this skill to detect patterns that have occurred 2+ times across different projects and propose a knowledge entry in 02-wissen/.
  
  Applies 3-phase model: first occurrence stays as log, second triggers destillation with "abgeleitet" trust, third upgrades to "bestätigt". Special rules for architecture decisions, debug fixes, tool docs - can be destilled on first occurrence. Always propose first, never auto-write.
---
# Wissens-Destillation

Destilliere gelöste Probleme zu Wissens-Einträgen. Filter: Wiederholung.

## 3-Phasen-Modell

### Phase 1 - Roh-Log (1. Auftreten)

Problem → Log-Eintrag im Projekt (via `log`).

**Kein Wissens-Eintrag.** Zu früh, könnte Zufall sein.

### Phase 2 - Destillations-Vorschlag (2. Auftreten)

Beim `log` prüfen: Gab's dieses Pattern schon?
- Keyword-Suche in Logs anderer Projekte
- `_api/wissens-index.json` nach Domain-Match (falls vorhanden)

Bei Match:
> "Dieses Webhook-Timing-Problem ist 2× aufgetreten. 2026-03-12 HeroSoftware, jetzt Resolvia. Wissens-Eintrag `02-wissen/n8n/webhook-race-condition.md`? Vertrauen: `abgeleitet`."

Bei OK → Eintrag mit:
- `vertrauen: abgeleitet`
- `quellen: [[log1]], [[log2]]`
- `projekte: [...]`
- `zuletzt_verifiziert: heute`

### Phase 3 - Bestätigt (3.+ Auftreten)

Bestehender Eintrag aktualisiert:
- `vertrauen: bestätigt`
- Neue Quelle + Projekt anhängen
- `zuletzt_verifiziert: heute`

Diff zeigen, OK abwarten.

## Spezial-Regeln (früher destillieren)

### Architektur-Entscheidungen
Oft nur 1× aber hoher Transfer-Wert (z.B. "Cal.com Fork abgelehnt wegen AGPLv3").

→ Wenn Deniz als "Design-Decision" / "Architektur-Entscheidung" labelt: sofort destillieren. `vertrauen: extrahiert`, `kategorie: entscheidung`.

### Debug-Fixes mit Fingerprint
Exakte Fehlermeldung + spezifischer Fix → früher destillieren.

→ `kategorie: debug_fix`, `vertrauen: extrahiert`.

### Tool-Dokumentation
"So funktioniert Mantle API" / "Attio Convention" → direkt destillieren.

→ `kategorie: referenz` oder `tool`.

## Widerspruchs-Check

Vor Erstellung/Update:
- Widersprechender Eintrag in Domain?
- Kompatibel mit anderem Pattern?

Bei Widerspruch:
- Kein neuer Eintrag
- `widerspricht:` Feld im bestehenden setzen
- Deniz: "Widerspricht `X`. Welcher Ansatz stimmt?"

## Frontmatter-Template

```yaml
---
typ: wissen
name: "Titel"
aliase: ["..."]
domain: ["..."]
kategorie: pattern
vertrauen: abgeleitet
quellen: ["[[log1]]", "[[log2]]"]
projekte: ["[[projekt-a]]"]
zuletzt_verifiziert: 2026-04-16
widerspricht: null
erstellt: 2026-04-16
---
```

## Regeln

- **Nie ungefragt destillieren.**
- **Quellen verlinken, nicht kopieren.**
- **Destillation ist kein Move.** Log bleibt.
- **Projekt-Spezifisches nicht ins Wissen.** Nur Transferables.

## Vault-Writes

Vor jedem .md-Write Pflicht-Lektuere:
- [[vault-schreibkonventionen]] - WAS rein (Encoding, Umlaute, Naming, Gedankenstriche)
- [[vault-schreibregeln]] - WIE schreiben (Tools, Rollback, Bug-Patterns)

Kernregeln:
- NIE Desktop Commander `write_file` oder `edit_block` fuer .md mit YAML-Frontmatter
- Hex-Verify Pflicht nach jedem Write (erste 8 Bytes muessen `2D 2D 2D 0A` plus YAML-Key sein)
