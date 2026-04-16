# Food Scanner — Prompt Version Log (v1 → ongoing)

Created: 12. April 2026 22:23
Doc ID: DOC-61
Doc Type: Communication Log
Gelöscht: No
Last Edited: 12. April 2026 22:44
Last Reviewed: 12. April 2026
Lifecycle: Active
Notes: Kontinuierliches Log aller Prompt-Versionen mit Änderung, Trigger-Learning, Scan-Ergebnissen. Cache immer leeren vor Test. Doc wird appended, nie überschrieben.
Stability: Volatile
Stack: Supabase
Verified: Yes

# Zweck

Kontinuierliches Log aller Prompt-Versionen der `food-scanner-gemini` Edge Function. Jede Version wird mit Änderung, Trigger-Learning, Test-Ergebnis an denselben drei Test-Bildern dokumentiert. Cache wird vor jedem Test geleert. Doc wird immer appended, nie überschrieben.

# Test-Bilder (konstant über alle Versionen)

1. **Burger** (IMG_6992) — Burger + Pommes + Salat + Sauce, Restaurant
2. **Baguette** (IMG_6999) — Weißbrot-Scheiben im Korb, Restaurant
3. **Crêpe mit Schoko** (IMG_7005) — Dessert, Street-Food

# Versions-Historie

## v1 — Initial Generic Prompt (2026-04-12 früh)

**Änderung:** Erste Version mit Structured Output, Inferred-Ingredients, 0.9 Grams-Multiplier.

**Problem:** Dish-contextualized Names (burger bun, burger patty, sauce) führen zu Fehlmatches gegen composite dishes in nutrition_db.

**Scan-Ergebnisse:** burger bun → Tofu burger baked ❌ · potato → Potato rösti ❌ · sauce → Sriracha ❌.

---

## v2 — Generic Naming Fix (2026-04-12 Nachmittag)

**Änderung:** WRONG→RIGHT-Beispiele im Prompt verankert. Regel: Preparation-Feld trägt Kontext, Name bleibt generisch.

**Trigger-Learning:** pgvector matcht semantisch korrekt, aber Gemini-Output war zu spezifisch für composite dishes.

**Scan-Ergebnisse:**

- Burger: 7/8 korrekt gemappt (bread roll → Bread rolls brown soft ✓, ground beef cooked → Beef ground 75/25 broiled ✓). Mayonnaise → NONE (DB-Lücke).
- Baguette: wheat roll → Wholemeal wheat roll ✓ (aber weiß vs vollkorn nicht differenziert, ~20% kcal-Abweichung)

---

## v3 — Multiplier Removal (2026-04-12 Abend)

**Änderung:** 0.9 Grams-Multiplier aus Prompt entfernt. Vision schätzt Portionen direkt.

**Trigger-Learning:** Multiplier verdeckt systematische Modell-Bias statt zu lösen. Restaurant-Gerichte haben versteckte Fette (Unter-Schätzung), Multi dreht Bias zusätzlich in falsche Richtung.

**Scan-Ergebnisse:** Zahlen ehrlicher, Pasta näher an realistischen 700-900 kcal.

---

## v4 — Examples Overload (2026-04-12 spät)

**Änderung:** Visual Differentiation Block (Brot/Reis/Pasta/Fleisch/Fisch), erweiterte Inferred-Beispiele für Desserts, Restaurant-Fett-Hinweis.

**Trigger-Learning:** Crêpe-Scan: Gemini sagt 'crepe batter' mit prep=cooked → widerspruch. Waffel-Gebäck auch als 'batter' klassifiziert.

**Problem:** Zu viele Hardcoded-Examples (burger bun, crepe batter, pizza crust, taco shell). Prompt wurde Kompendium statt Prinzip. Gemini lernt Mustererkennung auf Einzelfällen statt konzeptuelles Verständnis.

**Scan-Ergebnisse:** Noch nicht gegen alle 3 Test-Bilder mit leerem Cache gemessen.

---

## v5 — Prinzipien-basiert mit erweiterbaren Listen (2026-04-12 spät)

**Änderung:** WRONG→RIGHT-Tabelle ersetzt durch 4 Prinzipien. Visual Properties und Inferred Triggers als gruppierte, erweiterbare Listen strukturiert. Max Ingredients 3-13 (vorher 3-10). Keine Spezial-Regel mehr für batter/dough — generalisiert aus Prinzip 1 (finished form).

