# Stand-Snapshot: Borrowing durch, vor Kategorie-Fix

Areas: coralate
Confidence: Confirmed
Created: 12. April 2026 20:40
Date: 12. April 2026
Gelöscht: No
Log ID: LG-9
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Claude session
Summary: Stand gesichert vor Kategorie-Fix: 25.623 Foods, Borrowing 3-Pass durch (98-100% Coverage). Matching-Accuracy-Problem identifiziert → Research für food_group_normalized.
Type: Progress

**Verweis Status-Doc:** [Food Scanner v2 Architecture](../Docs/Food%20Scanner%20v2%20Architecture%20%E2%80%94%20Post-Jann%20Adjustmen%2034091df4938681549168f91af273bc0d.md)

## DB-Stand jetzt (vollständig)

- 25.623 Foods importiert, alle mit OpenAI Embeddings (1536-dim)
- Cross-DB Borrowing 3 Passes durch (0.55/2 → 0.6/3 → 0.65/4)
- Mineralien: 100% außer OFF (85%)
- Vitamine: 98-100% außer OFF (82%)
- food_scan_cache Schema erweitert (Migration 002)
- Edge Function noch nicht gebaut

## Kritisches Problem identifiziert

Semantic Retrieval matched systematisch falsche Kategorien. Echte Tests:

- 'burger bun' → matched 'Hamburger' (ganzes Gericht statt Brötchen)
- 'sauce' → matched 'Sriracha' (zu spezifisch)
- 'potato fried' → matched 'Rösti' (falsches Gericht)

Borrowing hat Coverage gelöst, aber Matching-Accuracy ist ein separates Problem.

## Nächster Schritt

Kategorie-Normalisierung food_group_normalized. Details in Research-Prompts. Research läuft parallel, Scanner-Build pausiert bis Ergebnisse da sind.

## Was bleibt stabil

Borrowing-Ergebnisse, Embeddings, Schema — alles kann wiederverwendet werden nach Re-Import. Nur neue Spalte food_group_normalized kommt dazu.