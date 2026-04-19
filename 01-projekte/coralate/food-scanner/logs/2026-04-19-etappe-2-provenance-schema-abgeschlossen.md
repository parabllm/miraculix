---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-19
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["supabase"]
---

Etappe 2 der Nutrient-DB-Roadmap durch. Provenance-Schema mit pro-Nutrient-Auflösung steht. Alle 23.305 Rows haben jetzt einen `provenance.values` Block der für jeden der 20 Nutrient-Spalten dokumentiert ob `measured` oder `none`. Ohne diesen Schritt wäre Etappe 3 (Borrowing) nicht nachvollziehbar gewesen.

## Schema

Bestehendes `provenance.source_file` bleibt. Neuer Block `provenance.values`:

```json
{
  "source_file": "USDA_SR/food_nutrient.csv",
  "values": {
    "enerc_kcal": { "method": "measured", "source": "USDA_SR/169909" },
    "vitd_ug":    { "method": "none" }
  }
}
```

Pro Nutrient ein Eintrag, 20 Einträge total. Etappe 3 wird `borrowed_from` als dritte Methode hinzufügen ohne das Schema zu ändern.

## Implementation

- Postgres-Funktion `build_value_provenance()` die pro Row das `values`-Objekt baut
- Backfill via UPDATE in 5 Chunks à 5000 Rows (ein einziger UPDATE über 23.305 hatte Timeout)
- Idempotent: kann mehrfach laufen, der UPDATE filtert via `WHERE NOT (provenance ? 'values')`
- Rollback: `UPDATE nutrition_db SET provenance = provenance - 'values'`

## Coverage-Bericht

Lückenanalyse für Etappe 3, geordnet von höchster zu niedrigster Coverage:

| Nutrient | Measured | None | % |
|---|---:|---:|---:|
| Makros (kcal, P, C, F) | 23305 | 0 | 100% |
| Sodium | 22759 | 546 | 97.7% |
| Calcium | 22450 | 855 | 96.3% |
| Iron | 22380 | 925 | 96.0% |
| Potassium | 22171 | 1134 | 95.1% |
| Magnesium | 21945 | 1360 | 94.2% |
| Zinc | 21744 | 1561 | 93.3% |
| Thiamine | 21665 | 1640 | 93.0% |
| Vitamin C | 20554 | 2751 | 88.2% |
| Riboflavin | 19276 | 4029 | 82.7% |
| Niacin | 19246 | 4059 | 82.6% |
| Fiber | 16654 | 6651 | 71.5% |
| Vitamin E | 16549 | 6756 | 71.0% |
| Vitamin D | 16436 | 6869 | 70.5% |
| Vitamin B6 | 11849 | 11456 | 50.8% |
| Folate | 11758 | 11547 | 50.5% |
| Vitamin A | 11027 | 12278 | 47.3% |

Total NULL-Slots: 65.351 über alle 20 Nutrient-Spalten.

## Implications für Etappe 3

- Makros nicht borgen, schon komplett
- Mineralien: kleine Lücken, Borrowing einfach (homogene Profile innerhalb Kategorie)
- Vitamin A, B6, Folate: ~50% Lücken, hauptsächliche Arbeit. Hier bringt Borrowing am meisten Coverage-Gewinn.
- Vitamin D: 30% Lücken, biologisch limitiert (kommt in wenigen Foods natürlich vor), Borrowing wird hier vorsichtig sein müssen weil zwischen 0 und Wert-vorhanden fast bimodal

Realistic Coverage-Erwartung nach Etappe 3: 80-95% je nach Nutrient. Vollständige 100% nicht erreichbar weil bestimmte Mikros in bestimmten Lebensmittelgruppen biologisch fehlen.

## Cost

0. Reine SQL-Operation, kein LLM, kein API-Geld.

## Nächste Schritte

- Etappe 3: Cross-DB Borrowing. Jetzt mit funktionierendem Provenance-Schema voll dokumentiert. Erste Frage: Borrowing-Strategy für Vitamin A (höchste Lücke, 12.278 NULLs) als Pilot, dann Roll-out.
