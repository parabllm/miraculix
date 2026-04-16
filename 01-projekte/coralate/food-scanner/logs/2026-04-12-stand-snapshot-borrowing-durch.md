---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-12
art: fortschritt
vertrauen: bestaetigt
quelle: chat_session
werkzeuge: ["supabase", "pgvector"]
---

Stand vor Kategorie-Fix gesichert. DB: **25.623 Foods** mit OpenAI-Embeddings (1536-dim). Borrowing 3 Passes durch.

## Coverage nach Borrowing

- Mineralien: 100% (außer OFF 85%)
- Vitamine: 98-100% (außer OFF 82%)
- `food_scan_cache` Schema erweitert (Migration 002)
- Edge Function noch nicht gebaut

## Kritisches Problem: Matching-Accuracy

Semantic Retrieval matched systematisch falsche Kategorien:

- `'burger bun'` → matched `'Hamburger'` (ganzes Gericht statt Brötchen)
- `'sauce'` → matched `'Sriracha'` (zu spezifisch)
- `'potato fried'` → matched `'Rösti'` (falsches Gericht)

Borrowing löst Coverage, aber **Matching-Accuracy ist separates Problem**.

## Nächster Schritt

Kategorie-Normalisierung `food_group_normalized`. Research läuft parallel, Scanner-Build pausiert bis Ergebnisse da sind. Borrowing + Embeddings + Schema sind reuse-bar.
