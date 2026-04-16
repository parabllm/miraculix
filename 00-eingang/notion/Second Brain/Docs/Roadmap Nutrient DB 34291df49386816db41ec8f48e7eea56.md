# Roadmap Nutrient DB

Created: 14. April 2026 15:32
Doc ID: DOC-63
Doc Type: Architecture
Gelöscht: No
Last Edited: 14. April 2026 15:32
Last Reviewed: 14. April 2026
Lifecycle: Active
Notes: Master-Plan nach kritischer Voice-Input-Einsicht 14.04.2026. Matching-System ist zentrale Infrastruktur für Backfill + Borrowing + User-Retrieval. Laufend aktualisiert.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Draft
Stack: Supabase
Verified: No

> **Stand:** 14.04.2026 — Draft nach kritischer Voice-Input-Einsicht von Deniz. Matching-System ist die zentrale Infrastruktur fuer Backfill, Borrowing und User-Retrieval gleichzeitig.
> 

## 1. Anforderungen (non-negotiable)

1. **Vollstaendigkeit:** Jede Row in `nutrition_db` hat am Ende alle 20 Naehrwerte (5 Makros + 15 Mikros), entweder gemessen, sicher geborgt, oder explizit als "unbekannt" markiert.
2. **Provenance pro Wert:** Fuer jeden Nutrient-Wert muss dokumentiert sein woher er kommt — `measured` (Original-Quelle), `borrowed_from:{source_id}` (aus anderer Row uebernommen), `imputed` (LLM-geschaetzt), `none` (keine Daten).
3. **Kategorisch sicher:** Borrowing darf nur zwischen Rows derselben `food_group_normalized` passieren, mit expliziter Unsafe-Liste fuer Edge Cases (plant-based vs animal, sugar-free vs sugar, fortified vs unfortified).

## 2. Kern-Architektur-Einsicht

Das **Matching-System ist eine einzige Infrastruktur** die fuer drei Aufgaben gleichzeitig genutzt wird:

1. **DB-internes Borrowing** — Row A borgt Mikros von Row B
2. **User-Retrieval** — Vision-Output in DB-Row
3. **OFF Lazy-Load** — neuer OFF-Eintrag in wissenschaftliche Referenz fuer Mikro-Enrichment

Konsequenz: Das Matching-System muss zuerst stehen und robust sein bevor irgendwas anderes gebaut wird. Sonst passiert der zweite DB-Reset (wie beim letzten Borrowing-Crash).

## 3. Borrowing-Hierarchie

Fuer jeden fehlenden Nutrient-Wert in einer Row wird folgende Hierarchie durchlaufen:

### Stufe 1: Cross-DB Borrowing (echte gemessene Werte)

- Suche in anderen Rows mit:
    - gleicher `food_group_normalized` (PFLICHT)
    - Similarity >= 0.85 (konservativ)
    - Wert vorhanden
    - Kategorie in Safe-List (siehe Abschnitt 4)
- Provenance: `{method: "borrowed", source: "USDA_SR/12345", similarity: 0.91}`

### Stufe 2: Median-Borrowing (mehrere Nachbarn)

- Mehrere Rows mit dem Wert, Varianz < 20%
- Provenance: `{method: "borrowed_median", sources: [...], n: 4}`

### Stufe 3: LLM-Imputation (Fallback, tbd)

- Nur wenn keine Nachbarn verfuegbar
- Modell: gpt-4.1-mini, strict JSON output
- Provenance: `{method: "llm_imputed", model: "gpt-4.1-mini", confidence: "low"}`
- UI warnt: "geschaetzt"

### Stufe 4: NULL

- Wenn alle Stufen scheitern oder LLM keine sichere Antwort gibt
- Provenance: `{method: "none"}`
- UI: "keine Daten verfuegbar"

> **Offene Entscheidung:** LLM-Imputation aufnehmen oder nicht? Strenge Wissenschaftlichkeit vs Coverage. Zu klaeren mit Deniz.
> 

## 4. Category-Safe-Listen

### Safe fuer Borrowing (Mikros aehnlicher Rows sind zuverlaessig)

- grains_pasta, bakery, vegetables, fruits, legumes_nuts_seeds
- meat_raw, seafood, dairy_eggs (nicht-fortified)
- fats_oils, herbs_spices

### Unsafe (NIE borrowen, auch bei hoher Similarity)

- plant_based_alternatives (Fortifizierung variiert extrem)
- supplements (Dosierungen variieren)
- beverages_alcoholic (bimodal in Naehrwerten)
- sweets_desserts (Zucker-/Fett-Gehalt variiert)
- packaged-Produkte mit "sugar-free", "low-fat", "fortified" Hinweisen

