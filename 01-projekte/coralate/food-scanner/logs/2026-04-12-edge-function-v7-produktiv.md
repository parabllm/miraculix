---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-12
art: meilenstein
vertrauen: bestätigt
quelle: chat_session
werkzeuge: ["supabase", "openai", "deno"]
---

Edge Function `food-scanner` von v1 auf **v7** iteriert. Start war fehlerhaft (sequentieller Tier-1 + Tier-3 Fallback bei Gate-Fail), Ende ist sauberer Hybrid-Pfad. **Pipeline end-to-end bei 10s Latenz, $0.004-0.006 pro Scan.**

## Iteration v1 → v7

- **v2:** Embedding+RPC parallelisiert via `Promise.all`. Tier-3-Blind-Fallback raus, Hybrid-Modus (Vision-Zutaten bleiben, Bognár drauf bei Gate-Fail)
- **v3:** Token-Usage + Kosten in Response, `detail=low` als Default
- **v4:** Prio-Teller-Fokus im Prompt (ignoriert Nebenteller, Getränke, Hintergrund)
- **v5:** Batch-Embeddings in 1 OpenAI-Call statt N parallele. Embed-Block von ~800ms/call auf 349ms total
- **v6:** Multi-Match RPC via CROSS JOIN LATERAL (rückgängig in v7, nur 500ms Ersparnis bei komplexerem Code)
- **v7:** Inferred-Ingredients mit Visibility-Marker. Olivenöl, Dressings, Cooking-Oils bei Salaten/Pasta/Fertiggerichten automatisch ergänzt. **Behebt systematischen Kalorien-Underreporting-Bug**

## Größter Hebel: 800px Client-Side-Downsize

Vor Upload via Canvas-API (HTML-Tool) bzw. `expo-image-manipulator` (App). Upload-Größe −97%, Vision-Latenz −40%, Input-Tokens −53%.

## Deliverables

- Edge Function v7 live auf `vviutyisqtimicpfqbmi`
- HTML-Test-Tool v4 mit Resize-Toggle, detail-Toggle, Metrics-Panel
- PDF-Briefing v3 für Jann + Lars mit Expo-Integration-Snippet
- Bucket-Policies (`food-scans` public + anon insert)
- SQL-Patches: `tier_used` CHECK um `tier1_vision_hybrid` erweitert

## Offene Themen

- Latenz-Reduktion (3 Research-Prompts formuliert)
- Sweet-Corn-Granularität (Vision clustert in Bucket-Kategorien)
- OFF/00004800 Bratwurst Einheiten-Bug (360g statt 360mg Natrium)
- B6-NULL-Werte (Cross-DB-Borrowing parallel)
