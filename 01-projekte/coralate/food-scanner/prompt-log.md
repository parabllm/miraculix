---
typ: aufgabe
name: "Food Scanner Prompt Version Log"
projekt: "[[food-scanner]]"
status: in_arbeit
benoetigte_kapazitaet: niedrig
kontext: ["desktop"]
kontakte: []
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Kontinuierliches Log aller Prompt-Versionen der Vision Edge Function. Append-only, nie überschreiben. Cache vor jedem Test leeren.

## Test-Bilder (konstant)

1. **Burger** (IMG_6992) - Burger + Pommes + Salat + Sauce, Restaurant
2. **Baguette** (IMG_6999) - Weißbrot-Scheiben im Korb, Restaurant
3. **Crêpe mit Schoko** (IMG_7005) - Dessert, Street-Food

## Aktuelle Version: v6 (Food Groups + Ambiguity + Grams)

**Stand 2026-04-19 Abend.** Deployed als food-scanner v16. Drei Kernänderungen gegenüber dem v15 Production-Prompt (80 Tokens): `food_group` als Pflichtfeld mit 19-Werte-Enum eingeführt, Ambiguity Rule mit expliziten Default-Formen für häufige Ambiguitäten (egg, flour, rice, milk, sugar), Grams Estimation mit Hand/Utensil/Whole-Item-Ankern.

**Adressierte Bugs:**
- chicken egg → egg white: Ambiguity Rule setzt "whole chicken egg" als Default
- wheat flour → whole-grain: Ambiguity Rule setzt "white wheat flour" als Default
- banana 300g statt 120g: Grams-Anker mit medium banana peeled 120g als Referenz
- garlic Null-Micros-Row: indirekt adressiert über food_group Pre-Filter (Retrieval-Integration ist Phase 5)

**Bewusst weggelassen:** state-Enum (raw, cooked, baked, fried, dried, canned, juice, puree, whole) komplett raus. Entscheidung: erst food_group testen und die Prompt-Bugs beheben, state-Feld in einer späteren Version wenn food_group-Klassifikation stabil läuft.

**Token-Count:** grob 310-340 Input-Tokens, Vervierfachung gegenüber v15 (80 Tokens), im Budget-Ziel 250-400.

**Architektur-Hinweis (Stand 2026-04-19 Abend, seit food-scanner v17 aktualisiert):** `food_group` Output ist additiv zum Frontend-Contract DOC-62. **Update:** Food-Scanner Edge Function ruft ab v17 `match_nutrition` mit `food_group_filter` aus dem Vision-Output auf. Das Feld wird jetzt aktiv für Pre-Filter-Retrieval genutzt. Bei leerem Filter-Ergebnis silent Fallback auf unfiltered RPC-Call, `fallback_triggered: true` wird pro Ingredient persistiert. Details in [[architektur-v8]].

**Offene Entscheidung:** Fallback `prepared_dishes` wird vom Prompt als Ausweg bei nicht-decomposbaren Composites zugelassen. Live-Test muss zeigen ob Gemini das nicht als generischen Escape-Hatch missbraucht.

## Versions-Historie

### v1 - Initial Generic Prompt (2026-04-12 früh)

Erste Version mit Structured Output, Inferred-Ingredients, 0.9 Grams-Multiplier.

**Problem:** Dish-contextualized Names (burger bun, burger patty, sauce) führten zu Fehlmatches gegen composite dishes in nutrition_db.

**Ergebnisse:** burger bun → Tofu burger baked ❌, potato → Potato rösti ❌, sauce → Sriracha ❌

### v2 - Generic Naming Fix (2026-04-12 Nachmittag)

WRONG→RIGHT-Beispiele im Prompt verankert. Regel: Preparation-Feld trägt Kontext, Name bleibt generisch.