Policy bei unsafe Kategorien: Wert bleibt NULL, UI zeigt "unbekannt".

## 5. Phasen-Plan

### Phase 0: Dokumentation

Dieses Doc als Master-Plan, laufend aktualisiert bei Phasen-Abschluessen.

### Phase 1: Matching-System

Grundinfrastruktur fuer alles andere.

**1a. `food_group_normalized` Backfill** (23.305 Rows)

- LLM-Klassifikation (gpt-4.1-mini), strict JSON
- Heuristiken aus DOC-60
- Confidence-Score pro Row
- Low-Conf Rows fuer manuellen Review markieren

**1b. `match_nutrition` RPC erweitern**

- Optional: `food_group_filter`, `preferred_sources`, `similarity_threshold`
- Rueckwaertskompatibel (Edge Function darf nicht brechen)

**1c. Matching-Qualitaets-Test (DB-intern)**

- 20-30 bekannte Paare die matchen muessen (BLS Avocado vs USDA_SR Avocado)
- 20-30 Paare die NICHT matchen duerfen (Avocado raw vs Avocado oil)
- Messbar: Precision/Recall fuer "gleich genug zum Borrowen"

### Phase 2: Vision-Prompt V2

Parallelisierbar zu Phase 1. Gibt `food_group_normalized` + `entity_type` pro Ingredient aus.

- XML-structured system prompt + JSON schema
- Few-shot examples fuer Dish-Decomposition
- temperature=0, thinkingBudget=0 (empirisch aus DOC-62)

### Phase 3: Cross-DB Borrowing

Nutzt Matching-Infrastruktur aus Phase 1. Lokales Node-Script mit Dry-Run-Option.

- 3a. Borrowing-Policy-Matrix finalisieren (Safe/Unsafe per Kategorie)
- 3b. Borrowing-Script mit Hierarchie (Stufe 1-4)
- 3c. Dry-Run Audit: wie viele Werte wuerden geborgt, wie viele NULL bleiben
- 3d. Commit + Provenance-Tags setzen
- 3e. Spot-Check: 50 Rows manuell gegen Original-Quelle

### Phase 4: User-Retrieval (Vision in DB Match)

Nutzt dieselbe Matching-Infrastruktur.

- 4a. Benchmark-Suite (50-100 Query/Expected-Paare, stratifiziert)
- 4b. Baseline gegen neue Infrastruktur messen
- 4c. Falls Luecken: BM25-Hybrid, Plausibility-Filter als Add-ons (Entscheidung datengetrieben)

### Phase 5: OFF Lazy-Load

Barcode-Flow. Nutzt Matching + Borrowing-Policy aus Phase 1+3.

- 5a. Barcode-Scan: Makros direkt aus OFF (sofort fuer User)
- 5b. Mikros via Borrowing-Policy (gleicher Mechanismus wie Phase 3)
- 5c. Latenz-Design: Makros sync zurueck an Client, Mikros ggf. Background-Job
- 5d. Provenance klar markiert, UI zeigt "Mikros geschaetzt aus X"

## 6. Offene Entscheidungen

- **LLM-Imputation als Stufe 3 aufnehmen?** (Deniz tbd)
- **Similarity-Threshold:** 0.85 konservativ oder differenziert pro Kategorie?
- **Provenance-Granularitaet:** pro Wert (20 Eintraege) oder gruppiert (Makros/Mikros)?
- **Backfill-Modell:** gpt-4.1-mini (~$2) oder gemini-2.5-flash-lite (~$0.50)?
- **Re-Embedding nach Kategorie-Backfill?** Research empfiehlt es, Kosten ~$3.

## 7. Rollback-Pfade

Pro Phase ein expliziter Rollback:

- **Phase 1a Backfill:** Spalte `food_group_normalized` leeren per UPDATE, keine Migration noetig
- **Phase 1b RPC:** Alte Signatur per `CREATE OR REPLACE` wiederherstellen
- **Phase 3 Borrowing:** `provenance.borrowed=true` Werte per SQL-Query zuruecksetzen auf NULL
- **Phase 2 Vision-Prompt:** Edge Function v13 als Backup deployt lassen, Rollback per Re-Deploy

## 8. Verwandte Docs

- DOC-62 Master Architecture v8 — Frontend-Contract, unumstoesslich
- DOC-60 Taxonomy Research — 20-Kategorien-Taxonomie + Heuristiken
- DOC-57 Food Scanner Deep Research — Retrieval-Pattern-Bibliothek
- DOC-50 Food Scanner Skill — Verdichtetes Wissen