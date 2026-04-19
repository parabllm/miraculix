---
typ: aufgabe
name: "Borrow Script v2"
projekt: "[[food-scanner]]"
status: erledigt
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: []
quelle: direkte_erfassung
vertrauen: extrahiert
erstellt: 2026-04-19
---

Dokumentation des finalen Borrow-Scripts für Etappe 3. Lokales Node.js-Skript, kein Edge Function. Lauf-Ort: `C:\Users\deniz\Downloads\Backfill Mikros\`. Für Repo vorgesehen unter `corelate-v3/scripts/borrow-nutrients/`.

## Zweck

Fills die Mikronährstoff-Lücken in `nutrition_db` durch kategorisch sichere Median-Borrowing aus semantisch nahen Rows derselben `food_group_normalized`. Ersetzt NULL nicht durch LLM-Imputation (bewusst verworfen), sondern durch echte gemessene Werte aus anderen Datensätzen.

## Files

| File | Zeilen | Zweck |
|---|---:|---|
| `borrow-nutrients-v2.mjs` | ~1000 | Hauptskript mit Retry-Logic |
| `borrowing-config.mjs` | ~150 | Safe/Unsafe-Listen, Modifier-Rules, Defaults |
| `llm-judge.mjs` | ~180 | OpenAI-Wrapper für Fit-Prüfung |
| `setup-snapshot.sql` | ~40 | Einmaliges Setup der Backup-Tabelle |
| `package.json` | ~20 | Dependencies |
| `README.md` | ~100 | Workflow-Anleitung |

Dependencies: `@supabase/supabase-js`, `dotenv`, `openai`.

## Algorithmus pro Ziel-Row

1. Hole Target mit NULL-Wert in einem Nutrient
2. Call `match_nutrition_filtered` RPC mit Embedding + food_group-Filter + nutrient_not_null-Filter. Top 200 Kandidaten
3. Filter clientseitig: Similarity ≥ Schwelle, nicht self-match, Modifier-Rules anwenden
4. Wenn unter min-neighbors: skip mit `too_few_neighbors`
5. CV der Kandidatenwerte berechnen
6. Wenn CV über Threshold: skip mit `cv_too_high`
7. Wenn LLM-Judge aktiv und Trigger-Bedingung erfüllt: frage LLM um Fit-Prüfung
8. LLM-Ergebnis auswerten: bei `reject` skip, bei `accept_subset` CV neu berechnen und nochmal threshold-checken
9. Median der akzeptierten Werte bilden
10. UPDATE mit neuem Wert + Provenance-Eintrag `method: "borrowed_from"`, source_ids, n, similarity, cv

## LLM-Judge-Trigger

LLM wird nur bei schwierigen Fällen eingeschaltet. Eine der drei Bedingungen reicht:

- `avgSimilarity < llmTriggerSimBelow` (default 0.85): Kandidaten semantisch weit
- `cv > llmTriggerCvAbove` (default 0.20): Werte streuen stark
- `nNeighbors <= llmTriggerMinNeighbors` (default 2): wenig Redundanz

## Modifier-Rules

Sechs Regex-Patterns, werden auf `name_en` angewendet. Jede Regel blockt bestimmte Nutrients:

- `salt-modifier`: blockt `na_mg`. Matches "no added salt", "unsalted", "low sodium", deutsche Varianten
- `sugar-modifier`: blockt `choavl_g`, `enerc_kcal`. Matches "sugar-free", "unsweetened"
- `fat-modifier`: blockt `fat_g`, `enerc_kcal`, `vita_rae_ug`, `vitd_ug`, `vite_mg`. Matches "low-fat", "skim"
- `fortified`: blockt alle 15 Mikros. Matches "fortified", "enriched", "angereichert"
- `light-diet`: blockt `fat_g`, `choavl_g`, `enerc_kcal`. Exclusion für "light meat" und "tuna, light"

Zwei-fach Schutz: Ziel-Row wird nicht befüllt wenn Modifier den Nutrient blockt. Kandidaten-Row wird nicht als Quelle genutzt wenn deren Modifier den Nutrient blockt.

## Parameter-Defaults

| Flag | Default | Begründung |
|---|---|---|
| `--similarity` | 0.73 | 0.85 war zu konservativ in Tests, 0.73 liefert gute Rate ohne zu viel Junk |
| `--cv` | 0.40 | Strenger bei Mikros mit bimodalen Verteilungen nicht sinnvoll |
| `--min-neighbors` | 2 | Ein einzelner Neighbor kann Ausreißer sein |
| `--max-candidates` | 200 | Top 200 aus RPC holen, dann filtern |
| `--parallel-batch-size` | 10 | 10 Ziel-Rows parallel |

Produktiv werden diese beim Live-Run via CLI überschrieben:
- Similarity 0.65
- CV 0.40
- min-neighbors 2
- LLM-Judge aktiv mit sim-below 0.85 und cv-above 0.20

## Retry-Logic

Drei Stellen mit exponential backoff (3 Versuche):

- Snapshot-Check beim Start (unterscheidet 42P01 Table-Not-Exists vs Timeout)
- Target-Fetch pro Category × Nutrient-Combo
- RPC-Calls für Matching

Combo-Level Try/Catch verhindert Crash eines ganzen Runs durch einzelnen Combo-Fehler.

## Skip-Reasons

Werden im JSON-Output pro Ziel-Row dokumentiert:

- `too_few_neighbors` (n unter min-neighbors)
- `cv_too_high` (CV über Threshold)
- `modifier_blocks_nutrient` (Target selbst hat Modifier für diesen Nutrient)
- `llm_reject` (LLM sagt nicht borrowbar)
- `llm_subset_too_small` (nach LLM-Filter unter min-neighbors)
- `cv_too_high_after_llm` (nach LLM-Subset neu berechnetes CV über Threshold) — Bug-Fix 2026-04-19

## Output

### JSON-Datei

`run-YYYY-MM-DD-HH-MM-SS-simX.XX-cvX.X-limitN.json` mit allen verarbeiteten Targets. Pro Entry:

```json
{
  "target_id": 12345,
  "target_name": "Wheat roll",
  "category": "bakery",
  "nutrient": "foldfe_ug",
  "borrowed": true,
  "new_value": 49.5,
  "n_neighbors": 4,
  "avg_similarity": 0.6929,
  "cv": 0.3909,
  "neighbor_sources": ["COFID/11-984", "NEVO/2798", ...],
  "llm_judge": { "decision": "accept_subset", "reason": "..." }
}
```

### Report-TXT

Human-readable Übersicht. Pro Combo-Gruppe (category × nutrient) werden alle Borrows gelistet mit Target, Median, Range, CV, Top-Kandidaten und LLM-Entscheidung.

## Snapshot-Tabelle

`nutrition_db_borrowing_backup` enthält vor jedem Live-Run alle 20 Nutrient-Spalten + provenance aller 23.305 Rows. Restore-Query:

```sql
UPDATE nutrition_db n
SET enerc_kcal = b.enerc_kcal, procnt_g = b.procnt_g, ...,
    provenance = b.provenance
