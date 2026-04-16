---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-14
art: entscheidung
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["supabase"]
---

Runde-2-Research (Gemini Deep Research + Perplexity Pro) zu NutriMatch, NCCDB-Imputation, produktiven Borrowing-Policies ausgewertet. Beide Streams konvergieren stark.

## Kern-Entscheidungen

### NutriMatch verworfen

Paper beeindruckend, aber GitHub-Repo nach Publikation tot (2 Commits, 0 Issues, 0 PRs). Nicht wartungsfähig, Latenz-/Kosten-Profil prohibitiv für Echtzeit. Autoren selbst warnen vor Detection-Limit-Bias bei semantischem Matching zwischen DBs mit unterschiedlichen Analyse-Thresholds.

### OFF 2026 Smart-Aggregation-Schema als Vorbild

OFF hat im März 2026 DB-Architektur umgebaut:
- Silos pro Datenquelle (Manufacturer, Packaging, External-DB, Estimation)
- Provenance-Tag pro einzelnem Nutrient in API-Response
- Hierarchische Aggregation: Manufacturer > Packaging > External > Estimation
- Client entscheidet ob estimated akzeptiert wird, sonst NULL
- Entspricht fast exakt unserem Roadmap-Skizze

Referenz: `openfoodfacts-server` + `robotoff`.

### LLM-Imputation für Nutrient-Werte: NEIN

Beide Research-Runden konvergent. Failure-Modes: Regression-to-Mean, halluzinierte Mikronährstoff-Werte, biologisch unmögliche Kombinationen. → **LLMs nur für Klassifikation (`food_group_normalized`), nicht für numerische Werte.**

### Cronometer Better-Alternative-Backfill als Regel-Set

Cronometer borgt nur für simple Single-Ingredient-Items. Multi-Ingredient-Processed-Foods werden NICHT automatisch backfilled. Pragmatische Policy für OFF Lazy-Load.

### CV > 30% als harte Borrowing-Grenze

JMIR-2024-Studie: MyFitnessPal CV 96-112% für Saturated Fat und Cholesterol → klinisch relevante Fehler. CV-Messung pro Kategorie-Nutrient aus eigener DB muss Teil des Borrowing-Scripts sein.

## Coverage-Erwartung

Start: ~75% Mikro-Coverage in `nutrition_db`. Nach Etappe 3 (sicheres Cross-DB Borrowing): erwartet **88-92%**. Rest bleibt NULL (Spurenelemente Jod/Selen/Chrom/Molybdän, Unsafe-Kategorien per Policy, Regional-spezifische CIQUAL-Rows). Deniz explizit OK: **Transparente NULLs > fabrizierte Werte.**

## 5-Etappen-Plan

1. **Food-Group-Backfill** - alle 23.305 Rows LLM-klassifizieren (~1h, ~$2)
2. **Provenance-Schema** - jeder Nutrient-Wert bekommt Source-Tag (~2h)
3. **Cross-DB Borrowing** - Dry-Run, Audit, Commit mit Category + CV + Simple-Item Regeln (~4h)
4. **Vision-Prompt V2 + RPC-Erweiterung** - XML-structured, Kategorie-Output (~3h)
5. **OFF Lazy-Load** - Barcode-Flow mit Borrowing-Policy (~4h)

**Gesamt:** ~14h Build + ~$5 LLM-Kosten.

## Nächste Schritte

- Roadmap-Doc aktualisieren (NutriMatch-Entscheidung, OFF-Schema-Referenz, 5-Etappen-Plan)
- Dann Etappe 1 oder Pause
