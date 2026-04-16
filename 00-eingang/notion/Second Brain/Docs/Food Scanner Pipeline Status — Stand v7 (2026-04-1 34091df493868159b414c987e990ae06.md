# Food Scanner Pipeline Status — Stand v7 (2026-04-12)

Created: 12. April 2026 17:38
Doc ID: DOC-55
Doc Type: Architecture
Gelöscht: Yes
Last Edited: 12. April 2026 17:41
Last Reviewed: 12. April 2026
Lifecycle: Deprecated
Notes: Konsolidierter Stand nach Latenz- und Qualitäts-Optimierungen v1-v7. Ersetzt inhaltlich Post-Jann-Adjustments-Doc.
Related Logs: Food Scanner v1→v7 — Edge Function produktiv, Latenz 10s, Kosten unter Target (../Logs/Food%20Scanner%20v1%E2%86%92v7%20%E2%80%94%20Edge%20Function%20produktiv,%20Late%2034091df493868134be65d3f7723fb268.md)
Stability: Stable
Verified: Yes

# Status

Edge Function `food-scanner` läuft als **v7** auf Supabase Projekt `vviutyisqtimicpfqbmi`. End-to-End-Pipeline funktioniert, Latenz stabil bei **~10s pro Bild-Scan**, Kosten **$0.004–0.006 pro Scan**.

# Was in v7 drin ist

- **GPT-4o Vision** mit strict JSON schema + logprobs, detail=high
- **Prio-Teller-Fokus** im System-Prompt: ignoriert Nebenteller, Getränke, Hintergrund
- **Inferred Ingredients** mit visibility-Marker (`visible` vs `inferred`): Olivenöl, Dressings, Cooking-Oils für Fertiggerichte werden inferiert statt ignoriert — behebt systematischen Kalorien-Underreporting-Bug
- **Client-side Downsize auf 800px** vor Upload → 97 Prozent Upload-Reduktion, 40 Prozent weniger Vision-Latenz, 53 Prozent weniger Input-Tokens
- **Batch-Embedding** (1 Call für alle Zutaten statt N parallele)
- **Parallele pgvector RPCs** via `match_nutrition`. Multi-Match-RPC wurde getestet und wieder rückgängig gemacht — marginaler Unterschied, einfacherer Code gewinnt
- **Hybrid-Modus** bei Quality-Gate-Fail: Vision-Zutaten bleiben, Bognár-Retention-Faktoren drauf, Konfidenz runter. Kein blinder Tier-3-Synthesis mehr
- **Grams-Korrektur x0.9** (grams_raw + grams in Response)
- **SHA256-Cache** in food_scan_cache
- **Token-Usage + Kosten** im Response
- **Recalculate-Endpoint** für Pure-SQL-Arithmetik bei User-Gramm-Edits

# Benchmark Stand v7

| Bild | Edge | Vision | Embed | RPC | Zutaten | Kosten |
| --- | --- | --- | --- | --- | --- | --- |
| Salat mit inferred | 11.3s | 5.7s | 0.3s | 3.9s | 8 (6V+2I) | $0.006 |
| Lachs | 8.8s | 4.6s | 0.3s | 2.9s | 3V | $0.004 |
| Tajine | 8.8s | 4.1s | 0.2s | 3.4s | 4V | $0.005 |
| Shakshuka (full-size) | 14.4s | 6.4s | 0.3s | 5.4s | 5 | $0.004 |

# Offene Baustellen

1. **Latenz-Bottleneck:** 10s sind zu viel. Vision 5s + RPC 3s sind die Hauptblöcke. Embeddings sind nur 0.3s (kein Problem mehr dank Batch)
2. **Granularität:** Vision clustert kleine Items (Maiskörner, Sesam) in Bucket-Kategorien. Sweet Corn wurde im Salat-Testlauf nicht als eigene Zutat erkannt
3. **Inferred-Grams sind grob:** Olivenöl 9g ist konservativ aber zu ungenau — könnte per Dish-Typ feiner sein
4. **OFF-Record 00004800 Bratwurst:** Einheiten-Bug (360g Natrium statt 360mg) — Import-Pipeline prüfen
5. **B6 in vielen nutrition_db Records NULL** — Cross-DB-Borrowing-Script läuft parallel

# Nächste Optimierungs-Schritte — 3 Research-Prompts

## Research 1: Vision-Modell-Alternativen mit Latenz unter 3s

Vergleich GPT-4o vs gpt-4o-mini vs Gemini 2.5 Flash Vision vs Claude 3.5 Sonnet Vision vs spezialisierte Food-APIs (LogMeal, Nutritionix, Foodvisor). Fokus auf Strict-JSON-Support, Logprobs, EU-Data-Residency (GDPR), Kosten, reale Benchmarks aus 2025-2026.

## Research 2: pgvector HNSW Latenz-Tuning auf Supabase

HNSW Parameter-Tuning bei 25k Rows, IVFFlat vs HNSW Trade-offs, Supavisor Connection-Pooling, Embedding-Dimension-Reduktion (1536 → 512 via text-embedding-3-small dimensions Parameter), Migration-Break-Even zu Qdrant/Turbopuffer. Ziel: unter 800ms RPC-Gesamtzeit.

## Research 3: Architektur-Alternativen um Vision-Embed-Match-Kette zu verkürzen

Ingredient-to-ID direkt aus Vision via Function-Calling, pg_trgm-Hybrid-Search, Caching häufiger Ingredients, Batch Vision+Match in einem LLM-Call, Speculative Execution basierend auf Location/Time. Ziel: unter 5s Gesamtlatenz OHNE Vision-Modell-Wechsel.

# Deployment

- Edge Function ID: `f5e69450-fde1-446a-bff2-42927135fda1`
- Aktuelle Version: 7
- HTML-Test-Tool v4: Single-File mit Canvas-Downsize, Toggle detail high/low, Metrics-Panel
- PDF-Briefing v3 für Jann + Lars: Benchmark Full-Size vs 800px, Expo-Integration-Snippet, Referenz-Scan mit allen 20 Nutrients

# Cost-Realität

Bei 100 Scans pro User pro Monat: **$0.40–0.60 pro User**. Coralate-Target <$1/User/Monat: erfüllt mit Puffer. Skaliert linear mit Nutzeraktivität.

# Was wurde rückgängig gemacht

- **Multi-Match-RPC** (v6) wieder entfernt: brachte nur ~500ms Einsparung bei deutlich komplexerem SQL. Parallele Single-RPCs sind transparenter und gleich schnell
- **Tier-3-Synthesis** komplett raus: wurde durch Hybrid-Modus im Tier-1-Pfad ersetzt, kein separater Code-Pfad mehr
- **Aggressive Generic-Defaults** (Pork Chop, Beef Steak): Prompt zwingt jetzt spezifische Protein-Identifikation