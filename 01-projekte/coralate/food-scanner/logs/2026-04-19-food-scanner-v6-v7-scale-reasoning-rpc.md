---
typ: log
name: "Food Scanner v6 bis v7 Scale Reasoning plus RPC Food-Group-Filter"
projekt: "[[food-scanner]]"
datum: 2026-04-19
kapazitaet: hoch
kontext: ["desktop", "live-test-handy"]
quelle: claude-session
vertrauen: direkt
---

## Was heute passiert ist

Abend des 2026-04-19, ausgedehnte Session mit Claude zu Vision-Prompt-Iteration, RPC-Integration und State-of-the-Art Research zur Grams-Schätzung. Kontext: Borrow-Script lief parallel, Edge Function und RPC konnten aber unabhängig erweitert werden.

## Ausgangslage

Aktiver Prompt war v5 dokumentiert aber v15-Production-Code hatte nur 80-Token-Variante. Dokumentations-Lücke. Fünf Bugs aus v6-Live-Analyse bekannt (Ei, Mehl, Banane, Garlic, Water/Sugar).

## Schritt 1: Prompt v6 (Food Groups plus Ambiguity plus Grams)

Deployed als food-scanner v16. Drei Hebel gleichzeitig:

- `food_group` als Pflichtfeld im Output, 19-Werte-Enum aligned mit `nutrition_db.food_group_normalized`
- Ambiguity Rule als generisches Prinzip mit fünf Default-Beispielen (egg, flour, rice, milk, sugar)
- Grams Estimation mit Hand/Utensil/Whole-Item-Ankern

Token-Count: 310 bis 340 Input-Tokens (vs. 80 vorher). state-Enum bewusst weggelassen (später).

Live-Test erfolgreich: Erdbeeren und Gurken sauber klassifiziert (fruits, vegetables). Grams bei Erdbeeren 300g und Gurken 600g wirkten plausibel.

## Schritt 2: RPC-Erweiterung `match_nutrition`

`match_nutrition` RPC um optionalen Parameter `food_group_filter text DEFAULT NULL` erweitert. Migration `match_nutrition_add_food_group_filter` plus `match_nutrition_drop_old_signature` (alte Zwei-Parameter-Signatur gedroppt gegen Function-Overloading-Ambiguität).

Borrow-Script bleibt kompatibel weil es `match_nutrition(embedding, match_count)` aufruft, neue Function nimmt food_group_filter als DEFAULT NULL und verhält sich dann identisch.

Food-Scanner v17 deployed: ruft RPC mit food_group aus Vision-Output auf. Silent Fallback auf unfiltered RPC wenn Filter 0 Matches liefert. Enriched Ingredient bekommt `filter_used` und `fallback_triggered` als Debug-Felder.

## Schritt 3: Live-Test Nudel-Gerichte zeigt fundamentales Grams-Problem

Drei Scans derselben Mahlzeit "Penne with Tuna Sauce" mit unterschiedlichen Portionsgrößen (zwei verschiedene Behältergrößen). Auswertung der ingredients JSONB via SQL:

| Ingredient | Scan 1 | Scan 2 | Scan 3 |
|---|---|---|---|
| penne pasta | 200g | 200g | 200g |
| tuna | 100g | 100g | 100g |
| olive oil | 15g | 15g | 15g |
| garlic | 5g | 5g | 5g |
| salt | 2g | 2g | 2g |
| black pepper | 1g | 1g | 1g |

Sechs von acht Zutaten kriegen in drei verschiedenen Bildern exakt dieselben Gramm-Werte. Das sind Default-Serving-Sizes aus Gemini's Trainingsdaten, keine Bild-Schätzungen.

## Schritt 4: Research zu State-of-the-Art

Vier relevante Erkenntnisse:

1. Cal AI hat 20 bis 30 Prozent Fehlermarge, bei komplexen Gerichten bis 50 Prozent. MFP, Lose It, Snap Calorie ähnlich.
2. Akademische Studie ChatGPT-4o vs Claude 3.5 Sonnet vs Gemini 1.5 Pro zeigt systematische Unterschätzung großer Portionen, hohe Variabilität.
3. State-of-the-Art (3D Reconstruction plus Reference Objects via SAM plus YOLO) erreicht 17 Prozent Fehler, aber aufwendig.
4. Prompt-Level: explizite "estimate based on size relative to other objects, not typical serving sizes" wirkt messbar besser als implizite Anker.

Kernproblem ist mathematisch unterbestimmt: Scale-Ambiguity aus 2D-Bildern. LLMs kompensieren mit Trainingsdefaults.

## Schritt 5: Prompt v7 (Scale Reasoning Protocol)

