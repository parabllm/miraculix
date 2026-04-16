# Runde 2 Research abgeschlossen — Architektur-Entscheidungen getroffen, 5-Etappen-Plan steht

Areas: coralate
Confidence: User-stated
Created: 14. April 2026 17:21
Date: 14. April 2026
Gelöscht: No
Log ID: LG-18
Source: Claude session
Summary: Runde 2 Research abgeschlossen. Klare Entscheidungen: NutriMatch verworfen (totes Repo, Latenz), OFF 2026 Smart-Aggregation-Schema als Vorbild uebernommen, LLM-Imputation fuer Werte bleibt raus, Cronometer Better-Alternative-Backfill + CV<30% als Regel-Set. Coverage-Erwartung 88-92% nach Borrowing, Rest NULL (bestaetigt okay). 5-Etappen-Plan definiert, ~14h Build.
Tools: Supabase
Type: Decision

## Runde 2 Research durch

Zwei Research-Reports von Gemini Deep Research und Perplexity Pro zu NutriMatch, NCCDB-Imputation und produktiven Borrowing-Policies ausgewertet. Beide Streams konvergieren stark auf klare Entscheidungen.

## Kern-Entscheidungen

### NutriMatch verworfen

Paper ist beeindruckend, aber GitHub-Repo ist nach Publikation tot (2 Commits, 0 Issues, 0 PRs, 1 Fork). Nicht wartungsfaehig, nicht modularisiert, Latenz- und Kosten-Profil fuer Echtzeit-Einsatz prohibitiv. Zusaetzlich: die Autoren selbst warnen vor Detection-Limit-Bias bei semantischem Matching zwischen Databases mit unterschiedlichen Analyse-Thresholds.

### OFF 2026 Smart-Aggregation-Schema als Vorbild

Open Food Facts hat im Maerz 2026 ihre DB-Architektur umgebaut. Das Muster:

- Silos pro Datenquelle (Manufacturer, Packaging, External-DB, Estimation)
- Provenance-Tag pro einzelnem Nutrient in API-Response
- Hierarchische Aggregation Manufacturer > Packaging > External > Estimation
- Client entscheidet ob estimated Werte akzeptiert werden, sonst NULL
- Entspricht fast exakt dem was wir im Roadmap-Doc skizziert haben
- Open Source Referenz: openfoodfacts-server + robotoff

### LLM-Imputation fuer Nutrient-Werte: NEIN

Beide Research-Runden konvergent. Dokumentierte Failure-Modes: Regression-to-Mean, halluzinierte Mikronaehrstoff-Werte, biologisch unmoegliche Kombinationen. Deshalb: LLMs nur fuer Klassifikation (food_group_normalized), nicht fuer numerische Werte.

### Cronometer Better Alternative Backfill als Regel-Set

Cronometer borgt nur fuer simple single-ingredient oder near-single-ingredient items. Multi-ingredient processed foods werden NICHT automatisch backfilled. Das ist die pragmatische Policy fuer unseren OFF Lazy-Load.

### CV > 30% als harte Borrowing-Grenze

Empirisch belegt durch 2024 JMIR-Studie: MyFitnessPal CV 96-112% fuer Saturated Fat und Cholesterol fuehrt zu klinisch relevanten Fehlern. CV-Messung pro Kategorie-Nutrient aus eigener DB muss Teil des Borrowing-Scripts sein.

## Coverage-Erwartung

Start: ~75% Mikro-Coverage aktuell in nutrition_db.

Nach Etappe 3 (sicheres Cross-DB Borrowing): erwartet 88-92%. Rest bleibt NULL.

Verbleibende NULLs konzentriert in:

- Spurenelemente (Jod, Selen, Chrom, Molybdaen) - in vielen DBs gar nicht gemessen
- Unsafe-Kategorien per Policy (supplements, plant-based alts, fortified cereals, sugar-free)
- Regional-spezifische CIQUAL-Rows ohne Gegenstueck

Deniz explizit okay mit NULL-Approach. Transparente NULLs > fabrizierte Werte.

## 5-Etappen-Plan (gekuerzt vs urspruenglicher 7-Phasen)

1. **Food-Group-Backfill** - alle 23.305 Rows LLM-klassifizieren (~1h, ~$2)
2. **Provenance-Schema** - jeder Nutrient-Wert bekommt source-Tag (~2h)
3. **Cross-DB Borrowing** - Dry-Run, Audit, Commit mit Category + CV + Simple-Item Regeln (~4h)
4. **Vision-Prompt V2 + RPC-Erweiterung** - XML-structured, Kategorie-Output (~3h)
5. **OFF Lazy-Load** - Barcode-Flow mit Borrowing-Policy (~4h)

Gesamt ~14h Build + ~$5 LLM-Kosten.

## Naechste Schritte

- Roadmap-Doc in Docs DB aktualisieren auf diesen Stand (NutriMatch-Entscheidung, OFF-Schema-Referenz, 5-Etappen-Plan)
- Dann Etappe 1 starten oder Pause

## Action

- Log festgehalten
- Research-Phase abgeschlossen, keine Runde 3 geplant
- Warten auf Deniz-Go fuer Roadmap-Doc-Update und Etappe 1

---

*Note: Project-Relation zu coralate muss manuell gesetzt werden (API-Validation-Fehler mit URL-Format).*