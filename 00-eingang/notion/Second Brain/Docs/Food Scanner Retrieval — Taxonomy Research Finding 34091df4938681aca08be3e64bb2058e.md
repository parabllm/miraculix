# Food Scanner Retrieval — Taxonomy Research Findings (20 Categories)

Created: 12. April 2026 21:00
Doc ID: DOC-60
Doc Type: Research
Gelöscht: No
Last Edited: 12. April 2026 21:00
Last Reviewed: 12. April 2026
Lifecycle: Active
Notes: ChatGPT+Perplexity Research Ergebnisse konvergent: 20-Kategorien Taxonomie für food_group_normalized.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: Supabase
Verified: Yes

# Quelle

ChatGPT Deep Research + Perplexity Pro, 2026-04-12. Vollständiger PDF-Export von Perplexity angehängt.

# Konvergente Empfehlung beider Research-Systeme

**20 Kategorien Taxonomie** basierend auf WWEIA 15-Gruppen + INFOODS + FoodEx2 Top-Level. Mathematisch optimal für pgvector HNSW Pre-Filtering bei 25k Rows (~850-1700 pro Bucket). Innerhalb der empirischen Zero-Shot-LLM-Accuracy-Zone (92-98%).

# Die 20 Kategorien

1. `dairy_eggs` — Milch, Käse, Joghurt, Butter, Eier. Ausnahme: pflanzliche Alternativen, Eis
2. `meat_raw` — rohes/minimal verarbeitetes Muskelfleisch. Ausnahme: Wurst, Schinken
3. `meat_processed` — Wurst, Schinken, Speck, Pastete
4. `seafood` — alle Süß-/Salzwassertiere, roh und verarbeitet
5. `vegetables` — kulinarische Gemüse inkl. Tomaten/Paprika (nicht botanisch Früchte)
6. `fruits` — kulinarische Früchte, frisch/getrocknet. Ausnahme: Fruchtsäfte
7. `grains_pasta` — Getreide, Mehl, Teigwaren. Ausnahme: gebackenes Brot
8. `legumes_nuts_seeds` — Linsen, Bohnen, Tofu-Block, Nüsse, Samen
9. `bakery` — Brot, Brötchen (inkl. Burger-Bun!), Croissants, Tortilla
10. `mixed_dish` — ≥2 Makro-Kategorien kombiniert als Mahlzeit: Pizza, Burger, Sandwich, Lasagne
11. `soup_broth` — savory Flüssigmahlzeiten
12. `snack_savory` — Chips, Pretzels, Popcorn, Cracker
13. `sweets_desserts` — Schokolade, Kuchen, Eis, Honig, Zucker
14. `fats_oils` — extrahierte Öle. Ausnahme: Butter (→ dairy_eggs)
15. `condiments_sauces` — Ketchup, Mayo, Pesto, Pastasaucen
16. `herbs_spices` — Salz, Pfeffer, Kräuter, Vanilleextrakt
17. `beverages_nonalcoholic` — Wasser, Saft, Soda, Smoothies
18. `beverages_alcoholic` — Bier, Wein, Spirituosen
19. `plant_based_alternatives` — Sojamilch, Beyond Meat, Veggie-Käse
20. `supplements` — Proteinpulver, Vitamingummies, Meal Replacements

Fallback: `uncategorized` bei absoluter Ambiguität.

# Kritische Entscheidungsheuristiken

1. **Botanisch vs. kulinarisch:** Tomate/Paprika → vegetables (nicht fruits)
2. **Lipid-Extraktion:** Jedes extrahierte Öl → fats_oils (Olivenöl nicht fruits)
3. **Composite-Schwelle:** ≥2 Makro-Kategorien als Mahlzeit → mixed_dish. Hot Dog Wurst solo = meat_processed, Hot Dog im Brötchen = mixed_dish
4. **Käse-Paradox:** Käse/Joghurt/Butter → dairy_eggs (nicht processed_food trotz NOVA Group 3)
5. **Liquid Food:** Suppe ≠ Getränk → soup_broth. Smoothie = beverages_nonalcoholic

# Architektur-Findings (Perplexity)

- pgvector **Pre-Filter via Metadata-Bitset** ist effizienter als Post-Filter bei Category-Cardinality 15-30
- Post-Filter bei niedriger Kategorie-Auswahl (z.B. NOVA 4 Gruppen) = Zero-Result-Risk
- HNSW Graph-Masking nach Kategorie funktioniert optimal bei gleichmäßiger Bucket-Verteilung
- 25.623 Rows / 20 Kategorien = ~1.281 pro Bucket → gesund für Retrieval

# LLM-Classifier-Spec (bereit für Backfill)

- Modell: gpt-4.1-mini oder gemini-2.5-flash
- Temperature: 0
- Input: name_en (+ optional name_original als Hint)
- Output: strict JSON `{category, confidence, reasoning}`
- Kosten geschätzt: ~$1-2 für alle 25.623 Rows

# Nächste Schritte

1. Quick-Fix im Gemini-Edge-Function-Prompt: generische Begriffe rausgeben statt dish-spezifische (z.B. 'wheat roll' statt 'burger bun')
2. Zuhause Full-Fix: food_group_normalized Spalte befüllen, match_nutrition RPC um filter-Parameter erweitern
3. Nach Backfill: Borrowing-Reset + Borrowing-Pass 4 mit Kategorie-Filter für saubere Mikros