Deployed als food-scanner v18. Sechs-Stufen-Protokoll:

1. Classify container in 7-Werte-Enum (large_plate, small_plate, deep_bowl, shallow_bowl, small_bowl, cup_mug, unknown)
2. Bidirectional scale check: Items-zu-Container UND Container-zu-Items konsistent
3. Count if possible mit inline per-piece-weights (penne 1g, egg 50g, cherry tomato 15g etc.)
4. Distance correction via Ratios statt Pixel
5. Emit grams, grams_confidence (low/medium/high), scale_anchor_used
6. Emit scale_reasoning als top-level Ein-Satz-Zusammenfassung

Schema-Erweiterungen:
- Top-Level: `container_type`, `scale_reasoning` (beide Pflicht, additiv zum Frontend-Contract)
- Pro Ingredient: `grams_confidence`, `count`, `scale_anchor_used` (alle Pflicht, additiv)

Neue DB-Spalte `scan_meta` JSONB in food_scan_log (Migration `food_scan_log_add_scan_meta`), speichert dish-level container_type, scale_reasoning, prompt_version.

Edge Function v18 extended: JSONParser um `$.container_type` und `$.scale_reasoning` erweitert, neue SSE-Events `container` und `scale_reasoning` während Streaming. `PROMPT_VERSION` Konstante in prompts.ts.

Token-Count v7: 650 bis 700 Input-Tokens. Über ursprünglichem Budget (250 bis 400), aber explizit OK gegeben weil Grams-Accuracy priorität.

## Deliverables

- Migration: `match_nutrition_add_food_group_filter`
- Migration: `match_nutrition_drop_old_signature`
- Migration: `food_scan_log_add_scan_meta`
- Edge Function food-scanner: v16 (Prompt v6) → v17 (RPC-Integration) → v18 (Prompt v7 plus scan_meta)
- Prompt-Log: v6 und v7 Einträge appended, Aktuelle-Version-Header auf v7
- Architektur-v8: v7-Sektion, neue SSE-Events, ScanMeta-Shape, Versions-Update, Match-Logik-Sektion mit Pre-Filter und Fallback

## Offene Live-Tests

1. Nudel-Vergleichstest mit v7: Werden sich grams-Werte zwischen großer und kleiner Schüssel jetzt tatsächlich unterscheiden? Das ist der primäre Erfolgstest gegen v6.
2. Scale-Reasoning-Qualität: Sind die ausgegebenen Sätze substantiell oder generisch?
3. Count-Feld-Nutzung: Bei zählbaren Items wirklich gesetzt?
4. Fallback-Rate bei food_group Pre-Filter: Wie oft triggert der Fallback in echten Scans?

## Roadmap: User-Correction-Loop (Phase B, nächste Session)

Priorität 1 nach v7-Live-Tests. Grundlage:

- `food_scan_log.user_corrections` JSONB wird vom confirm-Flow bereits geschrieben, aber nicht ausgewertet
- Ziel: SQL-View `ingredient_correction_stats` mit median correction factor pro Ingredient-Name
- Edge Function multipliziert Gemini-Estimate mit Correction-Factor nach Retrieval (initial global, später pro User)
- Verbindet später mit Cora: personal learning über Portion-Präferenzen pro User

## TASK: Frontend Einheiten-Auswahl (Jann-Abstimmung)

Aus Meeting mit Jann und dem letzten Coralate-Meeting: Frontend soll pro Ingredient nicht nur Gramm anzeigen, sondern kontextabhängige Einheiten-Optionen zur Korrektur:

- Eier: "2 Eier, 3 Eier, 4 Eier" als Quick-Select-Buttons
- Nudeln/Reis: "100g, 150g, 200g" plus Slider
- Sauce/Öl: "100 Prozent, 80 Prozent, 20 Prozent" der geschätzten Menge
- Tomaten/Kirschen/Obst: Stückzahl
- Fleisch/Fisch: Gramm

Pro Ingredient-Klasse eine eigene Unit-Strategy. Die Einheiten-Logik muss wissen welche Zutat welche sinnvollen Presets hat. Das `count`-Feld aus Prompt v7 passt direkt zu der Stückzahl-Option.

**Status:** nur dokumentiert, noch nicht implementiert. Backend-Input vom Vision-Prompt liegt bereit (count, grams, grams_confidence). Frontend-Umsetzung ist Jann-Thema, Backend muss evtl. Standard-Preset-Liste pro food_group mitliefern.

**Follow-up mit Jann:** abstimmen ob die Presets clientseitig hardcoded sind oder Backend eine Unit-Preset-API liefern soll. Letzteres sauberer für Cora-Personalisierung (Cora lernt welche Einheit der User pro Ingredient-Klasse nutzt).
