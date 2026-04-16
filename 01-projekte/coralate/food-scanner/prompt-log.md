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

## Aktuelle Version: v5 (Prinzipien-basiert)

**Stand 2026-04-12 spät.** WRONG→RIGHT-Tabelle ersetzt durch 4 Prinzipien. Visual Properties und Inferred Triggers als gruppierte, erweiterbare Listen. Max Ingredients 3-13 (vorher 3-10). Keine Spezial-Regel mehr für batter/dough - generalisiert aus Prinzip 1.

**Prinzipien:**
1. Finished form, not intermediate
2. Concrete, not category
3. Decompose composites
4. Reflect visual properties

**Trigger-Learning:** Zu viele Beispiele verhindern Generalisierung. Modell muss Prinzipien verstehen, Listen sind erweiterbar wenn neue Problemfälle auftauchen.

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
