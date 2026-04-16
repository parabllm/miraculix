---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-12
art: fortschritt
vertrauen: bestaetigt
quelle: chat_session
werkzeuge: ["supabase", "pgvector"]
---

Cross-DB Borrowing Pass 1 live: threshold 0.55, min 2 Nachbarn, Top-20-Pool. Script läuft lokal, ~1h20 ETA.

## 3-Pass-Strategie

Pass 1 (0.55 / 2) → Pass 2 (0.6 / 3 `--resume`) → Pass 3 (0.65 / 4 `--resume`).

**Self-Healing-Mechanik:** mit jedem Pass wächst der Nachbarschafts-Pool, striktere Kriterien finden trotzdem mehr Hits.

SQL-Funktion `borrow_missing_nutrients_v2(id, threshold, min_n)` parametrisch in DB deployed.

## Jann Voice-Call — Ingredient-Korrektur-Requirements

- User muss Gramm-Werte pro Ingredient editieren
- Neue Zutaten hinzufügen, bestehende entfernen
- Nach Re-Submit frische Totals
- `food_scan_cache` muss Original + Korrektur separat speichern (Feedback-Flywheel)

## Nächste Schritte

1. `food_scan_cache`-Schema erweitern (ALTER TABLE, 4 neue Spalten)
2. Edge Function `food-scanner` bauen (Dual-Flow + Recalculate-Endpoint)
3. HTML Test-Tool

## Parkiert

`BLS/USDA food_groups` — Borrowing nutzt nur Embeddings, nicht `food_group` als Filter. Später optional als Qualitäts-Guardrail.