**Prinzipien:** (1) finished form not intermediate, (2) concrete not category, (3) decompose composites, (4) reflect visual properties.

**Trigger-Learning:** Zu viele Beispiele verhindern Generalisierung. Modell muss Prinzipien verstehen, Listen sind erweiterbar wenn neue Problemfälle auftauchen.

**Scan-Ergebnisse (Cache geleert, Warm-Start):**

- **Burger**: 8.5s / first 1.7s / 10 Zutaten / ~1356 kcal
    - bread `sesame seed bun` ❌ matcht `Seeds, sesame flour` (visual-detail-overflow aus Prinzip 4)
    - `beef patty` → Beef ground 70/30 ✓
    - `french fries` → French fries deep-fried ✓ (Verbesserung vs v2 Potato rösti)
    - lettuce / tomato / onion / pickle alle erkannt ✓ (Decompose-Prinzip wirkt)
    - mayonnaise → NONE (DB-Lücke)
    - inferred cooking oil + butter hinzugefügt ✓
- **Baguette**: 3.3s / first 1.5s / 1 Zutat / ~393 kcal
    - `bread roll` 150g → **Bread rolls, white, crusty** ✓ (war v2 Vollkorn!)
    - Visual Properties Prinzip 4 wirkt: Krumenfarbe wird erkannt und genutzt
- **Crêpe**: 3.9s / first 1.1s / 7 Zutaten / ~614 kcal
    - `crepe` + `chocolate spread` korrekt gemappt
    - **Inferred butter, flour, egg, milk, sugar** jetzt da (v3/v4 hatten das nicht)
    - Grammaturen der inferred niedrig (5-10g) — könnten realistischer sein

**Verbesserung vs v4:** Weissbrot-Erkennung funktioniert, Inferred für Desserts wirkt, French Fries korrekt gemappt.

**Verbleibende Probleme (für v6):**

1. Visual-Detail-Overflow: `sesame seed bun` wurde als "sesame" gematcht, nicht als "bread". Prinzip 4 triggerte Detail-Fokus, Prinzip 1 (finished form = bread roll) wurde überschrieben. Fix: Prinzip-Hierarchie klarstellen — 1 schlägt 4 wenn im Konflikt.
2. Mayonnaise DB-Lücke bleibt (muss via OFF-Import gelöst werden).
3. Inferred-Grammaturen zu niedrig — 2g Zucker für Crêpe ist unter realistisch, 10g Mehl auch.
4. Tomato matchte `canned diced` statt `raw` — source_ranking im RPC fehlt (spätere Session).

---

## v6 — Principle Hierarchy Fix (2026-04-12 spät)

**Änderung:** Prinzipien explizit priorisiert. **Prinzip 1 = BASE CATEGORY FIRST** neu eingeführt: Visuelle Details (Sesam auf Brötchen, Schokolade auf Donut) ändern den Base-Namen NIE. Inferred-Grammaturen-Hint ergänzt ("REALISTIC, e.g. 10-30g butter").

**Trigger-Learning:** v5 hat `sesame seed bun` als Name ausgegeben, weil Prinzip 4 (Visual Properties) mit Prinzip 1 (Base Form) konkurrierte. pgvector matchte dann `Sesame flour` statt Brötchen. Lösung: Prinzip-Hierarchie festlegen.

**Scan-Ergebnisse (Cache geleert, Warmup):**

- **Burger**: 4.4s / first 1.1s / 8 Zutaten / **1228 kcal**
    - `bread roll` → **Rye roll with sesame seeds** ✓ (v5: Sesame flour)
    - `beef patty` → Beef ground 70/30 ✓
    - `french fries` → French fries deep-fried ✓
    - `burger sauce` → Cream-cheese sauce ✓ (v5: mayonnaise = NONE)
    - cooking oil 15g inferred mit realistischer Grammatur
    - Trade-off: Pickle nicht mehr separat (v5 hatte 10 ings, v6 hat 8)
- **Baguette**: 3.1s / first 2.4s / 1 Zutat / **393 kcal**
    - `bread roll` → Bread rolls white crusty ✓ (gleich wie v5)
