---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-19
art: meilenstein
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["supabase", "openai", "node", "gemini"]
---

Zwei Arbeitsblöcke an einem Tag. Etappe 3 Cross-DB Borrowing ist fertig entwickelt und validiert, Live-Run wurde gestartet. Parallel die erste strukturierte Analyse des produktiven Vision-Prompts in Edge Function `food-scanner` v15 durch echten Scan-Output aus `food_scan_log`.

## Block 1: Etappe 3 Borrowing final

### Entscheidungen gegenüber Roadmap-Entwurf

Die Roadmap sah Similarity-Schwelle 0.85 und CV 0.30 vor. Nach mehreren Dry-Runs auf 2000 Zielrows sind die produktiven Schwellen aggressiver:

- Similarity 0.65 (vorher 0.68 getestet, 0.85 war zu konservativ)
- CV 0.40
- min-neighbors 2
- LLM-Judge aktiv mit Triggern bei sim unter 0.85 oder CV über 0.20

Begründung: Bei 0.85 Similarity fallen zu viele legitime Borrows weg. Der LLM-Judge kompensiert die niedrigere Schwelle durch aktive Fit-Prüfung bei schwierigen Fällen.

### Modifier-Rules System

Sechs Regeln blocken Nutrients nach Modifikator im Namen:

- `salt-modifier` (no added salt, low sodium): blockt `na_mg`
- `sugar-modifier` (sugar-free, unsweetened): blockt `choavl_g`, `enerc_kcal`
- `fat-modifier` (low-fat, skim): blockt `fat_g`, `enerc_kcal`, Vitamin A/D/E
- `fortified` (enriched, vitaminized): blockt ALLE 15 Mikros
- `light-diet` (light, diet): blockt `fat_g`, `choavl_g`, `enerc_kcal`
- Exclusions für "light meat" und "tuna light" (nicht als Modifier zählen)

DB-Counts: salt-mod 645, sugar-mod 334, fat-mod 496, fortified 413.

### LLM-Judge Integration

gpt-4.1-mini als Fit-Judge, nicht als Werte-Schätzer. Drei mögliche Entscheidungen:

- `accept_all`: alle Kandidaten biologisch vergleichbar
- `reject`: Borrowing nicht möglich
- `accept_subset`: Teilmenge akzeptieren mit IDs

In-Memory Cache verhindert Doppel-Queries für identische Target+Candidate-Sets. Kosten pro Full-Run ca 5 bis 7 Dollar.

### Bug-Fix nach Dry-Run 2000

Im Dry-Run gefunden: Camembert hatte `fe_mg` Borrow mit CV 0.45 trotz CV-Threshold 0.40. Ursache: CV wurde vor LLM-Judge berechnet, bei `accept_subset` Entscheidung ändert sich die Kandidatenmenge und damit CV, aber kein Recheck danach. Gefixt, neue skip_reason `cv_too_high_after_llm`.

### Live-Run Status

Gestartet 2026-04-19 abends mit:

```
node borrow-nutrients-v2.mjs --mode=live --similarity=0.65 --cv=0.40 --min-neighbors=2 --llm-judge --llm-sim-below=0.85 --llm-cv-above=0.20
```

Erwartete Laufzeit 2-3h. Erwartete neue Borrows 11.000 bis 15.000. Erwartete Coverage-Steigerung von 84% auf 86-88% über alle 20 Nutrients.

## Block 2: Vision-Prompt Analyse auf echten Scans

Aus `food_scan_log` 5 erfolgreiche Scans analysiert (5 weitere gefailt mit Gemini 403, nicht Prompt-relevant).

### Produktive Prompt-Version

Edge Function `food-scanner` v15 in Datei `prompts.ts`. Kein Notion-Versions-Sync: der Log hier im Vault dokumentiert bis v5, aber der aktive Prompt ist kompakter als v5 (Prinzipien-Block entfernt, nur noch NAMING/INFERRED/OUTPUT Blöcke, ca 80 Tokens). Dokumentations-Lücke zwischen Vault und Production festgestellt.

### Bugs mit Faktor-Impact auf Nutrient-Werte

**chicken egg matched chicken egg white, raw**. Spätzle-Scan. sim 0.70. Eiweiß hat 42 kcal/100g, ganzes Ei 150 kcal/100g. Faktor 3.5x Unterschätzung für Kalorien, komplett falsches Protein-Profil. Prompt sagt "chicken egg" was ambig ist.

**garlic matched USDA_FND Eintrag mit Null-Mikros**. sim 0.813, aber der DB-Row hat `k_mg=0, ca_mg=0, fe_mg=0, mg_mg=0, na_mg=0`. Dieser Datensatz ist DB-seitig unvollständig, trotzdem Top-Match weil sim-Score am höchsten. Das ist kein Prompt-Bug sondern Match-RPC-Bug: die RPC sollte Rows mit überwiegend Null-Mikros aus Top-Matches filtern.

**water und granulated sugar bekommen 0 matches bei iced coffee**. 10g Zucker sollten 40 kcal beitragen, sind komplett verloren. iced coffee zeigt 4 kcal statt ~45. Kein Fallback implementiert wenn match_nutrition leer returned.

**wheat flour matched whole-grain statt white bei Spätzle**. Vollkorn hat 20-30% abweichende Nutrient-Werte. Prompt sagt nur "wheat flour" ohne Spezifität.

**banana 300g statt 120g geschätzt**. 276 kcal für eine Banane. Prompt gibt keine Referenzgrößen für häufige Items.

### Weniger kritische Befunde

- Similarity-Scores generell niedrig (0.6 bis 0.73), deutet auf suboptimale Embedding-Strategie. Gemini-Output-Namen matchen die DB-Konventionen nicht gut
- Preparation wird inkonsistent für Embedding genutzt: bei visible Ingredients reinkonkateniert, bei inferred weggelassen
- Avocado Toast sim 0.70 liefert "Avocado" statt "Avocado, raw" Varianten

## Nutrition-DB Coverage-Stand vor Live-Run

Gesamtcoverage 84% über 20 Nutrients × 23.305 Rows = 466.100 Zellen. Davon 391.683 gefüllt.

Top 3 Lücken: Vitamin A 47.3%, Folate 50.5%, Vitamin B6 50.8%.

## Files erstellt heute

Im Backfill-Ordner `C:\Users\deniz\Downloads\Backfill Mikros\`:

- `borrow-nutrients-v2.mjs` finale Version mit Retry-Logic und CV-Recheck-Fix
- `borrowing-config.mjs` Safe/Unsafe, Modifier-Rules, LLM-Trigger
- `llm-judge.mjs` OpenAI-Wrapper mit In-Memory-Cache
- `setup-snapshot.sql` Backup-Tabelle, einmal ausgeführt
- `README.md` Workflow-Dokumentation
- 2 Dry-Run Reports mit 238 detailliert annotierten Borrows

## Folgearbeiten

- Live-Run abwarten und Coverage-Verifikation via SQL
- Notion Prompt-Log mit v6-Analyse aktualisieren
- Vision-Prompt v2 auf Basis der 5 konkreten Bugs entwerfen
- Architektur-Doc v8 um Deprecation-Hinweis für `food-scanner-gemini` ergänzen
- Script-Files ins Repo `corelate-v3/scripts/borrow-nutrients/` committen

## Repo-Commit ausstehend

Etappe 1 und Etappe 3 Scripts sind noch nicht im Git. Lokal in `C:\Users\deniz\Downloads\Backfill Mikros\`. Commit-Task für Jann oder später selbst.
