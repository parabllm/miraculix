# Wissens-Destillation Skill

**Trigger implizit** beim `log` — Claude prüft Destillations-Kandidaten.
**Explizit:** "destilliere das", "das ist ein Pattern", "speicher das als transferable"

---

## Zweck

Destilliere gelöste Probleme zu Wissens-Einträgen in `02-wissen/`. Filter: Wiederholung. Nicht jedes gelöste Problem wird Wissen. Nur was **2× oder öfter auftritt** hat Transfer-Wert.

---

## 3-Phasen-Modell

### Phase 1 — Roh-Log (beim ersten Auftreten)
Problem gelöst → Log-Eintrag. Enthält:
- was war das Problem
- wie wurde es gelöst
- relevante Code-Snippets / Configs / Patterns

**Kein Wissens-Eintrag.** Zu früh, könnte Zufall sein.

### Phase 2 — Destillations-Vorschlag (beim zweiten Auftreten)
Claude erkennt beim `log`: "Dieses Pattern gab's schon in [anderes Projekt]."

Cross-Project-Check:
- `_api/wissens-index.json` nach Pattern-Match
- Projekt-Logs nach ähnlichen Titeln (Keyword-Suche reicht)

Wenn Match:
> "Webhook-Timing-Problem jetzt 2× aufgetreten. 2026-03-12 HeroSoftware, jetzt Resolvia. Wissens-Eintrag `02-wissen/n8n/webhook-race-condition.md`? Vertrauen: `abgeleitet`."

Bei OK: Wissens-Eintrag mit:
- `vertrauen: abgeleitet`
- `quellen: [[log1]], [[log2]]`
- `zuletzt_verifiziert: [heute]`
- `projekte: [projekt1, projekt2]`

### Phase 3 — Verifiziert (beim dritten+ Auftreten)
Existierender Eintrag wird aktualisiert:
- `vertrauen: bestaetigt`
- `zuletzt_verifiziert: [heute]`
- Neue Quelle in `quellen`
- Neues Projekt in `projekte`

Diff zeigen, OK abwarten.

---

## Spezial-Regeln

### Architektur-Entscheidungen
Treten oft nur 1× auf aber hohen Transfer-Wert (z.B. "Cal.com Fork abgelehnt"). 

→ Wenn Deniz als "Design-Decision" / "Architektur-Entscheidung" labelt: sofort destillieren. `vertrauen: extrahiert`, `kategorie: entscheidung`.

### Debug-Fixes
Wenn Fix spezifisch für Error-Output mit eindeutigem Fingerprint: früher destillieren. Schon beim ersten Auftreten.

→ `kategorie: debug_fix`, `vertrauen: extrahiert`.

### Tool-Dokumentation
"So funktioniert Mantle API" / "Attio Convention" → `kategorie: referenz` oder `tool`. Direkt destillieren.

→ `vertrauen: extrahiert` (Deniz) oder `bestaetigt` (validiert).

---

## Widerspruchs-Check

Vor Erstellung/Update eines Wissens-Eintrags:
- Widersprechender Eintrag in Domain?
- Kompatibel mit anderem Pattern?

Bei Widerspruch:
- Kein neuer Eintrag
- `widerspricht:` Feld setzen, auf Log verweisen
- Deniz: "Widerspricht `02-wissen/n8n/webhook-batching.md`. Welcher Ansatz stimmt?"

---

## Regeln

- **Nie ungefragt destillieren.** Vorschlag, OK abwarten.
- **Quellen verlinken, nicht kopieren.** Details bleiben im Log.
- **Destillation ≠ Move.** Log bleibt. Wissens-Eintrag ist Aggregation.
- **Projekt-spezifisches nicht ins Wissen.** Nur transferables.
