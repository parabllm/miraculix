---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-12
art: fortschritt
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["supabase", "gemini", "pg_cron"]
---

Komplette Prompt-Iteration von v1 bis v7 durchgezogen. Generic-Naming-Fix, Multiplier-Removal, Prinzipien-Hierarchie, Inferred-Query-Context eingebaut. Validiert mit Burger, Baguette, Crêpe + Tajine, Kebab.

## Stand

- **Edge Function:** `food-scanner-gemini` v7 live, Gemini 2.5 Flash-Lite, SSE-Streaming, in-memory LRU Embedding-Cache
- **Latenzen:** 2.5-7s total, 1.0-2.0s first ingredient (nach Warmup)
- **Cron:** `pg_cron` jede Minute Keepalive aktiv
- **Test-Bilder-Suite:** 5 Bilder, Cache wird vor jedem Test geleert

## Hauptlearnings

- Prompt-Iteration stößt an Grenze - verbleibende Probleme (Tomato → canned, chicken breast → stock cubes, mayonnaise → NONE) sind **RPC/DB-Probleme, nicht Prompt**
- Nächster Hebel: `food_group_normalized` Backfill + `match_nutrition`-RPC mit Kategorie-Filter + Source-Ranking
- OFF-Datenbank-Import für DB-Lücken (Mayo, weiße Buns, Fast-Food-Items)
