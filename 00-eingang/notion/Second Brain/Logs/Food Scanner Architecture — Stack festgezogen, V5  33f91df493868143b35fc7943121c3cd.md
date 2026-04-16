# Food Scanner Architecture — Stack festgezogen, V5.1 Research läuft

Areas: coralate
Confidence: User-stated
Created: 11. April 2026 18:04
Date: 11. April 2026
Gelöscht: No
Log ID: LG-2
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Manual
Type: Decision

Food Scanner Architektur ist nach V1-V5.1 final festgezogen. Stack steht, V5.1 Research-Ergebnisse stehen noch aus, danach Code-Build.

## Final-Stack

- **Vision Layer:** GPT-4o (OpenAI direkt) mit Strict JSON Schema + `logprobs: true`. Einziges Modell mit beidem in einer API. Self-Reported Confidence raus.
- **Nutrition Layer:** pgvector in Supabase mit aggregierten Open-Data-DBs (BLS 4.0 + CIQUAL + USDA + internationale, V5.1 klärt welche). Keine externe API.
- **Orchestrierung:** Supabase Edge Function `food-scanner` (Deno, EU), nicht n8n. Streaming JSON Parsing.
- **Quality Gate:** Logprob-Score + Cosine-Similarity, deterministisch.
- **Eskalation Stufe 4:** Gemini 2.5 Flash (anderes Modell, Cost-optimiert), darf NUR Such-Strings reformulieren, NIE Nährwerte erfinden.
- **Storage:** Supabase Storage Bucket `food-scans/{user_id}/{timestamp}.jpg`, Frontend lädt hoch und schickt Pfad an Edge Function.

## Hard Constraints von Deniz

1. Qualität > Latenz > Cost (in dieser Reihenfolge)
2. Geo/Time/History als Soft Hints, NIE Hard Filter
3. Internationale DB-Coverage Pflicht (polnisch, marokkanisch, asiatisch etc.)
4. DSGVO Position 3: Pre-Launch egal, später härter, Architektur provider-agnostisch bauen
5. Mikronährstoffe Pflicht (14 Felder)
6. Hauptfokus selbstgekochte + Restaurant-Mischgerichte
7. Live-Deployment ist Ziel, kein Mock

## Status

- V5.1 Research-Prompt eingefroren mit 6 Fragen (Schema-Realität BLS/CIQUAL/USDA, Logprob-Mechanik, Embedding-Modell, API-Fallback-Notwendigkeit, Geo als Soft Hint, internationale DB-Coverage)
- Stand-by bis V5.1 zurückkommt
- Danach: Cross-Check, Finalisierung, Build (Migration + Edge Function + HTML Test-Tool)

## Lesson Learned

Geo-als-Hard-Filter Bug ist mir zu spät aufgefallen — erst durch Denizs explizite Frage. Bei Hybrid-Systemen mit Soft Signals muss ich proaktiv den Failure-Mode "Kontext widerspricht visueller Realität" durchdenken. Ab jetzt Pflicht-Check bei jeder Multi-Input-Architektur.