**Ergebnisse:** Burger 7/8 korrekt (bread roll → Bread rolls brown soft ✓, ground beef cooked → Beef ground 75/25 broiled ✓). Mayonnaise → NONE (DB-Lücke). Baguette: wheat roll → Wholemeal wheat roll ✓ aber weiß vs vollkorn nicht differenziert (~20% kcal-Abweichung).

### v3 - Multiplier Removal (2026-04-12 Abend)

0.9 Grams-Multiplier aus Prompt entfernt. Vision schätzt Portionen direkt.

**Trigger-Learning:** Multiplier verdeckt systematische Modell-Bias statt zu lösen. Restaurant-Gerichte haben versteckte Fette (Unter-Schätzung), Multi dreht Bias zusätzlich in falsche Richtung.

**Ergebnisse:** Zahlen ehrlicher, Pasta näher an realistischen 700-900 kcal.

### v4 - Examples Overload (2026-04-12 spät)

Visual Differentiation Block (Brot/Reis/Pasta/Fleisch/Fisch), erweiterte Inferred-Beispiele für Desserts, Restaurant-Fett-Hinweis.

**Problem:** Zu viele Hardcoded-Examples (burger bun, crepe batter, pizza crust, taco shell). Prompt wurde Kompendium statt Prinzip. Gemini lernt Mustererkennung auf Einzelfällen statt konzeptuelles Verständnis.


### v5 (aktiv bis 2026-04-13)

Dokumentiert als Prinzipien-basiert mit 4 Regeln (Finished form / Concrete / Decompose / Reflect visual). Tatsächlich im Production-Code steht eine noch kompaktere Variante (ca 80 Tokens), die diese Prinzipien nicht explizit aufzählt. Dokumentations-Lücke festgestellt 2026-04-19.

### Production-Stand 2026-04-19 (food-scanner v15)

Aktiver Prompt in `food-scanner/prompts.ts`:

```
You are a precise food-vision system. Analyze the PRIMARY PLATE only.

Return STRICT JSON: { "dish_name": string, "ingredients": [{ "name": string, "grams": number, "preparation": string, "visibility": "visible" | "inferred" }] }

NAMING: Base food as in nutrition database. Concrete not category. Decompose if nutritionally relevant. Skip <5g garnishes.

INFERRED INGREDIENTS: Add invisible items (cooking oil, butter, dressing, eggs in batter). Realistic grams. Name as database-ready (butter, wheat flour, whole milk, granulated sugar, chicken egg).

OUTPUT: 3-13 ingredients max. No prose outside JSON.
```

Token-Count ca 80 Input-Tokens. Sehr kompakt, günstig, aber unter-spezifiziert.

### Analyse auf echten Scans (2026-04-19)

Erste strukturierte Evaluation mit 5 erfolgreichen Einträgen aus `food_scan_log`. Fünf Bugs mit Faktor-Impact auf Nutrient-Werte identifiziert:

**chicken egg → chicken egg white, raw.** Spätzle-Scan. sim 0.70. Eiweiß hat 42 kcal/100g, ganzes Ei 150 kcal/100g. Faktor 3.5x Unterschätzung. Prompt-Wording "chicken egg" ist ambig.

**garlic → USDA_FND Row mit Null-Mikros.** sim 0.813, aber der Kandidat hat k_mg=0, ca_mg=0, fe_mg=0, mg_mg=0, na_mg=0. DB-Hygiene-Problem, nicht Prompt. Die match_nutrition RPC muss Kandidaten mit überwiegend Null-Mikros aus Top-Matches filtern.

**water und granulated sugar → 0 matches bei iced coffee.** 10g Zucker sollten 40 kcal beitragen, verloren. iced coffee zeigt 4 kcal statt 45. Kein Fallback implementiert bei leerem Match-Ergebnis.

**wheat flour → whole-grain matched statt white.** Spätzle wird mit Weißmehl gemacht. Prompt sagt nur "wheat flour", keine Weiß/Vollkorn-Unterscheidung. Impact 20-30% abweichende Nutrient-Werte.

