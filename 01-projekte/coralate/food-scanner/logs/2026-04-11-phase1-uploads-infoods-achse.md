---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-11
art: fortschritt
vertrauen: bestätigt
quelle: manuell
werkzeuge: ["supabase"]
---

## Status

Alle 7 DB-Samples hochgeladen (BLS, CIQUAL, USDA Foundation+SR Legacy, CoFID, NEVO, TürKomp, STFCJ). CIQUAL-2025-Doku vollständig analysiert (3.484 Foods × 74 Komponenten, per 100g essbarer Anteil, A-D Confidence-Codes, INFOODS-Codes).

## Durchbruch: INFOODS-Codes

FAO definiert globalen Standard für Nährstoff-Identifier (ENERC, PROCNT, VITC, FE…). Alle seriösen FCDs nutzen intern INFOODS-Codes. **Harmonisierung läuft über diese Codes statt über Spaltennamen-Raten.**

## Tabellen-Entscheidung: EINE `nutrition_db`

Nicht pro Land getrennt. Eine Tabelle mit `source`-Flag, `source_id`, `name_original`, `name_en`, `origin_country` (Metadata NICHT Filter), 14 Mikro- + 5 Makro-Spalten nach INFOODS, `confidence_code`, `embedding vector(1536)`, `food_group`.

**Begründung:** pgvector-Cosine-Search über alle Quellen gleichzeitig. RRF re-rankt mit Geo als Soft Hint. Separate Länder-Tabellen würden Cross-Country-Matching unmöglich machen.

## Edamam raus, OFF bleibt

Edamam hat nur Enterprise $29+/Monat. Stattdessen: OFF via Live-API für Barcodes (gratis, kein Key) + OFF CSV-Stream direkt aus Internet in pgvector beim Import.

## Einziger Secret

`OPENAI_API_KEY` - alles andere braucht keine Keys.