FROM nutrition_db_borrowing_backup b
WHERE n.id = b.id;
```

Per CLI: `node borrow-nutrients-v2.mjs --mode=rollback --confirm=yes`.

## Kosten

- Supabase: im Pro-Plan enthalten, kein Extra-Call-Cost
- OpenAI LLM-Judge: ca 0.01 cent pro Call, 5-7 Dollar pro Full-Run

## Laufzeit

Erwartet 2-3 Stunden für alle 17 Safe-Kategorien × 16 Nutrients mit NULL-Lücken. Idempotent: Restart nach Crash überspringt schon gefüllte Rows automatisch (weil NOT NULL).

## Architektur-Entscheidungen

### Kein Edge Function

Batch-Job mit langer Laufzeit passt nicht ins Edge-Function-Modell (Deno-Runtime, Timeouts, kein lokales Filesystem für Output-Dateien). Node.js lokal mit direktem Supabase-Client.

### Aggregation in Code, nicht AI

Der LLM entscheidet nur über Fit der Kandidaten, nicht über den Nutrient-Wert. Median wird in JavaScript aus den akzeptierten Werten berechnet. LLM-Imputation von numerischen Werten wurde 2026-04-14 verworfen und mit diesem System bestätigt.

### In-Memory LLM-Cache

Ein `Map<string, judgeResult>` verhindert Doppel-Queries für identische Target+Candidate-Sets innerhalb eines Runs. Kein persistenter Cache zwischen Runs (weil Runs eh selten laufen).

## Bekannte Limitations

- CV-Threshold 0.40 ist für bimodale Verteilungen nicht ideal. Ein Vitamin A in Fleisch kann 0 oder 100 sein, selten dazwischen. Aktuell wird das als "zu hohe Varianz" geskippt.
- Kein State-Awareness. Apfel und Apfelkompott können im selben Borrow-Pool landen. Etappe 4 wird das mit state-tags fixen.
- USDA_FND Rows mit Null-Mikros können als Kandidaten durchrutschen. In Etappe 3 Live-Run zu beobachten.

## Repo-Commit ausstehend

Files sind noch nicht im Git. Ziel-Pfad `corelate-v3/scripts/borrow-nutrients/`. Pattern gleich wie food-group-backfill Skript.