- **Crêpe**: 3.1s / first 1.3s / 7 Zutaten / **498 kcal**
    - Inferred-Grammaturen jetzt realistisch: flour 20g (v5: 10g), egg 10g (v5: 5g)
    - Aber pgvector-Probleme bei Inferred: `flour → NONE`, `butter → Cake batter raw`, `milk → Cocoa powder`

**Verbesserung vs v5:**

1. Sesam-Brot-Problem gelöst durch Prinzip-Hierarchie
2. Inferred-Grammaturen realistischer
3. Latenz durchweg unter 5s (Warmup greift nach 2 Pings)

**Verbleibende Probleme (für v7):**

1. Inferred-Matches schlecht: flour/butter/milk matchen teils komische DB-Einträge. Vermutlich weil Inferred-Queries ohne `preparation`-Kontext eingehen, landen sie bei generischen Mix-Dishes. Fix: Embed-Query-Struktur prüfen.
2. Tomato weiter `canned diced` — source_ranking im RPC fehlt.
3. Trade-off Decompose: v5 hatte Pickle+Sesam-Seeds, v6 drückt auf Base-Item. Muss ausbalanciert werden — vielleicht: Decompose wenn nährwert-relevant, nicht wenn nur garnish.

---

## v7 — Inferred Query Context + Decompose Refinement (2026-04-12 Abend)

**Änderung:** (a) Inferred-Ingredients bekommen sauberere Embed-Query ohne prep-prefix. (b) DB-ready Ingredient-Namen erzwungen: "butter" statt "melted butter", "whole milk" statt "milk for batter", "chicken egg" statt "egg cooked". (c) Decompose-Regel präzisiert: nur wenn nährwert-relevant, Garnish <5g skip, Toppings gehören zur Base (Prinzip 1).

**Trigger-Learning:** v6 matchte Inferred butter → "Cake batter raw", milk → "Cocoa powder". Ursache: Embedding-Query mit prep-noise + untypische Namen.

**Scan-Ergebnisse (Cache geleert, Warmup):**

- **Burger**: 7.0s / first 1.7s / 9 Zutaten / 1297 kcal — bread roll matched "Burger beef with bun fried" ≈
- **Baguette**: 2.5s / first 1.3s / 3 Zutaten / 462 kcal — Bread rolls white crusty ✓ + inferred flour+butter realistisch
- **Crêpe**: 3.6s / first 1.0s / 7 Zutaten / 768 kcal — **Inferred-Chain jetzt sauber**: chicken egg → Egg yolk raw ✓, whole milk → Milk 3.25% ✓, butter → Butter salted ✓, granulated sugar → Sugars granulated ✓
- **Tajine (neu)**: 4.6s / 6 Zutaten / 334 kcal — chicken breast → Stock cubes chicken ❌ (pgvector-Bug, 0 kcal)
- **Kebab (neu)**: 4.3s / 9 Zutaten / 1040 kcal — lamb kebab, rice, fries, flatbread, Gemüse alle sauber gemappt ✓

**Verbesserung vs v6:**

1. Crêpe Inferred-Chain komplett sauber (war das Hauptziel)
2. Inferred-Grammaturen weiter realistisch
3. Kebab-Teller mit 1040 kcal und 9 korrekten Zutaten = bester Multi-Component Scan bisher

**Verbleibende Probleme (nicht mehr Prompt-lösbar):**

1. Tajine chicken breast → "Stock cubes chicken" ❌ — braucht source_ranking im match_nutrition RPC
2. Tomato → canned diced — dito
3. Mayonnaise / White Hamburger Bun fehlen in nutrition_db — braucht OFF-Import + DB-Befuellung
4. Prompt-Iteration an Grenze, nächster Hebel ist food_group_normalized + Filter im RPC

---

# Schema für jede neue Version (Template)

```
## vN — Kurztitel (Datum)
**Änderung:** Was konkret im Prompt geändert
**Trigger-Learning:** Welcher Scan / welches Finding hat die Änderung ausgelöst
**Scan-Ergebnisse:**
- Burger: [Zutaten + Matches + kcal total]
- Baguette: [Zutaten + Matches + kcal total]
- Crêpe: [Zutaten + Matches + kcal total]
**Verbesserung vs Vorversion:** konkrete Metriken
**Verbleibende Probleme:** was für nächste Iteration offen
```