**banana 300g statt 120g geschätzt.** 276 kcal für eine Banane. Prompt gibt keine Referenzgrößen für häufige Items.

### v6 - Food Groups + Ambiguity + Grams (2026-04-19 Abend, deployed als food-scanner v16)

Drei Hebel gleichzeitig, alle prinzipienbasiert nicht listengetrieben.

**1. food_group als Pflichtfeld.** 19-Werte-Enum aligned mit `nutrition_db.food_group_normalized`. Groups: meat_unprocessed, meat_processed, seafood, dairy_eggs, vegetables, fruits, grains_pasta, bakery, legumes_nuts_seeds, sauces_condiments, fats_oils, sweets_desserts, beverages_nonalcoholic, beverages_alcoholic, herbs_spices, breakfast_cereals, snacks, plant_based_alternatives, prepared_dishes. `food_additives` und `supplements` aus dem Schema gelassen (Vision-irrelevant, 172 + 93 Rows). Kurze Klassifikations-Hinweise für die 5 häufigsten Grenzfälle: processed vs unprocessed meat, bakery vs grains_pasta, dairy_eggs als Sammelkategorie, plant_based_alternatives, prepared_dishes nur als letzter Ausweg. Explizite Decomposition-Rule: beim Zerlegen eines Gerichts werden alle Komponenten einzeln klassifiziert, nie als prepared_dishes.

**2. Ambiguity Rule.** Generisches Prinzip "most common everyday form" mit fünf expliziten Defaults als Beispiel: egg → whole chicken egg, flour → white wheat flour, rice/pasta/bread → white unless visibly darker, milk → cow whole milk, sugar → white granulated. Generalisiert auf weitere Cases die nicht gelistet sind.

**3. Grams Estimation mit Ankern.** Hand-Referenzen (palm 100g meat, fist 150g rice cooked), Utensil-Referenzen (tablespoon 15g oil, teaspoon 5g), plus fünf Whole-Item-Referenzen (egg 50g, banana 120g, apple 180g, bread slice 30g, cheese slice 20g). Prinzip: visuelle Anker statt absolute Schätzung.

**Was bewusst weggelassen:** state-Enum, name_en, DB-Naming-Konvention, Mass-Lookup-Tabelle. Entscheidung: ein Hebel nach dem anderen testen. state kommt in eine spätere Version wenn v6-Baseline klar ist.

**Bugs die v6 adressiert:** chicken egg (Ambiguity), wheat flour (Ambiguity), banana 300g (Grams-Anker). Seit food-scanner v17 (RPC-Integration) adressiert der food_group Pre-Filter zusätzlich den garlic Null-Micros-Bug und vermindert Cross-Group-Misfires (avocado → avocado oil, strawberry → rhubarb). sugar/water 0 matches bleibt offen (brauchen andere Fallback-Strategie: Query-Simplification statt Filter-Removal).

**Token-Count:** grob 310-340 Input-Tokens.

**Test-Plan:** Live-Scans auf dem Handy, 5-8 Testfälle quer durchs Spektrum: Ei-Gericht, Mehl-Gericht, Obst, Fleisch, Restaurant-Teller, Dessert, Beverage, Composite. Analyse der `food_scan_log` Einträge mit Fokus auf food_group-Klassifikations-Qualität und Grams-Schätzung. Seit v17 zusätzlich: `fallback_triggered` Flag pro Ingredient beobachten (hohe Fallback-Rate = Vision klassifiziert falsch) und Retrieval-Qualität mit Pre-Filter vs ohne vergleichen.

## Test-Infrastruktur

Aktuell keine strukturierte Test-Suite für Prompts. Die 3 historischen Test-Bilder (Burger, Baguette, Crêpe) wurden manuell via `curl` gegen die Edge Function getestet. Regression-Testing erfolgte nur ad-hoc.

Für v6 vorgesehen: eigenes Test-Script mit Fixture-Bildern und automatisiertem Compare gegen erwartete Ingredient-Listen. Spec noch zu entwickeln.
