---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-13
art: fortschritt
vertrauen: bestaetigt
quelle: chat_session
werkzeuge: ["supabase"]
---

Nutrition-DB komplett zurückgesetzt und sauber neu importiert. **Auslöser:** Cross-DB Borrowing hatte Mikros semantisch verzerrt (Tofu-Burger borgte Rind-B12 von Frikadellen-Nachbarn).

## Entscheidung

Rohdaten-Only, keine Borrowing-Krücke. Multi-Layer-Retrieval als echte Lösung.

## Was jetzt in der DB ist

- **23.305 Rows** (vorher 25.623)
- BLS 7.090, USDA_SR 7.793, USDA_FND 135, CIQUAL 3.323, COFID 2.636, NEVO 2.328
- OFF komplett entfernt (kommt via Live-API + Lazy-Load zur Laufzeit)
- Alle Rows mit **100% Makro-Komplettheit** (kcal+protein+fat+carbs gefüllt)
- 0 Embeddings (NULL) - wird nächster Chat entscheiden wann/wie
- 0 borrowed-Tags in Provenance
- 2 Dezimalstellen-Rundung auf alle Numerics
- Ausreißer-Check: alle 900+ kcal-Einträge sind Öle/Fette (wissenschaftlich korrekt)

## Neue Architektur-Entscheidung: OFF Lazy-Load

OFF wird **NICHT mehr importiert**. Stattdessen:

1. Cache-Check in `nutrition_db` (`source='OFF'`, `source_id=barcode`)
2. Bei MISS: OFF Live-API-Call → Mapping auf 20-Spalten-Schema → Kategorisierung via Multi-Layer-System → fehlende Mikros via Cross-DB-Borrowing aus wissenschaftlicher Referenz → Insert mit `ON CONFLICT DO NOTHING`
3. Bei zweitem Scan desselben Produkts: instant Cache-Hit

## Frontend-Contract Status

**Komplett unberührt.** SSE-Events, Edge-Function-Signaturen, `food_scan_log`-Schema, RLS - nichts ändert sich. Jann's App merkt keinen Unterschied zwischen alt und neu.

## Nächster Schritt

Multi-Layer-Retrieval designen + implementieren. Kategorie-Backfill via LLM, Embedding-Generation, `match_nutrition` RPC erweitern um `food_group_filter`, Lazy-Load-Mechanismus für OFF.
