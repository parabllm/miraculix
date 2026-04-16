---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-11
art: entscheidung
vertrauen: extrahiert
quelle: manuell
werkzeuge: ["openai", "supabase", "pgvector"]
---

Food-Scanner-Architektur nach V1-V5.1 **final festgezogen**. Stack steht, V5.1-Research-Ergebnisse ausstehend, danach Code-Build.

## Final-Stack

- **Vision:** GPT-4o (OpenAI direkt) mit Strict JSON Schema + `logprobs: true`. Einziges Modell mit beidem in einer API. Self-Reported Confidence raus
- **Nutrition:** pgvector in Supabase mit aggregierten Open-Data-DBs (BLS 4.0 + CIQUAL + USDA + internationale, V5.1 klärt welche). Keine externe API
- **Orchestrierung:** Supabase Edge Function `food-scanner` (Deno, EU), nicht n8n. Streaming JSON Parsing
- **Quality Gate:** Logprob-Score + Cosine-Similarity, deterministisch
- **Eskalation Stufe 4:** Gemini 2.5 Flash (Cost-optimiert), darf NUR Such-Strings reformulieren, NIE Nährwerte erfinden
- **Storage:** Supabase Bucket `food-scans/{user_id}/{timestamp}.jpg`

## Hard Constraints von Deniz

1. Qualität > Latenz > Cost
2. Geo/Time/History als Soft Hints, NIE Hard Filter
3. Internationale DB-Coverage Pflicht (polnisch, marokkanisch, asiatisch etc.)
4. DSGVO: provider-agnostisch bauen
5. Mikronährstoffe Pflicht (14 Felder)
6. Hauptfokus selbstgekochte + Restaurant-Mischgerichte
7. Live-Deployment ist Ziel, kein Mock

## Lesson Learned

Geo-als-Hard-Filter-Bug wurde erst durch Denizs explizite Frage erkannt. Bei Multi-Input-Architekturen muss der Failure-Mode "Kontext widerspricht visueller Realität" proaktiv durchdacht werden.
