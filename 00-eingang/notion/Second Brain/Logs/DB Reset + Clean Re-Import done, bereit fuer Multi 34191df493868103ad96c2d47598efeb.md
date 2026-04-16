# DB Reset + Clean Re-Import done, bereit fuer Multi-Layer-Design

Confidence: Confirmed
Created: 13. April 2026 17:19
Date: 13. April 2026
Gelöscht: No
Log ID: LG-14
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Claude session
Summary: DB komplett zurueckgesetzt und neu importiert. 23.305 saubere Rows aus 6 wissenschaftlichen Quellen, 100% Makro-Komplettheit, keine Embeddings, keine Borrowing-Verzerrungen. OFF via Lazy-Load statt Full-Import. Frontend-Contract unberuehrt. Bereit fuer Multi-Layer-Design im naechsten Chat.
Type: Progress

**Verweis Status-Docs:**

- [Master Architecture v8 (DOC-62)](../Docs/Food%20Scanner%20%E2%80%94%20Master%20Architecture%20&%20Flow%20(v8)%2034191df493868161bdb9ce33655009f7.md)
- [Taxonomy Research (DOC-60)](../Docs/Food%20Scanner%20Retrieval%20%E2%80%94%20Taxonomy%20Research%20Finding%2034091df4938681aca08be3e64bb2058e.md)

## Was passiert ist

Nutrition DB komplett zurueckgesetzt und sauber neu importiert. Ausloeser: Cross-DB Borrowing hatte Mikros semantisch verzerrt (Tofu-Burger borgte Rind-B12 von Frikadellen-Nachbarn). Entscheidung: Rohdaten-Only, keine Borrowing-Krucke, Multi-Layer-Retrieval als echte Loesung.

## Was jetzt in der DB ist

- 23.305 Rows insgesamt (vorher 25.623)
- BLS 7.090, USDA_SR 7.793, USDA_FND 135, CIQUAL 3.323, COFID 2.636, NEVO 2.328
- OFF komplett entfernt (kommt via Live-API + Lazy-Load zur Laufzeit)
- Alle Rows mit 100% Makro-Komplettheit (kcal+protein+fat+carbs alle gefuellt)
- 0 Embeddings (NULL) - wird im naechsten Chat entschieden wann/wie
- 0 borrowed-Tags in provenance
- 2 Dezimalstellen-Rundung auf alle Numerics
- Ausreisser-Check: alle 900+ kcal Eintraege sind Oele/Fette, wissenschaftlich korrekt

## Neue Architektur-Entscheidung

OFF wird NICHT mehr importiert. Stattdessen Lazy-Load bei Barcode-Scan:

1. Cache-Check in nutrition_db (source='OFF', source_id=barcode)
2. Bei MISS: OFF Live-API Call, Mapping auf 20-Spalten-Schema, Kategorisierung via Multi-Layer-System, fehlende Mikros via Cross-DB-Borrowing aus wissenschaftlicher Referenz, Insert mit ON CONFLICT DO NOTHING
3. Bei zweitem Scan desselben Produkts: instant Cache-Hit

## Frontend-Contract Status

Komplett unberuehrt. SSE-Events, Edge Function Signaturen, food_scan_log Schema, alle RLS - nichts aendert sich. Jann's App merkt keinen Unterschied zwischen alt und neu.

## Naechster Schritt

Neuer Chat: Multi-Layer-Retrieval designen + implementieren. Kategorie-Backfill via LLM, Embedding-Generation, match_nutrition RPC erweitern um food_group_filter, Lazy-Load-Mechanismus fuer OFF. Vollstaendige Handover-Dokumentation in separatem Markdown bereitgestellt.